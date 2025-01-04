// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/View/Widgets/CustomUIElements/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherLessonsScreen extends StatefulWidget {
  final String userId;

  const TeacherLessonsScreen({super.key, required this.userId});

  @override
  _TeacherLessonsScreenState createState() => _TeacherLessonsScreenState();
}

class _TeacherLessonsScreenState extends State<TeacherLessonsScreen> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TextEditingController titleController = TextEditingController();
  String? selectedLessonType;
  String? userFullName;
  List? lessons;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userFullName = userSnapshot['fullName'];
          lessons = userSnapshot['alınan_dersler'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı verileri bulunamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  final List<String> lessonTypes = [
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

  bool isLoading = false;

  void _pickDate() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height / 3.2,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  minimumDate: DateTime.now().subtract(
                    Duration(seconds: 1),
                  ),
                  maximumDate: DateTime.now().add(Duration(days: 365)),
                  onDateTimeChanged: (DateTime date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                )),
            CupertinoButton(
              child: Text('Tamam'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _pickTime(bool isStartTime) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height / 3.2,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime dateTime) {
                  setState(() {
                    final timeOfDay = TimeOfDay(
                      hour: dateTime.hour,
                      minute: dateTime.minute,
                    );
                    if (isStartTime) {
                      startTime = timeOfDay;
                    } else {
                      endTime = timeOfDay;
                    }
                  });
                },
              ),
            ),
            CupertinoButton(
              child: Text('Tamam'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _generateJitsiMeetLink(String lessonId) {
    String roomName = 'lesson_${lessonId}_${DateTime.now().millisecondsSinceEpoch}';
    return 'https://meet.jit.si/$roomName';
  }

  Future<void> _saveLessonToFirebase() async {
    if (selectedDate == null ||
        startTime == null ||
        endTime == null ||
        selectedLessonType == null ||
        titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    if (startTime != null && endTime != null) {
      if (startTime!.hour > endTime!.hour ||
          (startTime!.hour == endTime!.hour &&
              startTime!.minute >= endTime!.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Başlangıç saati, bitiş saatinden sonra olamaz')),
        );
        return;
      }
    }

    if (startTime != null &&
        (startTime!.hour < TimeOfDay.now().hour ||
            (startTime!.hour == TimeOfDay.now().hour &&
                startTime!.minute < TimeOfDay.now().minute))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Başlangıç saati şu andan önce olamaz')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Timestamp startTimestamp = Timestamp.fromDate(DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          startTime!.hour,
          startTime!.minute));
      Timestamp endTimestamp = Timestamp.fromDate(DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          endTime!.hour,
          endTime!.minute));

      List<dynamic> dersiAlanlar = [];
      
      String meetLink = _generateJitsiMeetLink(DateTime.now().millisecondsSinceEpoch.toString());

      DocumentReference newLessonRef =
          await FirebaseFirestore.instance.collection('lessons').add(
        {
          'title': titleController.text,
          'creator': userFullName,
          'date': Timestamp.fromDate(selectedDate!),
          'startTime': startTimestamp,
          'endTime': endTimestamp,
          'lessonType': selectedLessonType,
          'dersi_alanlar': dersiAlanlar,
          'googleMeetLink': meetLink
        },
      );

      Map<String, dynamic> newLesson = {
        'id': newLessonRef.id,
        'title': titleController.text,
        'date': Timestamp.fromDate(selectedDate!),
        'startTime': startTimestamp,
        'endTime': endTimestamp,
        'lessonType': selectedLessonType,
        'googleMeetLink': meetLink
      };

      setState(() {
        lessons = (lessons ?? [])..add(newLesson);
      });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .update({
        'alınan_dersler': lessons,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ders başarıyla oluşturuldu ve listeye eklendi')),
      );

      setState(() {
        titleController.clear();
        selectedDate = null;
        startTime = null;
        endTime = null;
        selectedLessonType = null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ders oluşturulurken hata meydana geldi: $e')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      selectedDate = null;
      selectedLessonType = null;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Ders Oluştur',
          style: GoogleFonts.inter(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                color: Colors.grey,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toplantı Başlığı :',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.subTitleText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    CustomTextField(
                      controller: titleController,
                      hintText: 'örn. Matematik Permütasyon...',
                      color: AppColors.secondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tarih:',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.subTitleText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedDate != null
                                  ? DateFormat('dd MMMM, yyyy')
                                      .format(selectedDate!)
                                  : 'Tarih Seçin',
                              style: selectedDate != null
                                  ? GoogleFonts.inter(
                                      fontSize: 16,
                                      color: AppColors.headTitleText,
                                      fontWeight: FontWeight.w500,
                                    )
                                  : GoogleFonts.inter(
                                      fontSize: 16,
                                      color: AppColors.subTitleText,
                                      fontWeight: FontWeight.w500,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Başlangıç:',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.subTitleText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: () => _pickTime(true),
                          child: Container(
                            height: 48,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                startTime != null
                                    ? startTime!.format(context)
                                    : 'Saat',
                                style: startTime != null
                                    ? GoogleFonts.inter(
                                        fontSize: 16,
                                        color: AppColors.headTitleText,
                                        fontWeight: FontWeight.w500,
                                      )
                                    : GoogleFonts.inter(
                                        fontSize: 16,
                                        color: AppColors.subTitleText,
                                        fontWeight: FontWeight.w500,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Bitiş:',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.subTitleText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: () => _pickTime(false),
                          child: Container(
                            height: 48,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                endTime != null
                                    ? endTime!.format(context)
                                    : 'Saat',
                                style: endTime != null
                                    ? GoogleFonts.inter(
                                        fontSize: 16,
                                        color: AppColors.headTitleText,
                                        fontWeight: FontWeight.w500,
                                      )
                                    : GoogleFonts.inter(
                                        fontSize: 16,
                                        color: AppColors.subTitleText,
                                        fontWeight: FontWeight.w500,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Ders Seç:',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.subTitleText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 0,
                      children: lessonTypes.map((lesson) {
                        return ChoiceChip(
                          label: Text(lesson),
                          selected: selectedLessonType == lesson,
                          selectedColor: Colors.blue.shade700,
                          backgroundColor: Colors.blue.shade100,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedLessonType = selected ? lesson : null;
                            });
                          },
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 46),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 33,
                            child: ElevatedButton(
                              onPressed: _resetForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text(
                                'İptal',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          SizedBox(
                            width: 100,
                            height: 33,
                            child: ElevatedButton(
                              onPressed:
                                  isLoading ? null : _saveLessonToFirebase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: Text(
                                'Kaydet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
