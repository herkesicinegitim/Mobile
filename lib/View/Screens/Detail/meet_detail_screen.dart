// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/Data/Models/lesson.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

enum LessonInfoType { tarih, ders, link }

class MeetDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final bool isLessonTaken;

  const MeetDetailScreen(
      {super.key, required this.lesson, required this.isLessonTaken});

  @override
  State<MeetDetailScreen> createState() => _MeetDetailScreenState();
}

class _MeetDetailScreenState extends State<MeetDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: widget.isLessonTaken ? Text('') : Text(widget.lesson.title),
        actions: [
          widget.isLessonTaken
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      _launchURL(widget.lesson.googleMeetLink);
                    },
                    child: Container(
                      width: 169,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.button,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.queue_play_next_sharp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Derse Git',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lessonsInfo(
                'Tarih',
                formatTimestamp(widget.lesson.startTime),
                Colors.purple.shade50,
                Icons.calendar_month_outlined,
                Colors.purple.shade400,
                LessonInfoType.tarih,
              ),
              lessonsInfo(
                'Konu',
                widget.lesson.lessonType,
                Colors.blue.shade50,
                CupertinoIcons.building_2_fill,
                Colors.blue.shade400,
                LessonInfoType.ders,
              ),
              widget.isLessonTaken
                  ? lessonsInfo(
                      'Link',
                      widget.lesson.googleMeetLink,
                      Colors.yellow.shade50,
                      Icons.link,
                      Colors.yellow.shade400,
                      LessonInfoType.link,
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 24),
              buildSectionTitle('Eğitmen'),
              SizedBox(height: 12),
              buildInstructorInfo(),
              SizedBox(height: 16),
              buildSectionTitle('Öğrenciler'),
              SizedBox(height: 16),
              buildParticipantsList(),
            ],
          ),
        ),
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('d MMMM yyyy HH:mm').format(date);
  }

  String formatTime(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('HH:mm').format(date);
  }

  Padding lessonsInfo(
    String title,
    String subTitle,
    Color color,
    IconData icon,
    Color iconColor,
    LessonInfoType type,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.subTitleText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: subTitle));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Meet Kopyalandı!'),
                            ),
                          );
                        },
                        child: Text(
                          subTitle,
                          style: GoogleFonts.inter(
                            color: AppColors.headTitleText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (type == LessonInfoType.tarih) ...[
                      SizedBox(width: 8),
                      Text(
                        '-',
                        style: GoogleFonts.inter(
                          color: AppColors.headTitleText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        formatTime(widget.lesson.endTime),
                        style: GoogleFonts.inter(
                          color: AppColors.headTitleText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget buildInstructorInfo() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 36,
              color: AppColors.button,
            ),
            SizedBox(width: 12),
            Text(
              widget.lesson.creator,
              style: GoogleFonts.inter(
                color: AppColors.headTitleText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildParticipantsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.lesson.participants.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  size: 36,
                  color: AppColors.button,
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.lesson.participants[index],
                    style: GoogleFonts.inter(
                      color: AppColors.headTitleText,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      physics: ClampingScrollPhysics(),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
