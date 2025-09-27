// herb_model.dart
// المسؤول: ريما
// الغرض: نموذج بيانات العشبة المجففة

class DriedHerb {
  // الخصائص الأساسية
  final String herbID;   // معرف فريد للعشبة
  final String name;     // اسم العشبة
  final String imageUrl; // رابط صورة العشبة
  final String uses;     // الاستخدامات (طبية + طبخية)

  // الـ Constructor
  const DriedHerb({
    required this.herbID,
    required this.name,
    required this.imageUrl,
    required this.uses,
  });

  // التحويل من Map (Firestore) إلى DriedHerb
  factory DriedHerb.fromMap(Map<String, dynamic> map) {
    return DriedHerb(
      herbID: map['herbID'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      uses: map['uses'] ?? '',
    );
  }

  // التحويل من DriedHerb إلى Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'herbID': herbID,
      'name': name,
      'imageUrl': imageUrl,
      'uses': uses,
    };
  }

  // دالة للبحث بالاسم (حتى لو جزء من الاسم)
  bool matches(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery);
  }

  // التحقق من صحة البيانات
  bool isValid() {
    if (herbID.isEmpty || name.isEmpty || imageUrl.isEmpty) return false;
    if (uses.isEmpty) return false;
    return true;
  }

  @override
  String toString() {
    return 'DriedHerb(herbID: $herbID, name: $name, uses: $uses)';
  }
}
