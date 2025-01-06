// ignore_for_file: deprecated_member_use, unnecessary_cast, avoid_print

import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/Data/Models/lesson.dart';
import 'package:education/View/Screens/Detail/meet_detail_screen.dart';
import 'package:education/View/Widgets/CustomUIElements/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LessonsContainer extends StatefulWidget {
  final Lesson lesson;
  final String userId;

  const LessonsContainer({
    super.key,
    required this.lesson,
    required this.userId,
  });

  @override
  State<LessonsContainer> createState() => _LessonsContainerState();
}

class _LessonsContainerState extends State<LessonsContainer> {
  bool isLessonTaken = false;
  int weeklyCount = 5;

  @override
  void initState() {
    super.initState();
    checkLessonStatus();
  }

  // Ders alma işlemi başlatıldığında çağrılır. 
  // Haftalık ders hakkı kontrol edilir, kullanıcı onay verirse ders eklenir.
  Future<void> onTakeLesson() async {
    if (weeklyCount <= 0) {
      showPopup(
        title: "Ders Alamazsınız",
        message: "Aylık ders hakkınızı doldurdunuz.",
      );
      return;
    }

    final bool confirm = await showConfirmationPopup(
      title: "Ders Alma",
      message: "Haftalık hakkınız 1 azalacaktır. Devam etmek istiyor musunuz?",
    );

    if (confirm) {
      await updateUserLessons(widget.userId, widget.lesson);
    }
  }

  // Kullanıcıdan onay almak için pop-up gösterir.
  Future<bool> showConfirmationPopup({
    required String title,
    required String message,
  }) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          title: Text(title, style: GoogleFonts.inter(color: Colors.black)),
          content:
              Text(message, style: GoogleFonts.inter(color: Colors.black54)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                confirmed = false;
                Navigator.of(context).pop();
              },
              child: Text("Hayır", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                confirmed = true;
                Navigator.of(context).pop();
              },
              child: Text("Evet", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
    return confirmed;
  }

  // Kullanıcının mevcut ders durumu ve haftalık hakları Firebase'den kontrol edilir.
  Future<void> checkLessonStatus() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> takenLessons = userData['alınan_dersler'] ?? [];
        
        setState(() {
          weeklyCount = userData['weeklyCount'] ?? 5;
          isLessonTaken = takenLessons.any((lesson) => 
            lesson['title'] == widget.lesson.title && 
            lesson['startTime'] == widget.lesson.startTime
          );
        });
      }
    } catch (e) {
      print("Ders durumu kontrol edilirken hata oluştu: $e");
    }
  }

  // Kullanıcının ders geçmişini günceller.
  // Ders alınırsa, haftalık hak düşer ve ders kullanıcıya eklenir.
  Future<void> updateUserLessons(String userId, Lesson lesson) async {
    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        int currentWeeklyCount = userData['weeklyCount'] ?? 5;

        if (currentWeeklyCount > 0) {
          await userDocRef.update({
            'alınan_dersler': FieldValue.arrayUnion([
              {
                'title': lesson.title,
                'day': lesson.day,
                'startTime': lesson.startTime,
                'endTime': lesson.endTime,
                'meetLink': lesson.googleMeetLink,
              }
            ]),
            'weeklyCount': currentWeeklyCount - 1,
          });

          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('lessons')
              .where('title', isEqualTo: lesson.title)
              .limit(1)
              .get();

          if (snapshot.docs.isNotEmpty) {
            DocumentReference lessonDocRef = snapshot.docs.first.reference;
            await lessonDocRef.update({
              'dersi_alanlar': FieldValue.arrayUnion([
                {
                  'fullName': userData['fullName'],
                  'profilePhoto': userData['profilePhoto'],
                  'userId': widget.userId,
                }
              ])
            });
          }

          setState(() {
            isLessonTaken = true;
            weeklyCount = currentWeeklyCount - 1;
          });

          print("Ders başarıyla eklendi: ${lesson.title}");
        } else {
          showPopup(
            title: "Hakkınız Yok",
            message: "Haftalık ders hakkınız bitti.",
          );
        }
      }
    } catch (e) {
      print("Ders eklenirken hata oluştu: $e");
    }
  }

  // Kullanıcıya bir pop-up mesajı gösterir.
  void showPopup({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          title: Text(title, style: GoogleFonts.inter(color: Colors.black)),
          content:
              Text(message, style: GoogleFonts.inter(color: Colors.black54)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Tamam", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Tarihi belirli bir formatta döndürür.
  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('d MMMM yyyy');
    return formatter.format(dateTime);
  }

  // Zamanı belirli bir formatta döndürür.
  String formatTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    DateTime startTime = (widget.lesson.startTime as Timestamp).toDate();
    DateTime endTime = (widget.lesson.endTime as Timestamp).toDate();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetDetailScreen(
              isLessonTaken: isLessonTaken,
              lesson: widget.lesson,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.secondary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              child: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.button,
                                ),
                                child: Center(
                                    child: Icon(
                                  Icons.person_2_outlined,
                                  color: Colors.white,
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lesson.title,
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    CupertinoIcons.clock,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatDate(startTime),
                                    style: GoogleFonts.inter(
                                      color: AppColors.headTitleText,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    '${formatTime(startTime)} - ${formatTime(endTime)}',
                                    style: GoogleFonts.inter(
                                      color: AppColors.headTitleText,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 33,
                  child: CustomButton(
                    text: isLessonTaken
                        ? "Ders Alındı"
                        : weeklyCount > 0
                            ? "Dersi Al"
                            : "Hakkınız Yok",
                    isThereIcon: false,
                    color: isLessonTaken ? Colors.grey : AppColors.button,
                    onTap: isLessonTaken
                        ? null
                        : () {
                            onTakeLesson();
                          },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
