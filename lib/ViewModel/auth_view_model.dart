import 'package:education/Data/Models/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  Future<String?> signIn(String email, String password) async {
    String? errorMessage = await _authService.signInWithEmailPassword(email, password);
    if (errorMessage == null) {
      _user = FirebaseAuth.instance.currentUser;
    }
    notifyListeners();
    return errorMessage;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
