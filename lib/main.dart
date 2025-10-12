import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// استيراد باقي الصفحات
import 'package:aushbh/screens/main/favorites_screen.dart';
import 'package:aushbh/screens/main/search_screen.dart';
import 'package:aushbh/screens/auth/signup_screen.dart';
import 'package:aushbh/screens/auth/login_screen.dart';
import 'package:aushbh/screens/main/home_screen.dart';
import 'package:aushbh/screens/settings/edit_account_screen.dart';
import 'package:aushbh/screens/settings/settings_screen.dart';
import 'package:aushbh/screens/settings/user_guide_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      title: 'عُشبة - لتحديد الأعشاب المجففة',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E774F)),
        fontFamily: 'Tajawal',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      // استخدام StreamBuilder لمتابعة حالة تسجيل الدخول ديناميكياً
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // شاشة انتظار أثناء التحقق من تسجيل الدخول
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.hasData) {
              // المستخدم مسجّل الدخول
              return HomeScreen();
            } else {
              // لم يتم تسجيل الدخول
              return LoginScreen();
            }
          }
        },
      ),
      routes: {
        LoginScreen.routeName: (_) => LoginScreen(),
        SignupScreen.routeName: (_) => SignupScreen(),
        HomeScreen.routeName: (_) => HomeScreen(),
        SearchScreen.routeName: (_) => SearchScreen(),
        FavoritesScreen.routeName: (_) => FavoritesScreen(),
        SettingsScreen.routeName: (_) => SettingsScreen(),
        EditAccountScreen.routeName: (_) => EditAccountScreen(),
        UserGuideScreen.routeName: (_) => UserGuideScreen(),
      },
    );
  }
}
