import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static const routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _ob1 = true, _ob2 = true;
  File? _pickedFile;
  final _picker = ImagePicker();

  String? _imageError;

  static const Color _green = Color(0xFF2E774F);
  static const Color _bg = Color(0xFFF7F9F8);

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // اختيار صورة الملف الشخصي
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
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

  // إنشاء الحساب
  void _signUp() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (_imageError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_imageError!, textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);

    final avatarR = (base * 0.16).clamp(50.0, 68.0);
    final avatarIcon = (avatarR * 1.05).clamp(48.0, 72.0);
    final cardRadius = (base * 0.04).clamp(16.0, 22.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false, // حذف سهم الرجوع
          title: const Text(
            'إنشاء حساب جديد',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all((base * 0.05).clamp(16.0, 22.0)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // صورة الملف الشخصي
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        CircleAvatar(
                          radius: avatarR,
                          backgroundColor: const Color(0xFFE7F2EC),
                          backgroundImage: _pickedFile != null ? FileImage(_pickedFile!) : null,
                          child: _pickedFile == null
                              ? Icon(Icons.person, size: avatarIcon, color: _green)
                              : null,
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
                                color: const Color(0xFFF7F9F8),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFEFEFEF)),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: (base * 0.06).clamp(18.0, 22.0),
                                color: _green,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_imageError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _imageError!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // الاسم
                    _field("الاسم", _name, (v) {
                      if (v == null || v.trim().isEmpty) return "الاسم مطلوب";
                      if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(v)) return "الاسم يجب أن يحتوي على حروف فقط";
                      return null;
                    }, prefix: const Icon(Icons.badge_outlined)),

                    // اسم المستخدم
                    _field("اسم المستخدم", _username, (v) {
                      if (v == null || v.isEmpty) return "اسم المستخدم مطلوب";
                      if (v.length < 3 || v.length > 15) return "الطول يجب أن يكون بين 3 و15 حرف";
                      if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9._]+$').hasMatch(v)) return "مسموح حروف وأرقام و . و _ فقط";
                      if (v.contains(' ')) return "لا يسمح بالمسافات";
                      if (v.contains("..")) return "لا يسمح بالنقطتين المتتاليتين";
                      return null;
                    }, prefix: const Icon(Icons.alternate_email)),

                    // البريد الإلكتروني
                    _field("البريد الإلكتروني", _email, (v) {
                      if (v == null || v.isEmpty) return "البريد الإلكتروني مطلوب";
                      if (v.contains(' ')) return "لا يسمح بالمسافات";
                      if (v.length > 254) return "البريد طويل جدًا";
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) return "صيغة البريد غير صحيحة";
                      return null;
                    },
                        keyboard: TextInputType.emailAddress,
                        prefix: const Icon(Icons.email_outlined)),

                    // كلمة المرور
                    _field("كلمة المرور", _password, (v) {
                      if (v == null || v.isEmpty) return "كلمة المرور مطلوبة";
                      if (v.length < 8) return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
                      if (!RegExp(r'[A-Z]').hasMatch(v)) return "يجب أن تحتوي على حرف كبير";
                      if (!RegExp(r'[a-z]').hasMatch(v)) return "يجب أن تحتوي على حرف صغير";
                      if (!RegExp(r'[0-9]').hasMatch(v)) return "يجب أن تحتوي على رقم";
                      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) return "يجب أن تحتوي على رمز";
                      if (v.contains(' ')) return "لا يسمح بالمسافات";
                      return null;
                    },
                        obscure: _ob1,
                        prefix: const Icon(Icons.lock_outline),
                        suffix: IconButton(
                          icon: Icon(_ob1 ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _ob1 = !_ob1),
                        )),

                    // تأكيد كلمة المرور
                    _field("تأكيد كلمة المرور", _confirm, (v) {
                      if (v == null || v.isEmpty) return "تأكيد كلمة المرور مطلوب";
                      if (v != _password.text) return "كلمتا المرور غير متطابقتان";
                      return null;
                    },
                        obscure: _ob2,
                        prefix: const Icon(Icons.verified_user_outlined),
                        suffix: IconButton(
                          icon: Icon(_ob2 ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _ob2 = !_ob2),
                        )),

                    const SizedBox(height: 24),

                    // زر إنشاء الحساب
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _signUp,
                        style: FilledButton.styleFrom(
                          backgroundColor: _green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'إنشاء الحساب',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // لديك حساب؟ سجل الدخول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('لديك حساب؟ ', style: TextStyle(color: Colors.black54)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text(
                            'سجل الدخول',
                            style: TextStyle(
                              color: _green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  // ويدجت الحقول
  Widget _field(
      String label,
      TextEditingController c,
      String? Function(String?)? v, {
        bool obscure = false,
        TextInputType? keyboard,
        Widget? prefix,
        Widget? suffix,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: v,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefix,
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFFF8F9F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

