// result_screen.dart
// المسؤول: ريما
// الغرض: شاشة عرض نتيجة تحليل العشبة
//
// ⬅️ هذه الشاشة مرتبطة بميزة "Identify Herb – Result"
//    كما هو موضح في التقرير (SRS: القسم 3.4.4 و 3.4.5، وتصميم الواجهات 4.3).
//
// ملاحظة هامة: 
// 📌 الصورة التي تُعرض هنا ليست صورة المستخدم، بل صورة قياسية من فريق التطوير 
//    مأخوذة من قاعدة بيانات (Dataset) خاصة بالأعشاب المجففة.
// ❌ صورة المستخدم تُستخدم مؤقتًا فقط للتحليل في CameraScreen.

import 'package:flutter/material.dart';
// import '../../models/herb_model.dart';

class ResultScreen extends StatefulWidget {
  // final DriedHerb identifiedHerb;   // يحتوي على بيانات العشبة + رابط الصورة القياسية
  // final double confidence;

  // const ResultScreen({
  //   Key? key,
  //   required this.identifiedHerb,
  //   required this.confidence,
  // }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // ════════════════════════════════════════
  // المتغيرات (State)
  // ════════════════════════════════════════
  // bool _isAddingToFavorites = false;   // حالة عند الإضافة
  // bool _isAlreadyFavorite = false;     // هل العشبة موجودة مسبقًا بالمفضلة

  @override
  Widget build(BuildContext context) {
    // ✅ مكونات الشاشة كما في التقرير:
    // 1. AppBar بعنوان "نتيجة التحليل"
    // 2. صورة العشبة (من الداتا ست)
    // 3. اسم العشبة + نسبة الثقة
    // 4. الاستخدامات الطبية
    // 5. الاستخدامات في الطبخ
    // 6. زر "إضافة إلى المفضلة"
    // 7. زر "تجربة صورة أخرى"

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة التحليل'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: const Center(
        child: Text('📊 شاشة النتيجة - الهيكل فقط (بحسب التقرير)'),
      ),
    );
  }

  // ════════════════════════════════════════
  // مكون لإظهار البطاقات (الاستخدامات الطبية / الطبخ)
  // ════════════════════════════════════════
  // Widget _infoCard(String title, String content) { ... }

  // ════════════════════════════════════════
  // دالة إضافة للمفضلة
  // ════════════════════════════════════════
  // Future<void> _addToFavorites() async { ... }

  // ════════════════════════════════════════
  // دالة تجربة صورة أخرى
  // ════════════════════════════════════════
  // void _tryAnotherImage() {
  //   Navigator.pop(context); // العودة إلى CameraScreen
  // }
}
