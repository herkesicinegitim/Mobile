// ignore_for_file: use_build_context_synchronously

import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/Helper/login_register_helper.dart';
import 'package:education/View/Widgets/CustomUIElements/custom_button.dart';
import 'package:education/View/Widgets/CustomUIElements/custom_text_field.dart';
import 'package:education/ViewModel/auth_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    

    void signInUser() async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        },
      );

      if (LoginAndRegisterHelper.areLoginFieldsEmpty(
        emailController: emailController,
        passwordController: passwordController,
      )) {
        LoginAndRegisterHelper.dismissDialog(context);
        LoginAndRegisterHelper.showErrorSnackBar(
            context, 'İlgili alanlar boş bırakılamaz.');
        return;
      }

      String? errorMessage = await context
          .read<AuthViewModel>()
          .signIn(emailController.text, passwordController.text);

      Navigator.pop(context);

      if (errorMessage != null) {
        LoginAndRegisterHelper.dismissDialog(context);
        LoginAndRegisterHelper.showErrorSnackBar(context, errorMessage);
      } else {
        LoginAndRegisterHelper.dismissDialog(context);
        LoginAndRegisterHelper.showSuccessSnackBar(context, 'Giriş Başarılı');
        LoginAndRegisterHelper.clearLoginFields(
          emailController: emailController,
          passwordController: passwordController,
        );
      }
    }

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 26, bottom: 12),
                child: CustomTextField(
                  hintText: 'E-posta',
                  obscureText: false,
                  controller: emailController,
                  hasPasswordLine: false,
                ),
              ),
              CustomTextField(
                hintText: 'Parola',
                obscureText: true,
                controller: passwordController,
                hasPasswordLine: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CustomButton(
                    onTap: signInUser,
                    path: 'assets/icons/education.svg',
                    text: 'Giriş Yap',
                    isThereIcon: false,
                    color: AppColors.button),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CustomButton(
                  path: 'assets/icons/google.svg',
                  text: 'Google ile giriş yap',
                  isThereIcon: true,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
