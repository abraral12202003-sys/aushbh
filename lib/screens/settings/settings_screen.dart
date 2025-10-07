import 'package:aushbh/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'edit_account_screen.dart';
import 'user_guide_screen.dart';
import 'package:aushbh/services/email_service.dart';

/// شاشة الإعدادات الرئيسية
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static const routeName = '/settings';

  /// ألوان معتمدة للتصميم
  static const Color _green = Color(0xFF2E774F);
  static const Color _greenDark = Color(0xFF256B46);

  /// نافذة تأكيد الحذف مع تصميم مخصص
  Future<void> _confirmDelete(BuildContext context) async {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);

    final iconSize = (base * 0.12).clamp(44.0, 64.0);
    final titleSize = (base * 0.05).clamp(16.0, 22.0);
    final textSize = (base * 0.042).clamp(14.0, 18.0);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),

          /// محتوى النافذة
          title: Column(
            children: [
              Icon(Icons.delete_forever_rounded, size: iconSize, color: Colors.red.shade900),
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
            style: TextStyle(fontSize: textSize, height: 1.5, color: Colors.black87),
          ),

          /// أزرار الإجراءات (إلغاء / حذف)
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('إلغاء', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('حذف نهائي', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm == true && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  /// تسجيل الخروج
  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  /// بناء واجهة الإعدادات
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
      child: Scaffold(
        backgroundColor: Colors.white,

        /// شريط العنوان
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'الإعدادات',
            style: TextStyle(fontWeight: FontWeight.w800, color: _greenDark, fontSize: titleSize),
          ),
        ),

        /// محتوى الشاشة (القوائم)
        body: ListView(
          children: [
            /// رأس الصفحة (اسم المستخدم والصورة)
            Padding(
              padding: EdgeInsets.all((base * 0.05).clamp(14.0, 20.0)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: avatarR,
                    backgroundColor: const Color(0xFFE7F2EC),
                    child: Icon(Icons.person, color: _green, size: avatarIcon),
                  ),
                  SizedBox(width: (base * 0.05).clamp(14.0, 20.0)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name', style: TextStyle(fontSize: nameSize, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('username', style: TextStyle(fontSize: subSize, color: Colors.black54)),
                    ],
                  )
                ],
              ),
            ),

            /// قسم الحساب
            _SectionCard(
              title: 'الحساب',
              children: [
                _SettingTile(
                  title: 'تعديل معلومات الحساب',
                  icon: Icons.person_outline,
                  onTap: (ctx) => Navigator.pushNamed(ctx, EditAccountScreen.routeName),
                  highlight: true,
                ),
              ],
            ),

            /// قسم المساعدة
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
                  onTap: (ctx) => Navigator.pushNamed(ctx, UserGuideScreen.routeName),
                ),
              ],
            ),

            /// قسم الأمان والجلسة
            _SectionCard(
              title: 'الأمان والجلسة',
              children: [
                _SettingTile(title: 'تسجيل الخروج', icon: Icons.logout, onTap: (ctx) => _logout(ctx)),
                _SettingTile(title: 'حذف الحساب', icon: Icons.person_remove_outlined, destructive: true, onTap: (ctx) => _confirmDelete(ctx)),
              ],
            ),
          ],
        ),

        /// شريط التنقل السفلي
        bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      ),
    );
  }
}

/// ويدجت لعرض أقسام الإعدادات بشكل كروت
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
          /// عنوان القسم
          Text(title, style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: titleSize)),
          const SizedBox(height: 6),

          /// الكارد الخاص بالعناصر
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

  /// إضافة فواصل بين العناصر
  List<Widget> _withDividers(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(const Divider(height: 1, color: Color(0xFFF0F0F0), indent: 16, endIndent: 16));
      }
    }
    return out;
  }
}

/// عنصر فردي في الإعدادات (Tile)
class _SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool destructive;
  final bool highlight;
  final void Function(BuildContext) onTap;

  const _SettingTile({required this.title, required this.icon, required this.onTap, this.destructive = false, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final iconSize = (base * 0.06).clamp(18.0, 22.0);
    final containerSize = (base * 0.11).clamp(38.0, 46.0);
    final fontSize = (base * 0.042).clamp(14.0, 17.0);

    final iconBg = destructive ? Colors.red.shade100 : (highlight ? const Color(0xFFE7F2EC) : const Color(0xFFF2F6F4));
    final iconColor = destructive ? Colors.red.shade900 : const Color(0xFF2E774F);

    return ListTile(
      /// أيقونة على اليسار
      leading: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: iconColor),
      ),

      /// عنوان العنصر
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          color: destructive ? Colors.red.shade900 : Colors.black87,
        ),
      ),

      /// سهم صغير يمين
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),

      /// عند الضغط
      onTap: () => onTap(context),
    );
  }
}
