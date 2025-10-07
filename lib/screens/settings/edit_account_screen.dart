import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// شاشة تعديل الحساب
class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});
  static const routeName = '/edit-account';

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  // مفاتيح الفورم والتحكم في الحقول
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _currentPassword = TextEditingController();

  // متغيرات لإخفاء/إظهار كلمات المرور
  bool _obNew = true, _obConfirm = true, _obCurrent = true;

  // اختيار صورة البروفايل
  File? _pickedFile;
  final _picker = ImagePicker();
  String? _currentPasswordError;

  // ألوان ثابتة
  static const Color _green = Color(0xFF2E774F);
  static const Color _bg = Color(0xFFF7F9F8);

  @override
  void dispose() {
    // إغلاق الكنترولرات عند التخلص من الشاشة
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _currentPassword.dispose();
    super.dispose();
  }

  // اختيار صورة من المعرض أو الكاميرا
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
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
                leading: const Icon(Icons.photo_library_outlined, color: _green),
                title: const Text('اختيار صورة من المعرض'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: _green),
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

      // تحقق من الصيغة والحجم
      if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
        _showSnackBar("صيغة غير مدعومة (JPG, JPEG, PNG)", Colors.red);
        return;
      }
      if (sizeMB > 5) {
        _showSnackBar("حجم الصورة أكبر من ٥ ميجابايت", Colors.red);
        return;
      }

      setState(() => _pickedFile = file);
    }
  }

  // حفظ التعديلات
  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    // تحقق من إدخال كلمة المرور الحالية عند تغيير البريد أو كلمة المرور
    if ((_email.text.trim().isNotEmpty || _password.text.trim().isNotEmpty) &&
        _currentPassword.text.trim().isEmpty) {
      setState(() {
        _currentPasswordError = "الرجاء إدخال كلمة المرور الحالية لتأكيد التعديلات";
      });
      return;
    }

    setState(() => _currentPasswordError = null);
    _showSnackBar("تم حفظ التعديلات بنجاح", _green);

    // بعد الحفظ ارجع لشاشة الإعدادات
    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });

    _clearFields();
  }

  // مسح الحقول بعد الحفظ
  void _clearFields() {
    _name.clear();
    _username.clear();
    _email.clear();
    _password.clear();
    _confirmPassword.clear();
    _currentPassword.clear();
    setState(() => _pickedFile = null);
  }

  // رسالة منبثقة (SnackBar)
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // واجهة الشاشة
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width.clamp(320.0, 600.0);
    final avatarR = (w * 0.16).clamp(50.0, 68.0);
    final avatarIcon = (avatarR * 1.05).clamp(48.0, 72.0);
    final cardRadius = (w * 0.04).clamp(16.0, 22.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false, // حذف سهم التراجع
          title: const Text(
            'تعديل الحساب',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all((w * 0.05).clamp(16.0, 22.0)),
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
                    // صورة الحساب + زر الكاميرا
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        CircleAvatar(
                          radius: avatarR,
                          backgroundColor: const Color(0xFFE7F2EC),
                          backgroundImage: _pickedFile != null ? FileImage(_pickedFile!) : null,
                          child: _pickedFile == null ? Icon(Icons.person, size: avatarIcon, color: _green) : null,
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
                              child: Icon(Icons.camera_alt_outlined, size: (w * 0.06).clamp(18.0, 22.0), color: _green),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // حقول إدخال البيانات
                    _field("الاسم", _name, (v) {
                      if (v != null && v.trim().isNotEmpty && !RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(v)) {
                        return "الاسم يجب أن يحتوي على أحرف فقط";
                      }
                      return null;
                    }, prefix: const Icon(Icons.badge_outlined)),

                    _field("اسم المستخدم", _username, (v) {
                      if (v != null && v.trim().isNotEmpty) {
                        if (v.length < 3 || v.length > 15) return "اسم المستخدم يجب أن يكون بين ٣–١٥ حرفًا";
                        if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9._]+$').hasMatch(v)) return "مسموح استخدام الحروف، الأرقام، النقطة (.) والشرطة السفلية (_)";
                        if (v.contains(' ')) return "غير مسموح بالمسافات";
                        if (v.contains("..")) return "غير مسموح بالنقطتين المتتاليتين";
                      }
                      return null;
                    }, prefix: const Icon(Icons.alternate_email)),

                    _field("البريد الإلكتروني", _email, (v) {
                      if (v != null && v.trim().isNotEmpty) {
                        if (v.contains(' ')) return "غير مسموح بالمسافات";
                        if (v.length > 254) return "البريد طويل جدًا";
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) return "صيغة البريد الإلكتروني غير صحيحة";
                      }
                      return null;
                    }, prefix: const Icon(Icons.email_outlined), keyboard: TextInputType.emailAddress),

                    _field("كلمة المرور الجديدة", _password, (v) {
                      if (v != null && v.isNotEmpty) {
                        if (v.length < 8) return "كلمة المرور يجب أن تكون ٨ أحرف على الأقل";
                        if (!RegExp(r'[A-Z]').hasMatch(v)) return "يجب أن تحتوي على حرف كبير";
                        if (!RegExp(r'[a-z]').hasMatch(v)) return "يجب أن تحتوي على حرف صغير";
                        if (!RegExp(r'[0-9]').hasMatch(v)) return "يجب أن تحتوي على رقم";
                        if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) return "يجب أن تحتوي على رمز";
                        if (v.contains(' ')) return "غير مسموح بالمسافات";
                      }
                      return null;
                    }, prefix: const Icon(Icons.lock_outline), obscure: _obNew, suffix: IconButton(
                      icon: Icon(_obNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obNew = !_obNew),
                    )),

                    _field("تأكيد كلمة المرور الجديدة", _confirmPassword, (v) {
                      if (_password.text.isNotEmpty && v != _password.text) return "كلمتا المرور غير متطابقتان";
                      return null;
                    }, prefix: const Icon(Icons.verified_user_outlined), obscure: _obConfirm, suffix: IconButton(
                      icon: Icon(_obConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obConfirm = !_obConfirm),
                    )),

                    _field("كلمة المرور الحالية", _currentPassword, (v) => null,
                        prefix: const Icon(Icons.lock_clock_outlined),
                        obscure: _obCurrent,
                        suffix: IconButton(
                          icon: Icon(_obCurrent ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obCurrent = !_obCurrent),
                        ),
                        errorText: _currentPasswordError),

                    const SizedBox(height: 24),

                    // أزرار الحفظ والإلغاء
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade400)),
                            child: const Text('إلغاء', style: TextStyle(color: Colors.black87)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(backgroundColor: _green),
                            child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white)),
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

  // دالة لبناء الحقول مع الإعدادات المشتركة
  Widget _field(
      String label,
      TextEditingController controller,
      String? Function(String?)? validator, {
        bool obscure = false,
        Widget? prefix,
        Widget? suffix,
        TextInputType? keyboard,
        String? errorText,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscure,
        keyboardType: keyboard,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefix,
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFFF8F9F9),
          errorText: errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
