import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../main/home_screen.dart';

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

  bool _isPasswordVisible = false;
  bool _loading = false;

  static const Color _green = Color(0xFF2E774F);

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  // تسجيل الدخول
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // نافذة إعادة تعيين كلمة المرور
  void _showResetPasswordDialog() {
    final _resetEmail = TextEditingController(text: _email.text);
    final _formKeyDialog = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lock_reset, size: 48, color: _green),
              SizedBox(height: 12),
              Text(
                "إعادة تعيين كلمة المرور",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Form(
            key: _formKeyDialog,
            child: TextFormField(
              controller: _resetEmail,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              textAlign: TextAlign.right,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'البريد الإلكتروني مطلوب';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) return 'صيغة البريد غير صحيحة';
                return null;
              },
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            // زر إلغاء رمادي
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "إلغاء",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            // زر إرسال أخضر
            FilledButton(
              onPressed: () {
                if (_formKeyDialog.currentState!.validate()) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: _green,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "إرسال",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
          centerTitle: true,
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
                  // شعار التطبيق
                  Image.asset(
                    "assets/logo.jpg",
                    height: (base * 0.5).clamp(140.0, 220.0),
                  ),
                  const SizedBox(height: 32),

                  // بطاقة الإدخال
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
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
                    child: Column(
                      children: [
                        // حقل البريد الإلكتروني
                        TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            labelStyle: TextStyle(color: Colors.black54, fontSize: fieldFont),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.right,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'البريد الإلكتروني مطلوب';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                              return 'صيغة البريد الإلكتروني غير صحيحة';
                            }
                            if (value.length > 254) return 'البريد طويل جدًا';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // حقل كلمة المرور
                        TextFormField(
                          controller: _pass,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            labelStyle: TextStyle(color: Colors.black54, fontSize: fieldFont),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          textAlign: TextAlign.right,
                          validator: (v) {
                            final value = v ?? '';
                            if (value.isEmpty) return 'كلمة المرور مطلوبة';
                            if (value.length < 8) return '٨ أحرف على الأقل';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // رابط استرجاع كلمة المرور
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _showResetPasswordDialog,
                            child: const Text(
                              'هل نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: Colors.black54,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // زر تسجيل الدخول
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _loading ? null : _login,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: buttonFont,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // رابط إنشاء حساب جديد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟ ', style: TextStyle(color: Colors.black54)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, SignupScreen.routeName),
                        child: const Text(
                          'إنشاء حساب جديد',
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
    );
  }
}
