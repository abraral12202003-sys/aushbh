// herb_details_screen.dart
// المسؤول: مودة
// الغرض: شاشة عرض تفاصيل العشبة (تخدم دورين: تفاصيل + نتيجة التحليل)
//
// ⬅️ هذه الشاشة تجمع بين:
//    • View Dried Herb Information (SRS – القسم 3.4.8)
//    • Identify Herb – Result (SRS – القسم 3.4.4, 3.4.5)
//
// المتطلبات:
// ╔════════════════════════════════════════════════════════════════╗
// ║ 1. عرض صورة قياسية من الداتا ست                               ║
// ║ 2. عرض اسم العشبة                                             ║
// ║ 3. إذا قادمة من التحليل ➜ عرض نسبة الثقة (confidence %)      ║
// ║ 4. عرض الاستخدامات الطبية                                    ║
// ║ 5. عرض الاستخدامات في الطبخ                                  ║
// ║ 6. زر "إضافة إلى المفضلة"                                   ║
// ║ 7. إذا قادمة من التحليل ➜ زر "تجربة صورة أخرى"              ║
// ╚════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
// import '../../models/herb_model.dart';
// import '../../services/firestore_service.dart';

class HerbDetailsScreen extends StatefulWidget {
  // final DriedHerb herb;             // بيانات العشبة (اسم + صورة + الاستخدامات)
  // final double? confidence;         // نسبة الثقة (اختيارية – فقط عند التحليل)
  // final bool fromAnalysis;          // هل الشاشة جايه من عملية التحليل؟

  // const HerbDetailsScreen({
  //   Key? key,
  //   required this.herb,
  //   this.confidence,
  //   this.fromAnalysis = false,
  // }) : super(key: key);

  @override
  State<HerbDetailsScreen> createState() => _HerbDetailsScreenState();
}

class _HerbDetailsScreenState extends State<HerbDetailsScreen> {
  // ════════════════════════════════════════
  // المتغيرات (State)
  // ════════════════════════════════════════
  bool _isFavorite = false;
  bool _isAddingToFavorites = false;

  @override
  void initState() {
    super.initState();
    // TODO: التحقق إذا العشبة موجودة مسبقًا في المفضلة
  }

  @override
  Widget build(BuildContext context) {
    // TODO: جلب بيانات العشبة من widget.herb
    // String herbName = widget.herb.name;
    // String herbImage = widget.herb.imagePath;
    // String medicalUses = widget.herb.medicalUses;
    // String cookingUses = widget.herb.cookingUses;

    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل العشبة"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // صورة العشبة
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/herbs/sample.jpg", // مؤقت ➜ من الداتا ست
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // اسم العشبة
            const Text(
              "اسم العشبة", // TODO: من widget.herb.name
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // نسبة الثقة (تظهر فقط إذا fromAnalysis == true)
            // if (widget.fromAnalysis && widget.confidence != null)
            const Text(
              "نسبة الثقة: 92.4%", // TODO: عرض القيمة الحقيقية
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 20),

            // الاستخدامات الطبية
            _infoCard("الاستخدامات الطبية", "نص تجريبي"), // TODO: widget.herb.medicalUses

            // الاستخدامات في الطبخ
            _infoCard("الاستخدامات في الطبخ", "نص تجريبي"), // TODO: widget.herb.cookingUses

            const SizedBox(height: 24),

            // الأزرار
            Row(
              children: [
                // زر المفضلة
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAddingToFavorites ? null : _addToFavorites,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: Icon(
                      _isFavorite ? Icons.check : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isFavorite ? "مضافة للمفضلة" : "إضافة إلى المفضلة",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // زر تجربة صورة أخرى (يظهر فقط إذا fromAnalysis == true)
                // if (widget.fromAnalysis)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _tryAnotherImage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                    ),
                    child: const Text(
                      "تجربة صورة أخرى",
                      style: TextStyle(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // مكون لإظهار بطاقة معلومات
  Widget _infoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(content,
                style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }

  // دالة إضافة للمفضلة
  Future<void> _addToFavorites() async {
    setState(() => _isAddingToFavorites = true);
    // TODO: حفظ في Firestore
    setState(() {
      _isFavorite = true;
      _isAddingToFavorites = false;
    });
  }

  // دالة تجربة صورة أخرى
  void _tryAnotherImage() {
    Navigator.pop(context); // العودة للكاميرا
  }
}
