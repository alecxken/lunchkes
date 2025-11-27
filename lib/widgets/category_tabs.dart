// lib/widgets/category_tabs.dart
import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final TabController controller;

  const CategoryTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFBED600), Color(0xFF669438)],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBED600).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(icon: Icon(Icons.person, size: 20), text: 'Staff'),
          Tab(icon: Icon(Icons.engineering, size: 20), text: 'Contract'),
          Tab(icon: Icon(Icons.people, size: 20), text: 'Visitor'),
        ],
      ),
    );
  }
}
