// favorite_model.dart
// المسؤول: مودة
// الغرض: نموذج بيانات المفضلات لربط المستخدم بالأعشاب المفضلة

class Favorite {
  // الخصائص الأساسية
  final String favoriteID; // معرف فريد لسجل المفضلة
  final String userID;     // معرف المستخدم
  final String herbID;     // معرف العشبة

  // الـ Constructor
  const Favorite({
    required this.favoriteID,
    required this.userID,
    required this.herbID,
  });

  // التحويل من Map إلى Favorite
  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      favoriteID: map['favoriteID'] ?? '',
      userID: map['userID'] ?? '',
      herbID: map['herbID'] ?? '',
    );
  }

  // التحويل من Favorite إلى Map
  Map<String, dynamic> toMap() {
    return {
      'favoriteID': favoriteID,
      'userID': userID,
      'herbID': herbID,
    };
  }

  // إنشاء نسخة معدلة
  Favorite copyWith({
    String? favoriteID,
    String? userID,
    String? herbID,
  }) {
    return Favorite(
      favoriteID: favoriteID ?? this.favoriteID,
      userID: userID ?? this.userID,
      herbID: herbID ?? this.herbID,
    );
  }

  // إنشاء معرف فريد للمفضلة (user + herb)
  static String generateFavoriteID(String userID, String herbID) {
    return '${userID}_$herbID';
  }

  // التحقق من صحة البيانات
  bool isValid() {
    if (favoriteID.isEmpty || userID.isEmpty || herbID.isEmpty) return false;
    return true;
  }

  String? validateField(String field) {
    switch (field) {
      case 'userID':
        if (userID.isEmpty) return 'معرف المستخدم مطلوب';
        break;
      case 'herbID':
        if (herbID.isEmpty) return 'معرف العشبة مطلوب';
        break;
      default:
        return null;
    }
    return null;
  }

  @override
  String toString() {
    return 'Favorite(favoriteID: $favoriteID, userID: $userID, herbID: $herbID)';
  }
}
