import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class ForumPost extends StatelessWidget {
  final String avatar;
  final String userName;
  final String timestamp;
  final String title;
  final String content;

  const ForumPost({
    Key? key,
    required this.avatar,
    required this.userName,
    required this.timestamp,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                ),
                alignment: Alignment.center,
                child: Text(
                  avatar,
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 0),
                        Text(
                          timestamp,
                          style: AppTextStyles.timestamp,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: AppTextStyles.userName,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: AppTextStyles.userName.copyWith(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 21),
            child: Text(
              content,
              style: AppTextStyles.postContent,
            ),
          ),
        ],
      ),
    );
  }
}
