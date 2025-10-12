import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../main/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static const routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  // Password visibility
  bool _ob1 = true;
  bool _ob2 = true;

  // Picked image
  File? _pickedFile;
  final _picker = ImagePicker();

  // Error messages
  String? _imageError, _usernameError, _emailError;

  // Loading state
  bool _loading = false;

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

  void _clearFieldsAndErrors() {
    _name.clear();
    _username.clear();
    _email.clear();
    _password.clear();
    _confirm.clear();
    setState(() {
      _imageError = null;
      _usernameError = null;
      _emailError = null;
      _pickedFile = null;
    });
  }

  Future<bool> _hasInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
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
            if (_pickedFile != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('إزالة الصورة'),
                onTap: () => Navigator.pop(context, null),
              ),
          ],
        ),
      ),
    );

    if (source == null) {
      if (_pickedFile != null) _removeImage();
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

  void _removeImage() {
    setState(() {
      _pickedFile = null;
      _imageError = null;
    });
  }

  Future<void> _signUp() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (!await _hasInternet()) {
      _showSnackBar("لا يوجد اتصال بالإنترنت");
      return;
    }

    setState(() {
      _loading = true;
      _emailError = null;
      _usernameError = null;
    });

    try {
      final username = _username.text.trim();
      final email = _email.text.trim();

      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _usernameError = 'اسم المستخدم مستخدم مسبقًا';
            _loading = false;
          });
        }
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: _password.text);

      final uid = userCredential.user!.uid;
      String? imageUrl;

      if (_pickedFile != null) {
        final ref =
            FirebaseStorage.instance.ref().child('user_profiles/$uid.jpg');
        await ref.putFile(_pickedFile!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _name.text.trim(),
        'username': username,
        'profileImage': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearFieldsAndErrors();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } on FirebaseAuthException catch (e) {
      String? errorMsg;
      if (e.code == 'email-already-in-use') errorMsg = "البريد الإلكتروني مستخدم مسبقًا";
      else if (e.code == 'weak-password') errorMsg = "كلمة المرور ضعيفة جداً";
      else if (e.code == 'invalid-email') errorMsg = "صيغة البريد غير صحيحة";
      else errorMsg = "حدث خطأ أثناء التسجيل. (الرمز: ${e.code})";

      if (mounted) setState(() => _emailError = errorMsg);

      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser!.delete();
      }
    } catch (_) {
      if (mounted) setState(() {
        _emailError = "حدث خطأ غير متوقع. تحقق من الاتصال بالإنترنت";
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController c,
    String? Function(String?)? validator, {
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
        validator: validator,
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
          errorStyle:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('إنشاء حساب جديد',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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
                      offset: const Offset(0, 5))
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile image
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        CircleAvatar(
                          radius: avatarR,
                          backgroundColor: const Color(0xFFE7F2EC),
                          backgroundImage:
                              _pickedFile != null ? FileImage(_pickedFile!) : null,
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
                              child: Icon(Icons.camera_alt_outlined,
                                  size: (base * 0.06).clamp(18.0, 22.0), color: _green),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_imageError != null) ...[
                      const SizedBox(height: 8),
                      Text(_imageError!,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 24),
                    _field("الاسم", _name, (v) {
                      if (v == null || v.trim().isEmpty) return "الاسم مطلوب";
                      if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(v))
                        return "الاسم يجب أن يحتوي على حروف فقط";
                      return null;
                    }, prefix: const Icon(Icons.badge_outlined)),
                    _field("اسم المستخدم", _username, (v) {
                      if (v == null || v.isEmpty) return "اسم المستخدم مطلوب";
                      if (v.length < 3 || v.length > 15)
                        return "الطول يجب أن يكون بين 3 و15 حرف";
                      if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9._]+$').hasMatch(v))
                        return "مسموح حروف وأرقام و . و _ فقط";
                      if (v.contains(' ')) return "لا يسمح بالمسافات";
                      if (v.contains("..")) return "لا يسمح بالنقطتين المتتاليتين";
                      return null;
                    }, prefix: const Icon(Icons.alternate_email)),
                    if (_usernameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8, left: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(_usernameError!,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ),
                    const SizedBox(height: 8),
                    _field("البريد الإلكتروني", _email, (v) {
                      if (v == null || v.isEmpty) return "البريد الإلكتروني مطلوب";
                      if (v.contains(' ')) return "لا يسمح بالمسافات";
                      return null;
                    }, keyboard: TextInputType.emailAddress, prefix: const Icon(Icons.email_outlined)),
                    if (_emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8, left: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(_emailError!,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ),
                    _field("كلمة المرور", _password, (v) {
                      if (v == null || v.isEmpty) return "كلمة المرور مطلوبة";
                      if (v.length < 8) return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
                      if (!RegExp(r'[A-Z]').hasMatch(v)) return "يجب أن تحتوي على حرف كبير";
                      if (!RegExp(r'[a-z]').hasMatch(v)) return "يجب أن تحتوي على حرف صغير";
                      if (!RegExp(r'[0-9]').hasMatch(v)) return "يجب أن تحتوي على رقم";
                      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v))
                        return "يجب أن تحتوي على رمز";
                      if (v.contains(' ')) return "لا يسمح بالمسافات";
                      return null;
                    }, obscure: _ob1, prefix: const Icon(Icons.lock_outline), suffix: IconButton(icon: Icon(_ob1 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _ob1 = !_ob1))),
                    _field("تأكيد كلمة المرور", _confirm, (v) {
                      if (v == null || v.isEmpty) return "تأكيد كلمة المرور مطلوب";
                      if (v != _password.text) return "كلمتا المرور غير متطابقتان";
                      return null;
                    }, obscure: _ob2, prefix: const Icon(Icons.verified_user_outlined), suffix: IconButton(icon: Icon(_ob2 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _ob2 = !_ob2))),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _signUp,
                        style: FilledButton.styleFrom(
                          backgroundColor: _green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('إنشاء الحساب',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('لديك حساب؟ ',
                            style: TextStyle(color: Colors.black54)),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('سجل الدخول',
                              style: TextStyle(
                                  color: _green, fontWeight: FontWeight.bold)),
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
}
