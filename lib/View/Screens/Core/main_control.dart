// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/Data/Models/lesson.dart';
import 'package:education/View/Screens/Core/Student/student_home_screen.dart';
import 'package:education/View/Screens/Core/Student/student_lessons_screen.dart';
import 'package:education/View/Screens/Core/Student/student_profile_screen.dart';
import 'package:education/View/Screens/Core/Teacher/teacher_home_screen.dart';
import 'package:education/View/Screens/Core/Teacher/teacher_lessons_screen.dart';
import 'package:education/View/Screens/Core/Teacher/teacher_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainControl extends StatefulWidget {
  final String userId;
  final String role;
  final List<Lesson> lessons;

  const MainControl({
    super.key,
    required this.userId,
    required this.role, required this.lessons,
  });

  @override
  State<MainControl> createState() => _MainControlState();
}

class _MainControlState extends State<MainControl> {
  late final List<Widget> _screens;
  int _currentIndex = 0;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    print(widget.lessons);
    _loadUserData();
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        throw 'User not found';
      }
    } catch (e) {
      throw 'Error fetching user data: $e';
    }
  }

  Future<void> _loadUserData() async {
    try {
      var userData = await getUserData(widget.userId);
      setState(() {
        _userData = userData;
        _screens = widget.role == 'Öğretmen'
            ? [
                TeacherHomeScreen(userData: _userData! , userId:  widget.userId),
                TeacherLessonsScreen(userId: widget.userId),
                TeacherProfileScreen(
                   userId:  widget.userId),
              ]
            : [
                StudentHomeScreen(userId: widget.userId ),
                StudentLessonsScreen(userData: _userData!,userId: widget.userId ),
                StudentProfileScreen( hideIcon: false, userId:  widget.userId),
              ];
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primary,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, size: 20),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.videocam_fill),
            label: widget.role == 'Öğretmen' ? 'Ders Aç' : 'Derslerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_circle_fill),
            label: 'Profil',
          ),
        ],
        selectedItemColor: AppColors.activeChoose,
        unselectedItemColor: AppColors.headTitleText,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.activeChoose,
          fontWeight: FontWeight.w300,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}