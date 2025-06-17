import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class NavTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const NavTab({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              text,
              style: isSelected ? AppTextStyles.navTabSelected : AppTextStyles.navTab,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 12),
              height: 2,
              width: isSelected ? 75 : 0,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
