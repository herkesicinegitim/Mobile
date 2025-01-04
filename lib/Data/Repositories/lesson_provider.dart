import 'package:flutter/material.dart';

class LessonProvider with ChangeNotifier {
  List<String> _participants = [];

  List<String> get participants => _participants;

  void addParticipant(String participant) {
    _participants.add(participant);
    notifyListeners(); 
  }

  void removeParticipant(String participant) {
    _participants.remove(participant);
    notifyListeners();
  }
}
