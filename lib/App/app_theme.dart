import 'package:education/Core/Constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Renk paleti
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.green;
  static const Color dangerColor = Colors.red;

  static final TextStyle textStyle24Bold = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.headTitleText
  );

  static final TextStyle textStyle16Normal = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.subTitleText
  );


  static final TextStyle textStyle16Medium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.subTitleText
  );

  static final TextStyle textStyle14Normal = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle textStyle16SemiBold = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.activeChoose
  );

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: dangerColor,
    ),

    textTheme: TextTheme(
      headlineLarge: textStyle24Bold, 
      bodyLarge: textStyle16Normal, 
      bodyMedium: textStyle14Normal, 
      titleMedium: textStyle16SemiBold,
      titleSmall: textStyle16Medium,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, 
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}
