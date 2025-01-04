// registration_helper.dart

import 'package:flutter/material.dart';

class LoginAndRegisterHelper {

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade200,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade200,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static bool areRegisterFieldsEmpty({
    required TextEditingController nameAndSurnameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController passwordIsCorrectController,
  }) {
    return nameAndSurnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordIsCorrectController.text.isEmpty;
  }

  static bool areLoginFieldsEmpty({
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    return emailController.text.isEmpty || passwordController.text.isEmpty;
  }

  static void dismissDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void clearRegisterFields({
    required TextEditingController nameAndSurnameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController passwordIsCorrectController,
  }) {
    nameAndSurnameController.clear();
    emailController.clear();
    passwordController.clear();
    passwordIsCorrectController.clear();
  }


  static void clearLoginFields({
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    passwordController.clear();
    emailController.clear();
  }
}
