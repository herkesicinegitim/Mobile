import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudentLessonsScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const StudentLessonsScreen({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<StudentLessonsScreen> createState() => _StudentLessonsScreenState();
}

class _StudentLessonsScreenState extends State<StudentLessonsScreen> {
  late List<Map<String, dynamic>> lessons;

  @override
  void initState() {
    super.initState();
    lessons = List<Map<String, dynamic>>.from(
        widget.userData['alınan_dersler'] ?? []);
  }

  Stream<List<Map<String, dynamic>>> getLessonsStream() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .snapshots()
        .map((snapshot) {
      final userData = snapshot.data() as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(userData['alınan_dersler'] ?? []);
    });
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

  Future<Map<String, dynamic>?> _getClosestLesson() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .get();

    final userData = snapshot.data() as Map<String, dynamic>;
    final List<Map<String, dynamic>> lessons =
        List<Map<String, dynamic>>.from(userData['alınan_dersler'] ?? []);

    lessons.sort((a, b) {
      final dateA = (a['day'] as Timestamp).toDate();
      final dateB = (b['day'] as Timestamp).toDate();
      return dateA.compareTo(dateB);
    });

    return lessons.isNotEmpty ? lessons.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Yaklaşan Dersler',
          style: GoogleFonts.inter(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 12 , right: 12 , top: 20 , bottom: 20),
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: _getClosestLesson(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                            
                    if (snapshot.hasError || snapshot.data == null) {
                      return Text(
                        "Yaklaşan ders bulunamadı.",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      );
                    }
                            
                    final lesson = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson['title'] ?? 'Bilinmeyen Ders',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.black54),
                            SizedBox(width: 8),
                            Text(
                              formatLessonTime2(lesson['startTime']),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.access_time,
                                size: 16, color: Colors.black54),
                            SizedBox(width: 8),
                            Text(
                              formatLessonTime(
                                lesson['startTime'],
                                lesson['endTime'],
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Aldığın Dersler',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getLessonsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Bir hata oluştu."));
                }

                final List<Map<String, dynamic>> lessons = snapshot.data ?? [];

                if (lessons.isEmpty) {
                  return Center(
                    child: Text(
                      "Henüz ders almadınız.",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson['title'] ?? 'Bilinmeyen Ders',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.black54),
                                SizedBox(width: 8),
                                Text(
                                  formatLessonTime2(lesson['startTime']),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.black54),
                                SizedBox(width: 8),
                                Text(
                                  formatLessonTime(
                                    lesson['startTime'],
                                    lesson['endTime'],
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
