import 'dart:async';
import 'package:aushbh/screens/herb/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aushbh/screens/main/favorites_screen.dart';
import 'package:aushbh/screens/main/search_screen.dart';
import 'package:aushbh/screens/settings/settings_screen.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

// الألوان الهادئة الموحدة
const Color _gentleGreen = Color(0xFF5D9C59);
const Color _whiteBackground = Colors.white;
const Color _softGreenAccent = Color(0xFFADC2A9);
const Color _darkText = Color(0xFF333333);
const Color _lightText = Color(0xFF666666);
const Color _cardColor = Colors.white;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasInternet = true;
  Timer? _internetTimer;

  @override
  void initState() {
    super.initState();
    _startInternetMonitoring();
  }

  @override
  void deactivate() {
    _internetTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _internetTimer?.cancel();
    super.dispose();
  }

  Future<bool> _checkInternet() async {
    try {
      final response =
          await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _startInternetMonitoring() {
    _internetTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final connected = await _checkInternet();
      if (!mounted) return;
      if (_hasInternet != connected) {
        setState(() => _hasInternet = connected);
      }
    });
    _checkInternetAndSetState();
  }

  Future<void> _checkInternetAndSetState() async {
    final connected = await _checkInternet();
    if (!mounted) return;
    setState(() => _hasInternet = connected);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("لا يوجد مستخدم مسجل الدخول")),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _whiteBackground,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            if (!_hasInternet) {
              return _buildNoInternetView(_checkInternetAndSetState);
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _gentleGreen));
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            final userName = data['name'] ?? 'مستخدم';
            final userProfileImage = data['profileImage'];

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildWelcomeSection(userName, userProfileImage),
                    const SizedBox(height: 30),
                    _buildCameraCard(context),
                    const SizedBox(height: 40),
                    _buildFeaturesGrid(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoInternetView(VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 25),
            const Text(
              "أنت غير متصل بالإنترنت",
              style: TextStyle(fontSize: 22, color: _darkText, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "يرجى التحقق من اتصالك وإعادة المحاولة.",
              style: TextStyle(fontSize: 16, color: _lightText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("إعادة المحاولة",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gentleGreen,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(String userName, String? userProfileImage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _softGreenAccent.withOpacity(0.3),
            child: userProfileImage != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userProfileImage,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(color: _gentleGreen, strokeWidth: 2)),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.person, size: 30, color: _gentleGreen),
                    ),
                  )
                : const Icon(Icons.person, size: 30, color: _gentleGreen),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "أهلاً بك، $userName",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: _darkText),
              ),
              const SizedBox(height: 4),
              const Text(
                "استكشف عالم الأعشاب المجففة",
                style: TextStyle(fontSize: 14, color: _lightText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// تم تعديل الكود هنا لفتح CameraScreen
  Widget _buildCameraCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_hasInternet) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CameraScreen()),
        );
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: _gentleGreen.withOpacity(0.85),
          boxShadow: [
            BoxShadow(
              color: _gentleGreen.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.white, size: 55),
              SizedBox(height: 10),
              Text(
                "التقط صورة عشبة",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                "لتحديد اسمها واستخداماتها",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            "وظائف التطبيق",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _darkText),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFeatureCard(
              title: "المفضلة",
              subtitle: "أعشابك المحفوظة",
              icon: Icons.favorite_border_rounded,
              color: Colors.pink.shade300,
              onTap: () => Navigator.pushNamed(context, FavoritesScreen.routeName),
            ),
            _buildFeatureCard(
              title: "البحث",
              subtitle: "عن الأعشاب بالاسم",
              icon: Icons.search_rounded,
              color: Colors.blue.shade300,
              onTap: () => Navigator.pushNamed(context, SearchScreen.routeName),
            ),
            _buildFeatureCard(
              title: "الإعدادات",
              subtitle: "إدارة حسابك وتفضيلاتك",
              icon: Icons.settings_outlined,
              color: Colors.grey.shade500,
              onTap: () async => await Navigator.pushNamed(context, SettingsScreen.routeName),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            border: Border(
              right: BorderSide(color: color.withOpacity(0.7), width: 4),
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16, color: _darkText),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: _lightText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
