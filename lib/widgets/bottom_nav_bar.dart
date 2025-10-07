import 'package:flutter/material.dart';
import 'package:aushbh/screens/main/home_screen.dart';
import 'package:aushbh/screens/main/search_screen.dart';
import 'package:aushbh/screens/main/favorites_screen.dart';
import 'package:aushbh/screens/settings/settings_screen.dart';

/// ويدجت شريط التنقل السفلي
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  /// ألوان العناصر المختارة وغير المختارة
  static const Color _kSelectedGreen = Color(0xFF388E3C); 
  static const Color _kUnselectedColor = Color(0xFF757575); 

  /// دالة للتنقل بين الشاشات
  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, SearchScreen.routeName);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, FavoritesScreen.routeName);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, SettingsScreen.routeName);
        break;
    }
  }

  /// تصميم واجهة الشريط السفلي
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, 
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        currentIndex: currentIndex,

        /// خصائص الشكل
        backgroundColor: Colors.white, 
        elevation: 10, 
        selectedItemColor: _kSelectedGreen,
        unselectedItemColor: _kUnselectedColor,
        showUnselectedLabels: true,
        iconSize: 26, 
        selectedFontSize: 13, 
        unselectedFontSize: 12,

        /// عند الضغط على عنصر
        onTap: (index) => _onItemTapped(context, index),

        /// عناصر شريط التنقل
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            activeIcon: Icon(Icons.home_filled),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), 
            label: 'البحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), 
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), 
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
