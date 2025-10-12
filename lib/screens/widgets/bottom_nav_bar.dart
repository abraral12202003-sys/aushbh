import 'package:flutter/material.dart';
import 'package:aushbh/screens/main/home_screen.dart';
import 'package:aushbh/screens/settings/settings_screen.dart';
import 'package:aushbh/screens/main/favorites_screen.dart';
import 'package:aushbh/screens/main/search_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

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
