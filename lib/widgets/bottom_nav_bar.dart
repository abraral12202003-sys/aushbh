
import 'package:aushbh/screens/main/favorites_screen.dart';
import 'package:aushbh/screens/main/search_screen.dart';
import "package:flutter/material.dart";
import 'package:aushbh/screens/main/home_screen.dart';
import 'package:aushbh/screens/settings/settings_screen.dart';


class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  // دالة التحكم بالتنقل
  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0: // الرئيسية
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        break;
      case 1: // البحث
        _showUnderConstruction(context, SearchScreen.routeName);
        break;
      case 2: // المفضلة
        _showUnderConstruction(context, FavoritesScreen.routeName);
        break;
      case 3: // الإعدادات
        Navigator.pushReplacementNamed(context, SettingsScreen.routeName);
        break;
    }
  }

  // رسالة للشاشات غير الجاهزة
  void _showUnderConstruction(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$feature تحت الإنشاء 🚧")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
        NavigationDestination(icon: Icon(Icons.search), label: 'البحث'),
        NavigationDestination(icon: Icon(Icons.favorite_border), label: 'المفضلة'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ],
    );
  }
}
