import 'package:aushbh/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:aushbh/widgets/bottom_nav_bar.dart';
import 'edit_account_screen.dart';
import 'user_guide_screen.dart';

/// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _green = Color(0xFF2E774F);
  static const Color _greenDark = Color(0xFF256B46);
  bool _isProcessing = false;

  /// ---------------------------
  /// Stream المستخدم
  /// ---------------------------
  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  /// ---------------------------
  /// تسجيل الخروج
  /// ---------------------------
  Future<void> _logout(BuildContext context) async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تسجيل الخروج: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// ---------------------------
  /// حذف الحساب
  /// ---------------------------
  Future<void> _deleteAccount(BuildContext context, String? profileUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await _confirmDelete(context);
    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      // حذف صورة الملف الشخصي من Storage
      if (profileUrl != null) {
        final ref = FirebaseStorage.instance.refFromURL(profileUrl);
        await ref.delete().catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حذف صورة الملف الشخصي: $e'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        });
      }

      // حذف بيانات المستخدم من Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // حذف الحساب من Firebase Authentication
      await user.delete();

      // الانتقال لصفحة تسجيل الدخول
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى تسجيل الدخول مرة أخرى لحذف الحساب'),
            backgroundColor: Colors.red,
          ),
        );
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حذف الحساب: ${e.message}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// ---------------------------
  /// نافذة تأكيد الحذف
  /// ---------------------------
  Future<bool?> _confirmDelete(BuildContext context) async {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final iconSize = (base * 0.12).clamp(44.0, 64.0);
    final titleSize = (base * 0.05).clamp(16.0, 22.0);
    final textSize = (base * 0.042).clamp(14.0, 18.0);

    return showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Column(
            children: [
              Icon(Icons.delete_forever_rounded,
                  size: iconSize, color: Colors.red.shade900),
              const SizedBox(height: 16),
              Text(
                'تأكيد حذف الحساب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: titleSize,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
          content: Text(
            'سيتم حذف الحساب وجميع البيانات المرتبطة به نهائيًا. لا يمكن التراجع عن هذه العملية.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: textSize, height: 1.5, color: Colors.black87),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('إلغاء',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('حذف نهائي',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------------------
  /// واجهة المستخدم
  /// ---------------------------
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final titleSize = (base * 0.045).clamp(16.0, 20.0);
    final avatarR = (base * 0.16).clamp(48.0, 72.0);
    final avatarIcon = (avatarR * 1.08).clamp(48.0, 78.0);
    final nameSize = (base * 0.05).clamp(18.0, 22.0);
    final subSize = (base * 0.038).clamp(12.0, 14.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                'الإعدادات',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _greenDark,
                    fontSize: titleSize),
              ),
            ),
            body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _userStream(),
              builder: (context, snapshot) {
                String name = 'الاسم';
                String username = 'username';
                String? profileUrl;
                String email =
                    FirebaseAuth.instance.currentUser?.email ?? 'user@example.com';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data()!;
                  name = data['name'] ?? name;
                  username = data['username'] ?? username;
                  profileUrl = data['profileImage'];
                }

                return ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all((base * 0.05).clamp(14.0, 20.0)),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: avatarR,
                            backgroundColor: const Color(0xFFE7F2EC),
                            backgroundImage: profileUrl != null
                                ? NetworkImage(profileUrl)
                                : null,
                            child: profileUrl == null
                                ? Icon(Icons.person,
                                    color: _green, size: avatarIcon)
                                : null,
                          ),
                          SizedBox(width: (base * 0.05).clamp(14.0, 20.0)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: TextStyle(
                                      fontSize: nameSize,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(username,
                                  style: TextStyle(
                                      fontSize: subSize, color: Colors.black54)),
                            ],
                          )
                        ],
                      ),
                    ),
                    _SectionCard(
                      title: 'الحساب',
                      children: [
                        _SettingTile(
                          title: 'تعديل معلومات الحساب',
                          icon: Icons.person_outline,
                          onTap: (ctx) =>
                              Navigator.pushNamed(ctx, EditAccountScreen.routeName),
                          highlight: true,
                        ),
                      ],
                    ),
                    _SectionCard(
                      title: 'المساعدة',
                      children: [
                        _SettingTile(
                          title: 'التواصل مع الدعم الفني',
                          icon: Icons.email_outlined,
                          onTap: (ctx) => EmailService.openEmailClient(context: ctx),
                        ),
                        _SettingTile(
                          title: 'دليل المستخدم',
                          icon: Icons.article_outlined,
                          onTap: (ctx) =>
                              Navigator.pushNamed(ctx, UserGuideScreen.routeName),
                        ),
                      ],
                    ),
                    _SectionCard(
                      title: 'الأمان والجلسة',
                      children: [
                        _SettingTile(
                            title: 'تسجيل الخروج',
                            icon: Icons.logout,
                            onTap: (ctx) => _logout(ctx)),
                        _SettingTile(
                          title: 'حذف الحساب',
                          icon: Icons.person_remove_outlined,
                          destructive: true,
                          onTap: (ctx) => _deleteAccount(ctx, profileUrl),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 3),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

/// ---------------------------
/// ويدجت لعرض أقسام الإعدادات بشكل كروت
/// ---------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final cardRadius = (base * 0.04).clamp(14.0, 20.0);
    final titleSize = (base * 0.04).clamp(14.0, 18.0);

    return Padding(
      padding: EdgeInsets.all((base * 0.035).clamp(10.0, 16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                  fontSize: titleSize)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Column(children: _withDividers(children)),
          ),
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(const Divider(
            height: 1, color: Color(0xFFF0F0F0), indent: 16, endIndent: 16));
      }
    }
    return out;
  }
}

/// ---------------------------
/// عنصر فردي في الإعدادات (Tile)
/// ---------------------------
class _SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool destructive;
  final bool highlight;
  final void Function(BuildContext) onTap;

  const _SettingTile(
      {required this.title,
      required this.icon,
      required this.onTap,
      this.destructive = false,
      this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final iconSize = (base * 0.06).clamp(18.0, 22.0);
    final containerSize = (base * 0.11).clamp(38.0, 46.0);
    final fontSize = (base * 0.042).clamp(14.0, 17.0);

    final iconBg = destructive
        ? Colors.red.shade100
        : (highlight ? const Color(0xFFE7F2EC) : const Color(0xFFF2F6F4));
    final iconColor = destructive ? Colors.red.shade900 : const Color(0xFF2E774F);

    return ListTile(
      leading: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          color: destructive ? Colors.red.shade900 : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: () => onTap(context),
    );
  }
}

