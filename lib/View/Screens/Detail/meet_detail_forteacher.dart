// ignore_for_file: deprecated_member_use

import 'package:education/Core/Constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/View/Screens/Core/Student/student_profile_screen.dart';

class MeetDetailForteacher extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MeetDetailForteacher({super.key, required this.userData});

  @override
  State<MeetDetailForteacher> createState() => _MeetDetailForteacherState();
}

class _MeetDetailForteacherState extends State<MeetDetailForteacher> {
  @override
  void initState() {
    super.initState();
  }

  // Method to launch the URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  // Check if the current time is within the lesson's time range
  bool _isWithinLessonTime(DateTime startTime, DateTime endTime) {
    DateTime now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  @override
  Widget build(BuildContext context) {
    var lesson = widget.userData;
    DateTime startTime = lesson['startTime'].toDate();
    DateTime endTime = lesson['endTime'].toDate();

    bool canJoinLesson = _isWithinLessonTime(startTime, endTime);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          lesson['title'],
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.purple.shade400,
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tarih',
                          style: GoogleFonts.inter(
                            color: AppColors.subTitleText,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat('dd MMMM yyyy').format(startTime),
                              style: GoogleFonts.inter(
                                color: AppColors.headTitleText,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              DateFormat('HH:mm').format(startTime),
                              style: GoogleFonts.inter(
                                color: AppColors.headTitleText,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 2),
                            Text('-'),
                            SizedBox(width: 2),
                            Text(
                              DateFormat('HH:mm').format(endTime),
                              style: GoogleFonts.inter(
                                color: AppColors.headTitleText,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
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
              padding: EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.link,
                        color: Colors.yellow.shade400,
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link',
                          style: GoogleFonts.inter(
                            color: AppColors.subTitleText,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          lesson['googleMeetLink'] ?? 'Bilgi Yok',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: canJoinLesson
                        ? () {
                            _launchURL(lesson['googleMeetLink']);
                          }
                        : null,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      decoration: BoxDecoration(
                        color: canJoinLesson
                            ? AppColors.button
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.queue_play_next_sharp,
                            color: canJoinLesson
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Derse Git',
                            style: GoogleFonts.inter(
                              color: canJoinLesson
                                  ? AppColors.primary
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!canJoinLesson)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Zamanı geldiğinde buton tıklanılabilir olacak',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 22),
            buildSectionTitle('Katılımcılar'),
            SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lessons')
                  .doc(lesson['id'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Bir hata oluştu');
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('Henüz katılımcı bulunmamaktadır');
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                List<dynamic> participants = data['dersi_alanlar'] ?? [];

                if (participants.isEmpty) {
                  return Text('Henüz katılımcı bulunmamaktadır');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              body: StudentProfileScreen(
                                hideIcon: true,
                                userId: participants[index]['userId'],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric( vertical: 8.0),
                        child: Container(
                          padding: EdgeInsets.only(left: 12),
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: AppColors.button , size:38,),
                              SizedBox(width: 12),
                              Text(
                                participants[index]['fullName'] ??
                                    'İsimsiz Katılımcı',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildSectionTitle(String title) {
  return Text(
    title,
    style: GoogleFonts.inter(
      color: AppColors.headTitleText,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  );
}
