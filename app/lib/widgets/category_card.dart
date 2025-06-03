import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final int totalItems;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.items,
    required this.color,
    required this.totalItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 197,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 55,
            color: color,
            alignment: Alignment.center,
            child: Text(
              title,
              style: AppTextStyles.header,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: items
                  .map((item) => Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ))
                  .toList(),
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'View All ($totalItems)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
