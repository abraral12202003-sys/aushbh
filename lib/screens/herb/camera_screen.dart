// camera_screen.dart
// المسؤول: ريما
// الغرض: شاشة الكاميرا والتقاط الصور لتحليل الأعشاب
//
// ⬅️ هذه الشاشة مرتبطة بميزة "Identify Herb" المذكورة في التقرير
//    (SRS – القسم 3.4.3 Identify Herb, و تصميم الواجهات في القسم 4.3).
//
// ملاحظة هامة: 
// 📌 الصورة الملتقطة أو المرفوعة تُستخدم بشكل مؤقت فقط لعرضها للمستخدم 
//    ولإرسالها إلى خدمة التحليل (AI Service عبر Firebase Functions).
// ❌ لا يتم حفظها بشكل دائم لا محليًا ولا في قاعدة بيانات (Firestore / Storage).
//
// المتطلبات من التقرير:
// ╔════════════════════════════════════════════════════════════════╗
// ║ 1. المستخدم يلتقط صورة عشبة أو يختارها من المعرض              ║
// ║ 2. يتم إرسال الصورة إلى خدمة الذكاء الاصطناعي (AI Service)     ║
// ║    عبر Firebase Functions لاستخراج نوع العشبة                 ║
// ║ 3. عند نجاح التحليل ➜ فتح ResultScreen مع:                     ║
// ║    • اسم العشبة                                                ║
// ║    •  الاستخدامات في الطب/الطبخ                         ║
// ║ 4. عند فشل التحليل ➜ عرض رسالة خطأ مناسبة                     ║
// ╚════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import '../../services/ai_service.dart';
// import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // TODO: تعريف متغيرات الحالة
  // File? _selectedImage;              // الصورة مؤقتة ❌ لا يتم حفظها
  // final ImagePicker _picker = ImagePicker();
  // bool _isAnalyzing = false;
  // String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // TODO: بناء شاشة الكاميرا
    // ✅ مكونات UI كما في التقرير:
    // - AppBar بعنوان "تصوير العشبة"
    // - إذا لم يتم اختيار صورة ➜ عرض أيقونة + تعليمات + زرين (📷 كاميرا + 🖼️ معرض)
    // - إذا تم اختيار صورة ➜ عرض الصورة + زر "تحليل" + زر "اختيار صورة أخرى"
    // - عند الضغط على "تحليل" ➜ إظهار Loader حتى انتهاء الاستدعاء

    return Scaffold(
      appBar: AppBar(
        title: const Text('تصوير العشبة'),
        backgroundColor: const Color(0xFF4CAF50), // اللون الأساسي من الدليل البصري
      ),
      body: Center(
        child: const Text('📷 شاشة الكاميرا - قيد التطوير'),
      ),
    );
  }

  // TODO: دالة التقاط صورة من الكاميرا
  // Future<void> _takePicture() async {
  //   • استخدام _picker.pickImage(source: ImageSource.camera)
  //   • حفظ الصورة في _selectedImage (مؤقت فقط)
  //   • setState لتحديث الواجهة
  // }

  // TODO: دالة اختيار صورة من المعرض
  // Future<void> _pickFromGallery() async {
  //   • استخدام _picker.pickImage(source: ImageSource.gallery)
  //   • حفظ الصورة في _selectedImage (مؤقت فقط)
  //   • setState لتحديث الواجهة
  // }

  // TODO: دالة تحليل الصورة
  // Future<void> _analyzeImage() async {
  //   setState(() => _isAnalyzing = true);
  //   • try:
  //       - استدعاء AIService.analyzeHerb(_selectedImage!)
  //       - استقبال النتيجة (اسم العشبة + الوصف)
  //       - الانتقال إلى ResultScreen مع البيانات
  //   • catch:
  //       - حفظ رسالة في _errorMessage
  //       - عرض SnackBar أو Text بالخطأ
  //   • finally:
  //       - setState(() => _isAnalyzing = false);
  // }
}
