// search_screen.dart
// المسؤول: مودة
// الغرض: شاشة البحث عن الأعشاب بالاسم أو الاستخدامات

import 'package:flutter/material.dart';
import 'package:aushbh/widgets/bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن الأعشاب'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: const Center(
        child: Text('شاشة البحث - قيد التطوير'),
      ),

      // ✅ شريط التنقل السفلي مع مؤشر البحث
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
