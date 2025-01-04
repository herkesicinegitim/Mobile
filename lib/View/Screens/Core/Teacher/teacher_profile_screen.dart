// ignore_for_file: use_build_context_synchronously, unused_element, deprecated_member_use, prefer_interpolation_to_compose_strings

import 'package:education/Core/Constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TeacherProfileScreen extends StatefulWidget {
  final String userId;

  const TeacherProfileScreen({super.key, required this.userId});

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
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

    return '$startFormatted ';
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

          // Firestore'dan gelen user verisi
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var dersler = userData['alınan_dersler'] ?? [];

          // Dersleri tarihe göre sıralama
          DateTime parseDate(dynamic date) {
            if (date is Timestamp) {
              return date.toDate();
            } else if (date is String) {
              return DateTime.parse(date); // String tarih varsa
            } else {
              throw Exception('Invalid date type');
            }
          }

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
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: userData['profilePhoto'] != null
                                ? NetworkImage(userData['profilePhoto'])
                                : NetworkImage(
                                    'https://via.placeholder.com/150'),
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
                                'Düz Öğretmen',
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text(
                                        'Çıkmak İstediğinize Emin Misiniz?'),
                                    content:
                                        Text('Hesabınızdan çıkmak üzeresiniz.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Hayır'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          logout(context);
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
                              '${userData['weeklyCount']} ders',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: AppColors.headTitleText,
                                fontWeight: FontWeight.bold,
                              ),
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
                      'Açtığın Dersler',
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
                            left: 16, right: 16, bottom: 12),
                        child: Container(
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12)),
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
                                    SizedBox(width: 24),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            '${dersler[index]['title']}',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              formatLessonTime2(
                                                  dersler[index]['startTime']),
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: AppColors.subTitleText,
                                              ),
                                            ),
                                            Text(
                                              formatLessonTime(
                                                dersler[index]['startTime'],
                                                dersler[index]['endTime'],
                                              ),
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: AppColors.headTitleText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
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
