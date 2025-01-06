// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Helper/login_register_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterProvider extends ChangeNotifier {
  String? _selectedRole = 'Öğrenci';

  TextEditingController nameAndSurnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordIsCorrectController = TextEditingController();

  String? get selectedRole => _selectedRole;

  void setRole(String? newRole) {
    _selectedRole = newRole;
    notifyListeners();
  }

  void registerUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return  Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );

    if (LoginAndRegisterHelper.areRegisterFieldsEmpty(
        nameAndSurnameController: nameAndSurnameController,
        emailController: emailController,
        passwordController: passwordController,
        passwordIsCorrectController: passwordIsCorrectController)) {
      LoginAndRegisterHelper.dismissDialog(context);
      LoginAndRegisterHelper.showErrorSnackBar(
          context, 'İlgili alanlar boş bırakılamaz.');
      return;
    }

    if (passwordController.text != passwordIsCorrectController.text) {
      Navigator.pop(context);
      LoginAndRegisterHelper.showErrorSnackBar(
          context, 'Parolalar eşleşmiyor!');
    } else {
      try {
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        createUserDocument(userCredential);

        LoginAndRegisterHelper.dismissDialog(context);
        LoginAndRegisterHelper.showSuccessSnackBar(context, 'Kayıt oldunuz');
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        switch (e.code) {
          case 'email-already-in-use':
            LoginAndRegisterHelper.showErrorSnackBar(
                context, 'Bu e-posta adresi zaten kullanılıyor.');
            break;
          case 'invalid-email':
            LoginAndRegisterHelper.showErrorSnackBar(
                context, 'Geçersiz bir e-posta adresi girdiniz.');
            break;
          case 'weak-password':
            LoginAndRegisterHelper.showErrorSnackBar(
                context, 'Şifre çok zayıf. Daha güçlü bir şifre seçin.');
            break;
          case 'operation-not-allowed':
            LoginAndRegisterHelper.showErrorSnackBar(
                context, 'Bu işlem şu anda devre dışı.');
            break;
          default:
            LoginAndRegisterHelper.showErrorSnackBar(
                context, 'Bir hata oluştu: ${e.message}');
        }
      } catch (e) {
        Navigator.pop(context);
        LoginAndRegisterHelper.showErrorSnackBar(
            context, 'Beklenmeyen bir hata oluştu: $e');
      }
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set(
        {
          'fullName': nameAndSurnameController.text,
          'email': emailController.text,
          'role': _selectedRole,
          'weeklyCount': 5,
          'alınan_dersler': [], 
        },
      );
    }
  }

  void disposeControllers() {
    nameAndSurnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordIsCorrectController.dispose();
    super.dispose();
  }
}
