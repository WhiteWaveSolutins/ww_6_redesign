import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:scan_doc/ui/resurses/colors.dart';


class CustomizeWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  
  const CustomizeWidget({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.surfaceDark.withOpacity(0.5),
                border: Border.all(
                  color: AppColors.textPrimary.withOpacity(0.1),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class CustomizeIcon extends StatelessWidget {
  final IconData icon;
  
  const CustomizeIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surfaceDark.withOpacity(0.5),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.1),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}