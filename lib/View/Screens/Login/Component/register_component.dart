// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/Helper/login_register_helper.dart';
import 'package:education/View/Widgets/CustomUIElements/custom_button.dart';
import 'package:education/View/Widgets/CustomUIElements/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? _selectedRole = 'Öğrenci';

  TextEditingController nameAndSurnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordIsCorrectController = TextEditingController();

  @override
  void dispose() {
    nameAndSurnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordIsCorrectController.dispose();
    super.dispose();
  }

  void registerUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
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
          'profilePhoto': 'Pp gelecek',
          'alınan_dersler': [], 
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 26),
              child: CustomTextField(
                hintText: 'Ad Soyad',
                obscureText: false,
                controller: nameAndSurnameController,
                hasPasswordLine: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CustomTextField(
                hintText: 'E-posta',
                obscureText: false,
                controller: emailController,
                hasPasswordLine: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CustomTextField(
                hintText: 'Parola',
                obscureText: true,
                controller: passwordController,
                hasPasswordLine: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CustomTextField(
                hintText: 'Parola Tekrar',
                obscureText: true,
                controller: passwordIsCorrectController,
                hasPasswordLine: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                height: 50,
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  isExpanded: true,
                  value: _selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  items: <String>['Öğrenci', 'Öğretmen']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: GoogleFonts.inter(
                            color: AppColors.subTitleText,
                            fontSize: width < 380 ? 15 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: RichText(
                    text: TextSpan(
                      text: "Kayıt Ol'a basarak ",
                      style: GoogleFonts.inter(
                        color: AppColors.lightGray,
                        fontSize: width < 380 ? 13 : 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: "Üyelik Koşullarını",
                          style: GoogleFonts.inter(
                            color: AppColors.headTitleText,
                            fontSize: width < 380 ? 13 : 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(
                          text: " kabul ediyorum.",
                          style: GoogleFonts.inter(
                            color: AppColors.lightGray,
                            fontSize: width < 380 ? 13 : 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CustomButton(
                onTap: registerUser,
                path: 'assets/icons/education.svg',
                text: 'Kayıt Ol',
                isThereIcon: false,
                color: AppColors.button,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'ya da',
                      style: GoogleFonts.inter(
                        fontSize: width < 380 ? 14 : 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subTitleText,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const CustomButton(
                path: 'assets/icons/google.svg',
                text: 'Google ile kayıt ol',
                isThereIcon: true,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
