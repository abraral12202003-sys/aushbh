// user_guide_screen.dart
// المسؤول: أبرار
// الغرض: شاشة دليل المستخدم والمساعدة

import 'package:flutter/material.dart';

class UserGuideScreen extends StatelessWidget {
  static const routeName = '/user-guide';

  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final cardRadius = (base * 0.04).clamp(14.0, 20.0);
    final titleSize = (base * 0.05).clamp(16.0, 20.0);
    final textSize = (base * 0.042).clamp(14.0, 18.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F8),
        appBar: AppBar(
          title: const Text(
            'دليل المستخدم',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87, 
            ),
          ),
          backgroundColor: Colors.white, 
          elevation: 0, 
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87), 
        ),
        body: ListView(
          padding: EdgeInsets.all((base * 0.05).clamp(16.0, 22.0)),
          children: [
            _buildCard(
              icon: Icons.camera_alt_outlined,
              title: "التقاط أو رفع صورة عشبة",
              content:
                  "من الصفحة الرئيسية، اضغط على زر (التقاط أو رفع صورة).\n"
                  "اختر التقاط صورة بالكاميرا أو رفع صورة من جهازك.\n"
                  "سيتم تحليل الصورة باستخدام الذكاء الاصطناعي لتحديد نوع العشبة وعرض اسمها، صورتها، واستخداماتها.\n"
                  "يمكنك أيضًا الضغط على (أضف إلى المفضلة) لحفظها.",
              cardRadius: cardRadius,
              titleSize: titleSize,
              textSize: textSize,
            ),
            _buildCard(
              icon: Icons.favorite_border,
              title: "المفضلة",
              content:
                  "ستجد قائمة الأعشاب التي قمت بحفظها.\n"
                  "يمكنك حذف أي عشبة من المفضلة عند الحاجة.",
              cardRadius: cardRadius,
              titleSize: titleSize,
              textSize: textSize,
            ),
            _buildCard(
              icon: Icons.search,
              title: "البحث عن عشبة",
              content:
                  "اكتب اسم العشبة في خانة البحث.\n"
                  "سيتم عرض الأعشاب المطابقة ويمكنك الضغط لعرض تفاصيلها واستخداماتها.",
              cardRadius: cardRadius,
              titleSize: titleSize,
              textSize: textSize,
            ),
            _buildCard(
              icon: Icons.settings,
              title: "الإعدادات",
              content:
                  "يمكنك تعديل معلومات الحساب.\n"
                  "التواصل مع الدعم الفني عند وجود مشكلة.\n"
                  "عرض هذا الدليل.\n"
                  "تسجيل الخروج أو حذف الحساب.",
              cardRadius: cardRadius,
              titleSize: titleSize,
              textSize: textSize,
            ),
            _buildCard(
              icon: Icons.info_outline,
              title: "ملاحظات",
              content:
                  "• التطبيق يتطلب اتصالًا بالإنترنت.\n"
                  "• يرجى التأكد من منح صلاحية الكاميرا للتطبيق.",
              cardRadius: cardRadius,
              titleSize: titleSize,
              textSize: textSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String content,
    required double cardRadius,
    required double titleSize,
    required double textSize,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E774F), size: 26),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: titleSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: textSize, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
