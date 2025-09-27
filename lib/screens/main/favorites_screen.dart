// favorites_screen.dart
// المسؤول: مودة
// الغرض: شاشة عرض الأعشاب المفضلة للمستخدم
//
// ⬅️ هذه الشاشة مرتبطة بميزة "View Favorites" و "Remove from Favorites"
//    كما ورد في التقرير (SRS – القسم 3.4.6 و 3.4.7، وتصميم الواجهات 4.3).
//
// المتطلبات من التقرير:
// ╔════════════════════════════════════════════════════════════════╗
// ║ 1. المستخدم يفتح شاشة المفضلات من القائمة الرئيسية             ║
// ║ 2. التطبيق يجلب قائمة الأعشاب المفضلة من Firestore              ║
// ║ 3. عرض قائمة بالأعشاب (اسم + صورة + زر تفاصيل)                 ║
// ║ 4. عند اختيار عنصر ➜ عرض معلومات العشبة كاملة                  ║
// ║ 5. المستخدم يستطيع إزالة عشبة من المفضلة                        ║
// ║ 6. يتم تحديث القائمة في الوقت الفعلي (real-time update)         ║
// ╚════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'package:aushbh/widgets/bottom_nav_bar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  static const routeName = '/favorites';

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // ════════════════════════════════════════
  // المتغيرات (State)
  // ════════════════════════════════════════
  // TODO: List of favorite herbs from Firestore
  // TODO: حالة تحميل (isLoading)
  // TODO: حالة خطأ (errorMessage)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مفضلاتي'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: _buildFavoritesBody(),

      // ✅ إضافة شريط التنقل السفلي مع currentIndex الصحيح
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  // ════════════════════════════════════════
  // واجهة المحتوى (UI)
  // ════════════════════════════════════════
  Widget _buildFavoritesBody() {
    // TODO:
    // - إذا isLoading ➜ إظهار CircularProgressIndicator
    // - إذا خطأ ➜ إظهار رسالة خطأ
    // - إذا لا توجد مفضلات ➜ إظهار رسالة "لا توجد أعشاب مفضلة"
    // - إذا توجد بيانات ➜ ListView.builder لعرض الأعشاب:
    //      • صورة العشبة (من Firestore)
    //      • اسم العشبة
    //      • زر إزالة (🗑️)
    //      • زر لفتح تفاصيل العشبة
    return const Center(
      child: Text('📂 شاشة المفضلة - قيد التطوير'),
    );
  }

  // ════════════════════════════════════════
  // دالة إزالة عشبة من المفضلة
  // ════════════════════════════════════════
  Future<void> _removeFromFavorites(String herbId) async {
    // TODO:
    // - حذف العشبة من Firestore
    // - إظهار SnackBar للتأكيد
    // - تحديث القائمة بعد الحذف
  }

  // ════════════════════════════════════════
  // دالة فتح تفاصيل عشبة
  // ════════════════════════════════════════
  void _openHerbDetails(String herbId) {
    // TODO:
    // - الانتقال إلى HerbDetailScreen مع تمرير herbId
  }
}
