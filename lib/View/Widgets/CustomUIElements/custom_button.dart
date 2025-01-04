import 'package:education/Core/Constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String ? path;
  final void Function()? onTap;
  final bool isThereIcon;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    required this.isThereIcon,
    required this.color,
    this.path,
  });

  @override
  Widget build(BuildContext context) {
    
    double width = MediaQuery.sizeOf(context).width;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        overlayColor: Colors.transparent,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: Size(width, 50),
      ),
      child: isThereIcon
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  path!,
                  width: width < 380 ? 22 : 25,
                  height: width < 380 ? 22 : 25,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: width < 380 ? 15 : 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.headTitleText,
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: width < 380 ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }
}
