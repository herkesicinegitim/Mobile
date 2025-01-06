// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/View/Screens/Detail/meet_detail_forteacher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  late Timer lessonCheckTimer;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    userStream =
        FirebaseFirestore.instance.collection('Users').doc(userId).snapshots();

    // Timer başlatılıyor: Her 1 dakikada bir dersleri kontrol edecek
    lessonCheckTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkAndDeleteExpiredLessons();
    });
  }

  @override
  void dispose() {
    // Timer'ı durduruyoruz
    lessonCheckTimer.cancel();
    super.dispose();
  }

  // Derslerin süresi dolmuş mu, kontrol edip Firestore'dan siliyoruz
  Future<void> _checkAndDeleteExpiredLessons() async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      List<dynamic> lessons = data['alınan_dersler'] ?? [];

      // Şu anki tarih ve saat
      final now = DateTime.now();

      // Silinmesi gereken dersleri filtreliyoruz
      List<dynamic> expiredLessons = lessons.where((lesson) {
        Timestamp startTime = lesson['startTime'];
        DateTime startDateTime = startTime.toDate();
        return now.isAfter(startDateTime.add(Duration(minutes: 15)));
      }).toList();

      // Firestore'dan dersleri siliyoruz
      for (var lesson in expiredLessons) {
        lessons.remove(lesson);
      }

      // Güncellenmiş ders listesini Firestore'a kaydediyoruz
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'alınan_dersler': lessons});
    }
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      color: AppColors.secondary,
      child: StreamBuilder<DocumentSnapshot>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
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
          return LessonCard(
            lesson: upcomingLesson,
            userId: userId,
          );
        },
      ),
    );
  }

  Widget _buildLessonList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
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
              child: LessonCard(
                lesson: lesson,
                userId: userId,
              ),
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
  final String userId;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetDetailForteacher(
              userData: lesson,
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(left: 6 , top: 12), child: _buildIcon()),
              const SizedBox(width: 1),
              _buildLessonInfo(context),
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
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.button,
              ),
              child: Center(
                  child: Icon(
                Icons.person,
                color: AppColors.primary,
              )),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLessonInfo(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
            width: MediaQuery.of(context).size.width - 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    lesson['title'],
                    style: TextStyles.lessonTitle,
                  ),
                ),
               
              ],
            ),
          ),
          SizedBox(height: 8),
          // Date and time
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: Row(
              children: [
                _buildDateIcon(),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMMM yyyy')
                      .format(lesson['startTime'].toDate()),
                  style: TextStyles.lessonDate,
                ),
                SizedBox(width: 12),
                Text(
                  DateFormat('HH:mm').format(lesson['startTime'].toDate()),
                  style: TextStyles.dateText,
                ),
                SizedBox(width: 2),
                Text('-'),
                SizedBox(width: 2),
                Text(
                  DateFormat('HH:mm').format(lesson['endTime'].toDate()),
                  style: TextStyles.dateText,
                ),
              ],
            ),
          ),
        ],
      ),
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

  static TextStyle dateText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.headTitleText,
  );
}
