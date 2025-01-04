import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/Data/Models/lesson.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';  // intl paketini ekleyin

enum LessonInfoType { tarih, ders, link }

class MeetDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const MeetDetailScreen({super.key, required this.lesson});

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
                        letterSpacing: -1),
                  ),
                ],
              ),
            ),
          ),
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
              lessonsInfo(
                'Link',
                widget.lesson.googleMeetLink,
                Colors.yellow.shade50,
                Icons.link,
                Colors.yellow.shade400,
                LessonInfoType.link,
              ),
              SizedBox(height: 24),
              Text(
                'Eğitmen',
                style: GoogleFonts.inter(
                  color: AppColors.headTitleText,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 8),
              Container(
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
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Öğrenciler',
                style: GoogleFonts.inter(
                  color: AppColors.headTitleText,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  shrinkWrap:
                      true, 
                  itemCount: widget.lesson.participants.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0), 
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 36,
                            color: AppColors.button,
                          ),
                          SizedBox(width: 12),
                          Text(
                            widget.lesson.participants[index],
                            style: GoogleFonts.inter(
                              color: AppColors.headTitleText,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  physics: ClampingScrollPhysics(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

String formatTimestamp(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return DateFormat('d MMMM yyyy HH:mm').format(date); // Örnek: 14 August 2024 13:50
}

String formatTime(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return DateFormat('HH:mm').format(date); // Örnek: 13:50
}

  Padding lessonsInfo(String title, String subTitle, Color color, IconData icon,
      Color iconColor, LessonInfoType type) {
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
          Padding(
            padding: EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Flexible(
  child: Text(
    subTitle,
    style: GoogleFonts.inter(
      color: AppColors.headTitleText,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
),

                Row(
                  children: [
                    Text(
                      subTitle,
                      style: GoogleFonts.inter(
                          color: AppColors.headTitleText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                    if (type == LessonInfoType.tarih) ...[
                      SizedBox(width: 8),
                      Text(
                        '-',
                        style: GoogleFonts.inter(
                            color: AppColors.headTitleText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      SizedBox(width: 8),
                      Text(
                        formatTime(widget.lesson.endTime), 
                        style: GoogleFonts.inter(
                            color: AppColors.headTitleText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16 ),
                      ),
                    ],
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
