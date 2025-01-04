// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:education/Core/Constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/View/Screens/Detail/meet_detail_forteacher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TeacherHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const TeacherHomeScreen({
    super.key,
    required this.userData,
    required this.userId,
  });

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  late String userId;
  late Stream<DocumentSnapshot> userStream;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    userStream =
        FirebaseFirestore.instance.collection('Users').doc(userId).snapshots();
  }

  DateTime parseDate(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          'Yaklaşan Ders',
          style: TextStyles.appBarTitle,
        ),
        centerTitle: false,
        backgroundColor: AppColors.secondary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUpcomingLessonSection(),
          _buildSectionTitle('Açtığın Dersler'),
          Expanded(
            child: _buildLessonList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingLessonSection() {
    return AspectRatio(
      aspectRatio: 3.8,
      child: Container(
        padding: EdgeInsets.only(left: 12, top: 12),
        color: AppColors.secondary,
        child: StreamBuilder<DocumentSnapshot>(
          stream: userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return Center(child: Text('Yaklaşan ders bulunamadı'));
            }

            var userData = snapshot.data!;
            List<dynamic> lessons = userData['alınan_dersler'] ?? [];

            if (lessons.isEmpty) {
              return Center(child: Text('Yaklaşan ders bulunamadı'));
            }


            var upcomingLesson = lessons.first;
            return LessonCard(lesson: upcomingLesson);
          },
        ),
      ),
    );
  }

  Widget _buildLessonList() {
  return StreamBuilder<DocumentSnapshot>(
    stream: userStream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData) {
        return Center(child: Text('Veri bulunamadı'));
      }

      var userData = snapshot.data!;
      List<dynamic> lessons = userData['alınan_dersler'] ?? [];

      if (lessons.isEmpty) {
        return Center(
          child: Text(
            'Henüz açtığınız ders bulunmamaktadır',
            style: TextStyles.noDataMessage,
          ),
        );
      }

      // Sorting the lessons based on startTime
      lessons.sort((a, b) {
        Timestamp timestampA = a['startTime'];
        Timestamp timestampB = b['startTime'];

        DateTime dateA = timestampA.toDate();
        DateTime dateB = timestampB.toDate();

        return dateA.compareTo(dateB);
      });

      return ListView.builder(
        shrinkWrap: true,
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          var lesson = lessons[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: LessonCard(lesson: lesson),
          );
        },
      );
    },
  );
}


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
      child: Text(
        title,
        style: TextStyles.sectionTitle,
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetDetailForteacher(
              userData: lesson, // Pass userData here
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 14),
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: _buildLessonInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SizedBox(
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
                  'https://via.placeholder.com/150'), // Profil resmi buraya gelecek
            ),
          ),
        ],
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy ').format(dateTime);
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

  Widget _buildLessonInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lesson['title'],
          style: TextStyles.lessonTitle,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildDateIcon(),
            const SizedBox(width: 8),
            Text(
              formatLessonTime2(lesson['startTime']),
              style: TextStyles.lessonDate,
            ),
            SizedBox(
              width: 2,
            ),
            Text(
              formatLessonTime(lesson['startTime'], lesson['endTime']),
              style: TextStyles.lessonDate,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          CupertinoIcons.clock,
          size: 18,
          color: Colors.black,
        ),
      ),
    );
  }
}

class TextStyles {
  static TextStyle appBarTitle = GoogleFonts.inter(
    fontSize: 24,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle sectionTitle = GoogleFonts.inter(
    fontSize: 24,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle lessonTitle = GoogleFonts.inter(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static TextStyle lessonDate = GoogleFonts.inter(
    color: AppColors.subTitleText,
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  static TextStyle lessonTime = GoogleFonts.inter(
    color: AppColors.headTitleText,
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  static TextStyle noDataMessage = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
}
