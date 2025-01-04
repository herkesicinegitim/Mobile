import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  final String title;
  final Timestamp startTime;
  final Timestamp endTime;
  final String googleMeetLink;
  final String lessonType;
  final String creator;
  final List<String> participants;
  final Timestamp day; // Timestamp for the lesson day

  Lesson({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.googleMeetLink,
    required this.lessonType,
    required this.creator,
    required this.participants,
    required this.day, // Initialize Timestamp for day
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      title: map['title'] ?? 'Ders Adı Yok',
      startTime: map['startTime'] is Timestamp
          ? map['startTime'] as Timestamp
          : Timestamp.fromDate(DateTime.now()), // Default to current time
      endTime: map['endTime'] is Timestamp
          ? map['endTime'] as Timestamp
          : Timestamp.fromDate(DateTime.now()), // Default to current time
      googleMeetLink: map['googleMeetLink'] ?? 'https://meet.jit.si/default_room',
      lessonType: map['lessonType'] ?? 'Ders Tipi Yok',
      creator: map['creator'] ?? 'Oluşturucu Yok',
      participants: (map['dersi_alanlar'] as List)
          .map((item) => item['fullName'] as String)
          .toList(),
      day: map['date'] is Timestamp
          ? map['date'] as Timestamp
          : Timestamp.fromDate(DateTime.now()), // Default to current time
    );
  }
}
