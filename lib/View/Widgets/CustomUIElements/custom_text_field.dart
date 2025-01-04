import 'package:education/Core/Constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Color color;
  final bool hasPasswordLine;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.hasPasswordLine = false,
    this.obscureText = false,
    this.color = AppColors.primary,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool passwordIsHide = true;

  void showPassword() {
    setState(() {
      passwordIsHide = !passwordIsHide;
    });
  }

  @override
  Widget build(BuildContext context) {

      double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 50,
      child: TextField(
        controller: widget.controller,
        cursorColor: AppColors.activeChoose,
        style: TextStyle(
          color: Colors.black, 
          fontSize: width < 380 ? 15 : 16 , 
        ),
        decoration: InputDecoration(
          
          filled: true,
          fillColor: widget.color,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.inter(
              fontSize: width < 380 ? 15 : 16,
              fontWeight: FontWeight.w500,
              color: AppColors.subTitleText,
            ),
          suffixIcon: widget.hasPasswordLine
              ? GestureDetector(
                  onTap: showPassword,
                  child: passwordIsHide
                      ? const Icon(
                          Icons.lock_outline,
                          color: AppColors.subTitleText,
                        )
                      : const Icon(
                          Icons.lock_open_outlined,
                          color: AppColors.subTitleText,
                        ),
                )
              :  null , 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
        ),
        obscureText: passwordIsHide ? widget.obscureText : !widget.obscureText,
      ),
    );
  }
}
