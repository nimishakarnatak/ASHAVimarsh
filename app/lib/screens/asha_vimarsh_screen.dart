import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/nav_tab.dart';
import 'chat_screen.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_card.dart';
import '../widgets/chat_bubble.dart';
import 'information_screen.dart';
import 'training_screen.dart';
import 'forum_screen.dart';

class AshaVirmarshScreen extends StatefulWidget {
  const AshaVirmarshScreen({Key? key}) : super(key: key);

  @override
  State<AshaVirmarshScreen> createState() => _AshaVirmarshScreenState();
}

class _AshaVirmarshScreenState extends State<AshaVirmarshScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildNavTabs(),
            Expanded(
              child: _buildCurrentView(),
            ),
          ],
        ),
      ),
      // floatingActionButton: _buildEmergencyFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(70, 11, 70, 29),
      color: AppColors.primary,
      child: const Text(
        'ASHA Vimarsh',
        style: AppTextStyles.header,
      ),
    );
  }

  Widget _buildCurrentView() {
    print('Current tab index: $_selectedTabIndex'); // Debug print
    switch (_selectedTabIndex) {
      case 0:
        return Column(
          children: [
            const SizedBox(height: 14),
            // SearchBarCust(
            //   controller: _searchController,
            //   onSearch: () {},
            // ),
            const Expanded(
              child: ChatScreen(),
            ),
          ],
        );
      case 1:
        return const InformationScreen();
      case 2:
        return const ForumScreen();
      case 3:
        return const TrainingScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    print('Initial tab index: $_selectedTabIndex'); // Debug print
  }

  Widget _buildNavTabs() {
    final tabs = ['Chat', 'Information', 'Forum', 'Training'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          tabs.length,
          (index) => NavTab(
            text: tabs[index],
            isSelected: _selectedTabIndex == index,
            onTap: () {
              print('Tapped tab: ${tabs[index]} at index: $index'); // Debug print
              setState(() => _selectedTabIndex = index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return Container(
      color: const Color(0x80D9D9D9),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ChatBubble(
            message: 'I have a case of a child with high fever and rash. Could this with measles? What should I look to confirm?',
            isUser: true,
          ),
          _buildSearchStatistics(),
          _buildMeaslesResponse(),
          _buildRelatedQuestions(),
        ],
      ),
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

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: AppTextStyles.categoryTitle,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryCard(
                title: 'Maternal Help',
                items: const [
                  'Postnatal Care',
                  'Breastfeeding',
                  'Maternal Nutrition',
                ],
                color: AppColors.primary,
                totalItems: 15,
              ),
              CategoryCard(
                title: 'Prenatal Health',
                items: const [
                  'Prenatal Visits',
                  'Nutrition Guidelines',
                  'Risk Identification',
                ],
                color: const Color(0xFF5BCCA8),
                totalItems: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Information',
            style: AppTextStyles.categoryTitle,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.red),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  color: AppColors.red,
                  child: const Text(
                    'Emergency Cases',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildEmergencyItem('Bleeding During Pregnancy', true),
                _buildEmergencyItem('High Fever in Children', false),
                Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9698),
                        border: Border.all(color: AppColors.red),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        'View All (15)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.red),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.white : AppColors.black,
            ),
          ),
          Image.asset(
            'assets/images/arrow_icon.png',
            width: 18,
            height: 17,
          ),
        ],
      ),
    );
  }

  // Widget _buildEmergencyFAB() {
  //   return Container(
  //     width: 41,
  //     height: 41,
  //     decoration: const BoxDecoration(
  //       shape: BoxShape.circle,
  //       color: AppColors.red,
  //     ),
  //     child: const Center(
  //       child: Text(
  //         '!',
  //         style: TextStyle(
  //           color: AppColors.white,
  //           fontSize: 20,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
