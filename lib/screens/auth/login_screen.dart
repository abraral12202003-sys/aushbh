import 'package:aushbh/screens/main/home_screen.dart';
import 'package:aushbh/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  bool _isPasswordVisible = false;
  String? _formError;

  static const Color _primaryGreen = Color(0xFF2E774F);
  static const Color _inputFill = Color(0xFFF8F9FA);

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _clearFieldsAndError() {
    _email.clear();
    _pass.clear();
    setState(() => _formError = null);
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;

    if (!await _hasInternet()) {
      _showSnackBar('لا يوجد اتصال بالإنترنت');
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
      _clearFieldsAndError();

      if (mounted) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    } on FirebaseAuthException {
      setState(() {
        _formError = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      });
    } catch (_) {
      _showSnackBar('حدث خطأ غير متوقع');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showResetPasswordDialog() {
    final _resetEmail = TextEditingController(text: _email.text);
    final _formKeyDialog = GlobalKey<FormState>();
    String? message;
    Color messageColor = _primaryGreen;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.lock_reset, size: 48, color: _primaryGreen),
                SizedBox(height: 12),
                Text(
                  'إعادة تعيين كلمة المرور',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Form(
              key: _formKeyDialog,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _resetEmail,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon:
                          const Icon(Icons.email_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: _inputFill,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                    ),
                    textAlign: TextAlign.right,
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'البريد مطلوب';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value)) return 'صيغة البريد غير صحيحة';
                      if (value.contains(' ')) return 'لا يسمح بالمسافات';
                      return null;
                    },
                  ),
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        message!,
                        style: TextStyle(
                            color: messageColor, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setStateDialog(() => message = null);
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (!_formKeyDialog.currentState!.validate()) return;
                  if (!await _hasInternet()) {
                    setStateDialog(() {
                      message = 'لا يوجد اتصال بالإنترنت';
                      messageColor = Colors.red;
                    });
                    return;
                  }
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _resetEmail.text.trim(),
                    );
                    setStateDialog(() {
                      message = 'إذا كان البريد مسجلاً، سيتم إرسال الرابط';
                      messageColor = _primaryGreen;
                    });
                    _resetEmail.clear();
                  } catch (_) {
                    setStateDialog(() {
                      message = 'حدث خطأ. تأكد من صحة البريد.';
                      messageColor = Colors.red;
                    });
                  }
                },
                child: const Text(
                  'إرسال',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context).size.width.clamp(320.0, 600.0);
    final cardRadius = (base * 0.05).clamp(18.0, 26.0);
    final fieldFont = (base * 0.042).clamp(14.0, 18.0);
    final buttonFont = (base * 0.048).clamp(16.0, 20.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.jpg',
                    height: (base * 0.45).clamp(140.0, 200.0),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryGreen.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all((base * 0.06).clamp(20.0, 30.0)),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: fieldFont),
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon:
                                const Icon(Icons.email_outlined, color: Colors.grey),
                            filled: true,
                            fillColor: _inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(color: _primaryGreen, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'البريد الإلكتروني مطلوب';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value)) return 'صيغة البريد الإلكتروني غير صحيحة';
                            if (value.contains(' ')) return 'لا يسمح بالمسافات';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pass,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(fontSize: fieldFont),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon:
                                const Icon(Icons.lock_outline, color: Colors.grey),
                            filled: true,
                            fillColor: _inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(color: _primaryGreen, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          validator: (v) {
                            final value = v ?? '';
                            if (value.isEmpty) return 'كلمة المرور مطلوبة';
                            if (value.length < 8) return '٨ أحرف على الأقل';
                            if (value.contains(' ')) return 'لا يسمح بالمسافات';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_formError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _formError!,
                              style: const TextStyle(
                                  color: Colors.red, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _showResetPasswordDialog,
                            child: const Text(
                              'هل نسيت كلمة المرور؟',
                              style: TextStyle(
                                  color: _primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 8,
                            ),
                            onPressed: _loading ? null : _login,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    'دخول',
                                    style: TextStyle(
                                        fontSize: buttonFont,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟ ',
                          style: TextStyle(color: Colors.black54)),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, SignupScreen.routeName),
                        child: const Text('إنشاء حساب جديد',
                            style: TextStyle(
                                color: _primaryGreen, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
