import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SearchBarCust extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const SearchBarCust({
    Key? key,
    required this.controller,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.grey),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search Knowledge Base...',
          hintStyle: const TextStyle(
            color: AppColors.grey,
            fontSize: 15,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onSubmitted: (_) => onSearch(),
      ),
    );
  }
}
