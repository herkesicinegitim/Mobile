import 'package:education/Core/Constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDialog {
  static void displayMessageToUser(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uyarı',
                  style: GoogleFonts.inter(
                    color: AppColors.headTitleText,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Icon(
                  Icons.info,
                  size: 28,
                  color: AppColors.activeChoose,
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              message,
              style: GoogleFonts.inter(
                color: AppColors.headTitleText,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Tamam',
              style: GoogleFonts.inter(
                color: AppColors.activeChoose,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
