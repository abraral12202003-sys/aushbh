// user_model.dart
// المسؤول: جلنار
// الغرض: نموذج بيانات المستخدم

class User {
  // الخصائص الأساسية
  final String userID;             // معرف المستخدم (Firebase UID)
  final String name;               // الاسم الكامل
  final String username;           // اسم المستخدم الفريد
  final String email;              // البريد الإلكتروني
  final String? profilePictureUrl; // رابط الصورة الشخصية (اختياري)

  // الـ Constructor
  const User({
    required this.userID,
    required this.name,
    required this.username,
    required this.email,
    this.profilePictureUrl,
  });

  // التحويل من Map (Firestore) إلى User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userID: map['userID'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
    );
  }

  // التحويل من User إلى Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'name': name,
      'username': username,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // إنشاء نسخة معدلة من User
  User copyWith({
    String? name,
    String? username,
    String? email,
    String? profilePictureUrl,
  }) {
    return User(
      userID: userID,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  @override
  String toString() {
    return 'User(userID: $userID, name: $name, username: $username)';
  }
}
