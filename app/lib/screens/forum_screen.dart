import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/forum_post.dart';
import '../widgets/comment_item.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const ForumPost(
              avatar: 'A',
              userName: 'ASHA Anjali',
              timestamp: 'Yesterday, 2:45PM',
              title: 'Successful Nutritional Intervention',
              content: 'In Ganeshpur village, I encountered several cases of malnourished children (ages 2-5). Traditional counseling wasn\'t working as mothers were reluctant to change cooking practices.\n\nI organized a community cooking demonstration with locally available ingredients. By showing how to make nutritious khichdi with vegetables and jaggery for taste, 12 families adopted these recipes.\n\nOutcome: After 2 months, 8 children showed gained weight and improve health indicators.',
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Response Actions',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: const Text(
                          'It Worked (7)',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: const Text(
                          'It Didn\'t Worked (1)',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Comments (3)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '+ Add Comment',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            const CommentItem(
              avatar: 'B',
              userName: 'ASHA Bhavna',
              content: 'Could you share the exact recipe you used for the nutritious khichdi? I tried something similar but used moong dal instead. Also, how did you convince the elders in the family who often resist such changes?',
              tag: 'Implementation Details',
              showAlert: false,
            ),
            const SizedBox(height: 11),
            const CommentItem(
              avatar: 'C',
              userName: 'ASHA Chandni',
              content: 'Could you share the exact recipe you used for the nutritious khichdi? I tried something similar but used moong dal instead. Also, how did you convince the elders in the family who often resist such changes?',
              tag: 'General',
              showAlert: false,
            ),
            const SizedBox(height: 29),
          ],
        ),
      ),
    );
  }
}
