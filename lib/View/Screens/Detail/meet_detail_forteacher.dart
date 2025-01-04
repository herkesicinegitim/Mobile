import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}