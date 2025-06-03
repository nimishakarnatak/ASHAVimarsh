import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSend() {
    if (_messageController.text.trim().isNotEmpty) {
      // Here you would typically handle sending the message
      // For now, we'll just clear the input
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
     // Add background color to the entire column
      children: [
        Expanded(
          child: Container(
          color: AppColors.lightGrey,
            child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(14),
            children: [
              ChatBubble(
                message: 'I have a case of a child with high fever and rash. Could this with measles? What should I look to confirm?',
                isUser: true,
              ),
              _buildSearchStatistics(),
              _buildMeaslesResponse(),
              _buildRelatedQuestions(),
              // Add some space at the bottom for better scrolling
              const SizedBox(height: 20),
            ],
          ),
          ),
        ),
        ChatInput(
          controller: _messageController,
          onSend: _handleSend,
        ),
      ],
    );
  }

  Widget _buildSearchStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 52),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        border: Border.all(color: AppColors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        '23 other ASHAs searched about measles this month',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.green,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMeaslesResponse() {
    return ChatBubble(
      message: '''ASHA Vimarsh
Key signs of measles include:
• High fever (often >104 F/40C)
• Red, blotchy rash starting on face
• Koplik's spots (tiny white spots inside mouth)
• Red, watery eyes
• Cough, runny nose''',
      extraContent: _buildSourceInfo(),
    );
  }

  Widget _buildSourceInfo() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        border: Border.all(color: AppColors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/info_icon.png',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 3),
              const Text(
                'Sources: ASHA Module 7, Page 43\nMinistry Guidelines (2023)',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 7),
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF9FCFFF),
              border: Border.all(color: AppColors.blue),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              'View Source',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedQuestions() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 70,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Related Questions',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _buildQuestionItem('How is measles prevented?'),
        _buildQuestionItem('What is the incubation period for measles?'),
        _buildQuestionItem('When is a child no longer contagious?'),
      ],
    );
  }

  Widget _buildQuestionItem(String question) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(question),
    );
  }
}
