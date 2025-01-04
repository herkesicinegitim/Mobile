// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/Data/Models/lesson.dart';
import 'package:education/View/Widgets/CustomWidget/lessons_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentHomeScreen extends StatefulWidget {
  final String userId;

  const StudentHomeScreen({super.key, required this.userId});
  
  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String categoryNames = 'Tümü';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    categoryNames = categoriesList.first;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<String> categoriesList = [
    'Tümü',
    'Matematik',
    'Geometri',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'İngilizce',
    'Türkçe',
    'Almanca',
    'Felsefe',
    'Edebiyat',
  ];

  Future<List<Lesson>> fetchLessons(String categoryFilter) async {
    final lessonsCollection = FirebaseFirestore.instance.collection('lessons');

    Query query = lessonsCollection;
    if (categoryFilter != 'Tümü') {
      query = query.where('lessonType', isEqualTo: categoryFilter);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      if (data != null) {
        return Lesson.fromMap(data as Map<String, dynamic>);
      } else {
        return Lesson.fromMap(data as Map<String, dynamic>);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Uygun Dersler',
          style: GoogleFonts.inter(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
        
        ],
      ),
      body: Column(
        children: [
          horizontalFilterBar(),
          Expanded(
            child: FutureBuilder<List<Lesson>>(
              future: fetchLessons(categoryNames),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Bir hata oluştu: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('Burada henüz ders yok'),
                  );
                }

                final lessons = snapshot.data!;
                return ListView.separated(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return LessonsContainer(
                      lesson: lesson,
                      userId: widget.userId,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10);
                  },
                  physics: ClampingScrollPhysics(),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Padding horizontalFilterBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 7, right: 7, top: 4, bottom: 10),
      child: SizedBox(
        height: 33,
        child: ListView.builder(
          controller: _scrollController,
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: categoriesList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  categoryNames = categoriesList[index];
                });
                _scrollController.animateTo(
                  (index * 70).toDouble(),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.linear,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: categoryNames == categoriesList[index]
                        ? AppColors.activeChoose
                        : AppColors.button,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 400),
                        style: categoryNames == categoriesList[index]
                            ? GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              )
                            : GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                        child: Text(categoriesList[index]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
