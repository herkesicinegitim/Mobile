import 'package:education/ViewModel/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:education/View/Widgets/CustomUIElements/custom_button.dart';
import 'package:education/View/Widgets/CustomUIElements/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:education/Core/Constants/app_colors.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (context) => RegisterProvider(),
      child: Consumer<RegisterProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
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
                      controller: provider.nameAndSurnameController,
                      hasPasswordLine: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CustomTextField(
                      hintText: 'E-posta',
                      obscureText: false,
                      controller: provider.emailController,
                      hasPasswordLine: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CustomTextField(
                      hintText: 'Parola',
                      obscureText: true,
                      controller: provider.passwordController,
                      hasPasswordLine: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CustomTextField(
                      hintText: 'Parola Tekrar',
                      obscureText: true,
                      controller: provider.passwordIsCorrectController,
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
                        value: provider.selectedRole,
                        onChanged: (String? newValue) {
                          provider.setRole(newValue);
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
                      onTap: () => provider.registerUser(context),
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
        },
      ),
    );
  }
}



