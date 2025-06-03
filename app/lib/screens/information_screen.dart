import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/category_card.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategories(),
          _buildEmergencySection(),
        ],
      ),
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
}
