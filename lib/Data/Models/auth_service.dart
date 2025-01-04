import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign In Function
  Future<String?> signInWithEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Kullanıcı bulunamadı.';
      } else if (e.code == 'invalid-credential') {
        return 'Parola ya da e-posta yanlış.';
      } else if (e.code == 'invalid-email') {
        return 'Geçersiz bir e-posta adresi girdiniz.';
      } else {
        return 'Bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      return 'Bilinmeyen bir hata oluştu.';
    }
  }

  // Logout Function
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
