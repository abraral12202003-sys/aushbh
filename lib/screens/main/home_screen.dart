import 'package:aushbh/screens/main/favorites_screen.dart';
import 'package:aushbh/screens/main/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:aushbh/screens/settings/settings_screen.dart';

/// شاشة الرئيسية (HomeScreen)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// حالة الشاشة الرئيسية
class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  String? _userName = "مستخدم";
  String? _userProfileImage;

  /// بناء واجهة الشاشة
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildHomeContent(context),
      ),
    );
  }

  /// بناء محتوى الشاشة الرئيسية
  Widget _buildHomeContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            /// قسم الترحيب بالمستخدم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: _userProfileImage != null
                        ? AssetImage(_userProfileImage!)
                        : null,
                    child: _userProfileImage == null
                        ? const Icon(Icons.person, size: 40, color: Colors.green)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "أهلاً بك في عالم الأعشاب 🌿",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      Text(
                        _userName ?? "مستخدم",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// زر التصوير الرئيسي
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ميزة التصوير قيد التطوير 📷")),
                );
              },
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "التقط صورة عشبة",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "لتحديد اسمها واستخداماتها",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// عنوان الوظائف الرئيسية
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "الوظائف الرئيسية",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            /// شبكة الوظائف الرئيسية
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFeatureCard(
                  title: "مفضلاتي",
                  subtitle: "أعشابك المحفوظة",
                  icon: Icons.favorite,
                  color: Colors.pink,
                  onTap: () {
                    Navigator.pushNamed(context, FavoritesScreen.routeName);
                  },
                ),
                _buildFeatureCard(
                  title: "البحث",
                  subtitle: "ابحث عن عشبة",
                  icon: Icons.search,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, SearchScreen.routeName);
                  },
                ),
                _buildFeatureCard(
                  title: "الإعدادات",
                  subtitle: "إدارة التطبيق",
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () {
                    Navigator.pushNamed(context, SettingsScreen.routeName);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة خاصة بالوظائف الرئيسية
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
