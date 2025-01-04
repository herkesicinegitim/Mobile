// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:education/Core/Constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class StudentProfileScreen extends StatefulWidget {
  final String userId;

  const StudentProfileScreen({super.key, required this.userId});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  File? _imageFile;

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    try {
      if (_imageFile != null) {
        String fileName = '${widget.userId}_profile_photo'; // Dosya adı
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference reference =
            storage.ref().child('profile_photos/$fileName'); // Dosya yolu
        UploadTask uploadTask =
            reference.putFile(_imageFile!); // Fotoğrafı yükle

        // Yükleme tamamlandığında snapshot al
        TaskSnapshot snapshot = await uploadTask;

        // Yükleme tamamlandığında download URL'sini al
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Firestore'da profil fotoğrafı URL'sini güncelle
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .update({
          'profilePhoto': imageUrl, // 'profilePhoto' alanını güncelliyoruz
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil fotoğrafı başarıyla güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Başarıyla çıkış yapıldı')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çıkış yapılamadı: $e')),
      );
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String formatLessonTime(Timestamp startTimestamp, Timestamp endTimestamp) {
    DateTime startDate = startTimestamp.toDate();
    DateTime endDate = endTimestamp.toDate();

    String startFormatted = formatTime(startDate);
    String endFormatted = formatTime(endDate);

    return '$startFormatted - $endFormatted';
  }

  String formatLessonTime2(Timestamp startTimestamp) {
    DateTime startDate = startTimestamp.toDate();

    String startFormatted = formatDateTime(startDate);

    return startFormatted;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Kullanıcı verisi bulunamadı'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var dersler = userData['alınan_dersler'] ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: width < 380 ? 40 : 80, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap:
                                _pickImage, // Trigger image picker when tapped
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (userData['profilePhoto'] != null
                                      ? NetworkImage(userData['profilePhoto'])
                                      : NetworkImage(
                                          'https://via.placeholder.com/150')), // Placeholder
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['fullName'],
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Düz Öğrenci',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.subTitleText,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 93,
                            height: 33,
                            decoration: BoxDecoration(
                              color: AppColors.button,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                userData['role'],
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: Colors.black),
                            onPressed: () {
                              // Çıkış yapmadan önce kullanıcıya onay sorusu soralım
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors
                                        .white, // Arka plan rengini beyaz yap
                                    title: Text(
                                        'Çıkmak İstediğinize Emin Misiniz?'),
                                    content:
                                        Text('Hesabınızdan çıkmak üzeresiniz.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Popup'u kapat
                                        },
                                        child: Text('Hayır'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Popup'u kapat
                                          logout(context); // Çıkış işlemini yap
                                        },
                                        child: Text('Evet'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 16 + 35 / 4, right: 16, top: 16, bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(6)),
                        child: Icon(
                          CupertinoIcons.building_2_fill,
                          color: Colors.purple.shade400,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kalan aylık eğitim sayısı',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.subTitleText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              userData['weeklyCount'] == 0
                                  ? 'Hakkiniz kalmadi'
                                  : '${userData['weeklyCount']} ders',
                              style: GoogleFonts.inter(
                                  fontSize:
                                      userData['weeklyCount'] == 0 ? 14 : 16,
                                  color: userData['weeklyCount'] == 0
                                      ? Colors.red.shade300
                                      : AppColors.headTitleText,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Aldığınız Dersler',
                      style: GoogleFonts.inter(
                        fontSize: width < 380 ? 21 : 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Column(
                    children: List.generate(
                      dersler.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: 12.0, right: 16, left: 16),
                        child: Container(
                          height: 90,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: SizedBox(
                                          width: 60,
                                          height: 54,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                child: Container(
                                                  height: 36,
                                                  width: 36,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColors.button,
                                                  ),
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      'assets/icons/education.svg',
                                                      width: 24,
                                                      height: 24,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: NetworkImage(
                                                      'https://via.placeholder.com/150'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dersler[index]['title'],
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  formatLessonTime2(
                                                      dersler[index]['day'],),
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: Colors.black),
                                                ),
                                                SizedBox(width: 8,),
                                                Text(
                                                  formatLessonTime(
                                                      dersler[index]['startTime'],
                                                      dersler[index]['endTime']),
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
