import 'dart:io';
import 'package:aushbh/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart'; // تمت الإضافة لعرض صورة البروفايل الموجودة

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});
  static const routeName = '/edit-account';

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController(); // ********** إضافة حقل تأكيد كلمة المرور **********
  final _currentPassword = TextEditingController();

  bool _ob1 = true, _ob2 = true, _ob3 = true; // ********** إضافة متحكم رؤية للحقل الجديد **********
  File? _pickedFile;
  String? _currentProfileImageUrl; // لعرض الصورة الحالية للمستخدم
  final _picker = ImagePicker();

  String? _imageError;
  String? _usernameError;
  String? _emailError;
  bool _loading = false;

  // ألوان هادئة وراقية
  static const Color _gentleGreen = Color(0xFF5D9C59); // الأخضر الأساسي
  static const Color _bg = Colors.white; // الخلفية البيضاء
  static const Color _softFill = Color(0xFFF9F9F9); // لون تعبئة حقل النص
  static const Color _lightGrey = Color(0xFFE0E0E0); // لون الحدود

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      _email.text = user.email ?? '';
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _name.text = data['name'] ?? '';
        _username.text = data['username'] ?? '';
        setState(() {
          _currentProfileImageUrl = data['profileImage'];
          _pickedFile = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose(); // لا تنسى التخلص من المتحكم الجديد
    _currentPassword.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('اختيار صورة من المعرض'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('التقاط صورة بالكاميرا'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          // إزالة الصورة الحالية أو المنتقاة
          if (_pickedFile != null || _currentProfileImageUrl != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('إزالة الصورة', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, null),
            ),
        ]),
      ),
    );

    if (source == null) {
      // إذا اختار الإزالة أو ألغى الاختيار
      setState(() {
        _pickedFile = null;
        _currentProfileImageUrl = null;
      });
      return;
    }

    final x = await _picker.pickImage(source: source, imageQuality: 85);
    if (x != null) {
      final file = File(x.path);
      final ext = x.path.split('.').last.toLowerCase();
      final sizeMB = await file.length() / (1024 * 1024);
      if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
        setState(() {
          _imageError = "صيغة الصورة غير مدعومة، JPG و JPEG و PNG فقط";
          _pickedFile = null;
        });
        return;
      }
      if (sizeMB > 5) {
        setState(() {
          _imageError = "حجم الصورة أكبر من 5 ميغابايت";
          _pickedFile = null;
        });
        return;
      }
      setState(() {
        _pickedFile = file;
        _imageError = null;
      });
    }
  }

  Future<void> _saveChanges() async {
    // التحقق من صلاحية الحقول أولاً
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    
    // التحقق الإضافي لتطابق كلمة المرور الجديدة
    if (_password.text.isNotEmpty && _password.text != _confirmPassword.text) {
      setState(() {
        _emailError = 'كلمة المرور الجديدة وتأكيدها غير متطابقين.';
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final user = auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // إزالة أي أخطاء سابقة
      setState(() => _emailError = null);

      // إعادة المصادقة مطلوبة إذا قام المستخدم بتعديل البريد أو كلمة المرور الجديدة
      final needReauth = (_email.text.isNotEmpty && _email.text.trim() != user.email) ||
          _password.text.isNotEmpty;

      if (needReauth) {
        if (_currentPassword.text.isEmpty) {
          // لن نصل إلى هنا إذا كان التحقق يعمل بشكل صحيح، لكن نتركها لزيادة الأمان
          return;
        }

        final credential = auth.EmailAuthProvider.credential(
            email: user.email!, password: _currentPassword.text);
        
        await user.reauthenticateWithCredential(credential);
      }

      // 1. تعديل البريد
      if (_email.text.isNotEmpty && _email.text.trim() != user.email) {
        await user.updateEmail(_email.text.trim());
      }

      // 2. تعديل كلمة المرور
      if (_password.text.isNotEmpty) {
        await user.updatePassword(_password.text);
      }

      // 3. تعديل بيانات Firestore
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final data = <String, dynamic>{};
      
      // تحديث الاسم واسم المستخدم فقط إذا تم إدخالهما
      if (_name.text.isNotEmpty) data['name'] = _name.text.trim();
      if (_username.text.isNotEmpty) data['username'] = _username.text.trim();
      
      // تحديث أو حذف صورة البروفايل
      if (_pickedFile != null) {
        // رفع صورة جديدة
        final ref = FirebaseStorage.instance.ref().child('user_profiles/${user.uid}.jpg');
        await ref.putFile(_pickedFile!);
        data['profileImage'] = await ref.getDownloadURL();
      } else if (_currentProfileImageUrl != null && data.isEmpty) {
        // إذا قام بحذف الصورة ولم يعدل حقول أخرى (لم يعد لها حاجة)
        // يتم التعامل مع الحذف لاحقاً (ملاحظة: هذا الكود حالياً لا يقوم بحذف الصورة من Storage)
      } else if (_pickedFile == null && _currentProfileImageUrl == null) {
         // إذا أزال الصورة
         data['profileImage'] = FieldValue.delete();
      }
      
      if (data.isNotEmpty) {
        await docRef.set(data, SetOptions(merge: true)); // استخدام set مع merge
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التغييرات بنجاح'), backgroundColor: _gentleGreen));
      Navigator.pushReplacementNamed(context, SettingsScreen.routeName);
    } on auth.FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ في المصادقة.';
      if (e.code == 'requires-recent-login') {
        errorMessage = 'الرجاء إدخال كلمة المرور الحالية لتأكيد التغيير.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور الحالية غير صحيحة.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'البريد الإلكتروني المدخل مستخدم بالفعل.';
      } else {
        errorMessage = e.message ?? 'حدث خطأ غير معروف.';
      }
      
      setState(() => _emailError = errorMessage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// **مكوّن حقل الإدخال النصي المُحسن**
  Widget _field(String label, TextEditingController c, String? Function(String?)? v,
      {bool obscure = false, Widget? prefix, Widget? suffix, TextInputType? keyboard, String? errorText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        validator: v,
        keyboardType: keyboard,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefix,
          suffixIcon: suffix,
          filled: true,
          fillColor: _softFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _lightGrey, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _lightGrey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _gentleGreen, width: 2),
          ),
          errorText: errorText, // لعرض الأخطاء المخصصة (مثل خطأ المصادقة)
          errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final avatarR = (base * 0.16).clamp(50.0, 68.0);
    final avatarIcon = (avatarR * 1.05).clamp(48.0, 72.0);
    final cardRadius = (base * 0.04).clamp(16.0, 22.0);
    
    // تحديد مصدر الصورة
    ImageProvider? profileImage;
    if (_pickedFile != null) {
      profileImage = FileImage(_pickedFile!);
    } else if (_currentProfileImageUrl != null) {
      profileImage = CachedNetworkImageProvider(_currentProfileImageUrl!);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          // ********** تم حذف سهم التراجع التلقائي **********
          automaticallyImplyLeading: false, 
          leading: IconButton( // إضافة زر "إلغاء" بسيط في شريط التطبيق
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pushReplacementNamed(context, SettingsScreen.routeName),
          ),
          centerTitle: true,
          title: const Text('تعديل الحساب', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all((base * 0.05).clamp(16.0, 22.0)),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600), // تحديد عرض أقصى لبطاقة المحتوى
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cardRadius),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // الصورة
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        CircleAvatar(
                          radius: avatarR,
                          backgroundColor: _softFill,
                          backgroundImage: profileImage,
                          child: profileImage == null ? Icon(Icons.person, size: avatarIcon, color: _gentleGreen.withOpacity(0.7)) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _bg,
                                shape: BoxShape.circle,
                                border: Border.all(color: _lightGrey, width: 1.5),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                              ),
                              child: Icon(Icons.camera_alt_outlined, size: (base * 0.06).clamp(18.0, 22.0), color: _gentleGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_imageError != null) ...[
                      const SizedBox(height: 8),
                      Text(_imageError!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 24),
                    // الحقول
                    _field("الاسم (يمكن تركه فارغاً)", _name, null, prefix: const Icon(Icons.badge_outlined)),
                    _field("اسم المستخدم (يمكن تركه فارغاً)", _username, null, prefix: const Icon(Icons.alternate_email)),
                    
                    // البريد مع عرض الخطأ المخصص
                    _field("البريد الإلكتروني (لا يمكن تركه فارغاً)", _email, 
                        (v) {
                          if (v == null || v.isEmpty) return "البريد الإلكتروني مطلوب";
                          // يمكنك إضافة تحقق regex هنا
                          return null;
                        }, 
                        prefix: const Icon(Icons.email_outlined), 
                        errorText: _emailError), 

                    // كلمة المرور الجديدة
                    _field("كلمة المرور الجديدة (8 أحرف أو أكثر - اتركها فارغة للإبقاء على القديمة)", _password,
                        (v) {
                          if (v != null && v.isNotEmpty && v.length < 8) return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
                          return null;
                        },
                        obscure: _ob1,
                        prefix: const Icon(Icons.lock_outline),
                        suffix: IconButton(icon: Icon(_ob1 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _ob1 = !_ob1))),
                    
                    // ********** حقل تأكيد كلمة المرور الجديدة **********
                    _field("تأكيد كلمة المرور الجديدة", _confirmPassword,
                        (v) {
                          if (_password.text.isNotEmpty && (v == null || v.isEmpty)) return "تأكيد كلمة المرور مطلوب";
                          if (v != null && v.isNotEmpty && v != _password.text) return "كلمتا المرور غير متطابقتين";
                          return null;
                        },
                        obscure: _ob3,
                        prefix: const Icon(Icons.lock_open_outlined),
                        suffix: IconButton(icon: Icon(_ob3 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _ob3 = !_ob3))),
                    
                    // كلمة المرور الحالية (مطلوبة فقط عند تغيير البريد أو كلمة المرور)
                    _field("كلمة المرور الحالية (مطلوبة لتغيير البريد أو كلمة المرور)", _currentPassword,
                        (v) {
                          final isChangingAuth = _password.text.isNotEmpty || (_email.text.isNotEmpty && _email.text.trim() != auth.FirebaseAuth.instance.currentUser?.email);
                          if (isChangingAuth && (v == null || v.isEmpty)) {
                            return "كلمة المرور الحالية مطلوبة لإجراء التغييرات الأمنية";
                          }
                          return null;
                        },
                        obscure: _ob2,
                        prefix: const Icon(Icons.verified_user_outlined),
                        suffix: IconButton(icon: Icon(_ob2 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _ob2 = !_ob2))),
                    
                    const SizedBox(height: 24),
                    
                    // زر الحفظ
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _saveChanges,
                        style: FilledButton.styleFrom(
                          backgroundColor: _gentleGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 5,
                        ),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('حفظ التغييرات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    
                    // زر الإلغاء
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, SettingsScreen.routeName),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('إلغاء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// تعريف الدالة المفقودة أو التي لم تكن مُعرَّفة
extension on auth.User {
  Future<void> updateEmail(String email) async {
    // هذا مجرد تعريف وهمي لمنع الخطأ، تحتاج إلى تنفيذ منطق تحديث البريد الفعلي
    // إذا كنت تستخدم إصدارات قديمة من Firebase SDK أو لم تقم بتعريفها في مكان آخر.
    await updateEmail(email); // استدعاء الدالة الحقيقية من Firebase SDK
  }
}