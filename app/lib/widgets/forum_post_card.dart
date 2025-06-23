// lib/widgets/forum_post_card.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/question.dart';

class ForumPostCard extends StatelessWidget {
  final Question question;
  final VoidCallback? onTap;
  final Function(int)? onVote; // 1 for upvote, -1 for downvote
  final VoidCallback? onComment;

  const ForumPostCard({
    Key? key,
    required this.question,
    this.onTap,
    this.onVote,
    this.onComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user info and timestamp
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          question.author.username.isNotEmpty 
                              ? question.author.username[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    question.author.username,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(question.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Verification badges
                            Row(
                              children: [
                                if (question.author.isModerator)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (question.isClosed) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Closed',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Question title
                  Text(
                    question.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Question content (truncated)
                  Text(
                    question.content.length > 150
                        ? '${question.content.substring(0, 150)}...'
                        : question.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      height: 1.4,
                    ),
                  ),
                  
                  // Tags
                  if (question.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: question.tags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            // Action bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.grey.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  // Upvote button
                  _buildInteractionButton(
                    icon: Icons.thumb_up_outlined,
                    label: question.upvotes.toString(),
                    onTap: onVote != null ? () => onVote!(1) : null,
                    color: Colors.green,
                  ),
                  
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.grey.withOpacity(0.2),
                  ),
                  
                  // Downvote button
                  _buildInteractionButton(
                    icon: Icons.thumb_down_outlined,
                    label: question.downvotes.toString(),
                    onTap: onVote != null ? () => onVote!(-1) : null,
                    color: Colors.red,
                  ),
                  
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.grey.withOpacity(0.2),
                  ),
                  
                  // Comments button
                  _buildInteractionButton(
                    icon: Icons.chat_bubble_outline,
                    label: question.answerCount.toString(),
                    onTap: onComment ?? onTap,
                  ),
                  
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.grey.withOpacity(0.2),
                  ),
                  
                  // Net score
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 16,
                            color: question.netVotes >= 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${question.netVotes >= 0 ? '+' : ''}${question.netVotes}',
                            style: TextStyle(
                              color: question.netVotes >= 0 ? Colors.green : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: color ?? AppColors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color ?? AppColors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks == 1 ? '' : 's'} ago';
      } else {
        final months = (difference.inDays / 30).floor();
        return '$months month${months == 1 ? '' : 's'} ago';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}