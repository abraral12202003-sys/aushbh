import 'package:aushbh/screens/main/favorites_screen.dart';
import 'package:aushbh/screens/main/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:aushbh/screens/auth/signup_screen.dart';
import 'package:aushbh/screens/auth/login_screen.dart';
import 'package:aushbh/screens/main/home_screen.dart';
import 'package:aushbh/screens/settings/edit_account_screen.dart';
import 'package:aushbh/screens/settings/settings_screen.dart';
import 'package:aushbh/screens/settings/user_guide_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //  مؤقتًا: متغير يحدد هل المستخدم مسجل دخول أم لا
  final bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      title: 'عُشبة - تحديد الأعشاب المجففة',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E774F)),
        fontFamily: 'Tajawal',
      ),

      //  التوجيه حسب حالة تسجيل الدخول
      initialRoute: isLoggedIn ? HomeScreen.routeName : LoginScreen.routeName,

      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        SearchScreen.routeName: (_) => const SearchScreen(),
        FavoritesScreen.routeName: (_) => const FavoritesScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        EditAccountScreen.routeName: (_) => const EditAccountScreen(),
        UserGuideScreen.routeName: (_) => const UserGuideScreen()
      },
    );
  }
}
