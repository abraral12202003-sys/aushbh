import 'dart:io'; // للتعامل مع الملفات
import 'package:flutter/material.dart'; // واجهة المستخدم
import 'package:image_picker/image_picker.dart'; // لاختيار الصور من المعرض أو الكاميرا

///  شاشة تعديل معلومات الحساب
class EditAccountScreen extends StatefulWidget { 
  const EditAccountScreen({super.key}); // مُنشئ ثابت
  static const routeName = '/edit-account'; // مسار التوجيه

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState(); // إنشاء الحالة
}

class _EditAccountScreenState extends State<EditAccountScreen> { // حالة الشاشة
  final _formKey = GlobalKey<FormState>(); // مفتاح للتحقق من صحة النموذج

  ///  حقول الإدخال (التحكم في النصوص)
  final _name = TextEditingController(); /// الاسم
  final _username = TextEditingController(); /// اسم المستخدم
  final _email = TextEditingController(); // البريد الإلكتروني
  final _password = TextEditingController(); // كلمة المرور الجديدة
  final _confirmPassword = TextEditingController(); // تأكيد كلمة المرور الجديدة
  final _currentPassword = TextEditingController(); // كلمة المرور الحالية

  bool _obNew = true, _obConfirm = true, _obCurrent = true; // إخفاء كلمات المرور

  File? _pickedFile; // ملف الصورة المختارة
  final _picker = ImagePicker(); // مُلتقط الصور

  bool _loading = false; // حالة التحميل (لمنع التكرار)

  String? _currentPasswordError; // رسالة خطأ لكلمة المرور الحالية

  static const Color _green = Color(0xFF2E774F); // لون أخضر مخصص
  static const Color _bg = Color(0xFFF7F9F8); // لون خلفية فاتح

  final _oldData = { // بيانات قديمة (للمقارنة)
    "name": "الاسم الحالي",
    "username": "اسم_مستخدم",
    "email": "old@email.com",
  };

  @override
  void dispose() { // تنظيف الموارد عند التخلص من الودجت
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _currentPassword.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async { // اختيار صورة من المعرض أو الكاميرا
    final source = await showModalBottomSheet<ImageSource>( // عرض ورقة سفلية لاختيار المصدر
      context: context, // سياق الواجهة
      showDragHandle: true, // إظهار مقبض السحب
      backgroundColor: Colors.white, // خلفية بيضاء
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // زوايا مستديرة في الأعلى
      ),
      builder: (_) => Directionality( // اتجاه النص من اليمين لليسار
        textDirection: TextDirection.rtl, // اتجاه النص
        child: Column( // عمود للعناصر
          mainAxisSize: MainAxisSize.min, // حجم العمود حسب المحتوى
          children: [ // عناصر العمود
            ListTile( // خيار اختيار من المعرض
              leading: const Icon(Icons.photo_library_outlined), // أيقونة المعرض
              title: const Text('اختيار صورة من المعرض'), // نص الخيار
              onTap: () => Navigator.pop(context, ImageSource.gallery), // إرجاع المصدر المختار
            ),
            ListTile( // خيار اختيار من الكاميرا
              leading: const Icon(Icons.photo_camera_outlined), // أيقونة الكاميرا
              title: const Text('التقاط صورة بالكاميرا'), // نص الخيار
              onTap: () => Navigator.pop(context, ImageSource.camera), // إرجاع المصدر المختار
            ),
            const SizedBox(height: 8), // مسافة صغيرة في الأسفل
          ],
        ),
      ),
    );

    if (source == null) return; // إذا لم يتم اختيار مصدر، العودة
    final x = await _picker.pickImage(source: source, imageQuality: 85); // اختيار الصورة
    if (x != null) { // إذا تم اختيار صورة
      final file = File(x.path); // إنشاء ملف من المسار
      final ext = x.path.split('.').last.toLowerCase(); // استخراج الامتداد
      final sizeMB = await file.length() / (1024 * 1024); // حساب الحجم بالميجابايت

      if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) { // التحقق من الامتداد
        _showSnackBar("صيغة غير مدعومة (مسموح: JPG, JPEG, PNG)", Colors.red); // عرض رسالة خطأ
        return; // العودة
      }

      if (sizeMB > 5) { // التحقق من الحجم (أكبر من 5 ميجابايت)
        _showSnackBar("حجم الصورة أكبر من ٥ ميجابايت", Colors.red); // عرض رسالة خطأ
        return; // العودة
      }

      setState(() => _pickedFile = file); // تحديث الحالة بالصورة المختارة
    }
  }

  void _saveChanges() { // حفظ التعديلات
    if (!_formKey.currentState!.validate()) return; // التحقق من صحة النموذج

    if ((_email.text.trim().isNotEmpty && _email.text.trim() != _oldData["email"]) ||
        _password.text.trim().isNotEmpty) { // إذا تم تعديل البريد أو كلمة المرور
      if (_currentPassword.text.trim().isEmpty) { // إذا كانت كلمة المرور الحالية فارغة
        setState(() { // تحديث الحالة
          _currentPasswordError = "الرجاء إدخال كلمة المرور الحالية لتأكيد التعديلات"; // رسالة خطأ 
        });
        return;
      }
    }

    setState(() { // تحديث الحالة
      _currentPasswordError = null; // مسح رسالة الخطأ
    });

    final updates = <String, dynamic>{}; // خريطة لتخزين التعديلات
    if (_name.text.trim().isNotEmpty && _name.text.trim() != _oldData["name"]) { // إذا تم تعديل الاسم
      updates["name"] = _name.text.trim(); // إضافة التعديل للخريطة
    }
    if (_username.text.trim().isNotEmpty && _username.text.trim() != _oldData["username"]) { // إذا تم تعديل اسم المستخدم
      updates["username"] = _username.text.trim(); // إضافة التعديل للخريطة
    }
    if (_email.text.trim().isNotEmpty && _email.text.trim() != _oldData["email"]) { // إذا تم تعديل البريد الإلكتروني
      updates["email"] = _email.text.trim(); // إضافة التعديل للخريطة
    }
    if (_password.text.trim().isNotEmpty) { // إذا تم إدخال كلمة مرور جديدة
      updates["password"] = _password.text.trim(); // إضافة التعديل للخريطة
    }
    if (_pickedFile != null) { // إذا تم اختيار صورة جديدة
      updates["photo"] = _pickedFile!.path; // إضافة مسار الصورة للخريطة
    }

    if (updates.isEmpty) { // إذا لم تكن هناك تعديلات
      _showSnackBar("لم يتم تعديل أي بيانات", Colors.grey); // عرض رسالة
      return;
    }

    _showSnackBar("تم حفظ التعديلات بنجاح", Colors.green); // عرض رسالة نجاح

    _clearFields(); // تنظيف الحقول بعد الحفظ
  }

  void _clearFields() { // تنظيف حقول الإدخال
    _name.clear();
    _username.clear();
    _email.clear();
    _password.clear();
    _confirmPassword.clear();
    _currentPassword.clear();
    setState(() { // تحديث الحالة
      _pickedFile = null; // مسح الصورة المختارة
    });
  }

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

  ///  واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = w.clamp(320.0, 600.0);
    final avatarR = (base * 0.16).clamp(50.0, 68.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'تعديل الحساب',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all((base * 0.05).clamp(16.0, 22.0)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ///  صورة الحساب + زر تغيير الصورة
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      CircleAvatar(
                        radius: avatarR,
                        backgroundColor: const Color(0xFFE7F2EC),
                        backgroundImage:
                            _pickedFile != null ? FileImage(_pickedFile!) : null,
                        child: _pickedFile == null
                            ? const Icon(Icons.person, size: 60, color: _green)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(30),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt_outlined, color: _green),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ///  حقول الإدخال)
                  _field("الاسم", _name, (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(v)) {
                        return "الاسم يجب أن يحتوي على أحرف فقط";
                      }
                    }
                    return null;
                  }, icon: Icons.badge_outlined),

                  _field("اسم المستخدم", _username, (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      if (v.length < 3 || v.length > 15) return "اسم المستخدم يجب أن يكون بين ٣–١٥ حرفًا";
                      if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9._]+$').hasMatch(v)) {
                        return "مسموح استخدام الحروف، الأرقام، النقطة (.) والشرطة السفلية (_)";
                      }
                      if (v.contains(' ')) return "غير مسموح بالمسافات";
                      if (v.contains("..")) return "غير مسموح بنقطتين متتاليتين";
                    }
                    return null;
                  }, icon: Icons.alternate_email),

                  _field("البريد الإلكتروني", _email, (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      if (v.contains(' ')) return "غير مسموح بالمسافات";
                      if (v.length > 254) return "البريد الإلكتروني طويل جدًا";
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
                        return "صيغة البريد الإلكتروني غير صحيحة";
                      }
                    }
                    return null;
                  }, icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),

                  ///  كلمة المرور الجديدة + التأكيد + الحالية
                  _field("كلمة المرور الجديدة", _password, (v) {
                    if (v != null && v.isNotEmpty) {
                      if (v.length < 8) return "كلمة المرور يجب أن تكون ٨ أحرف على الأقل";
                      if (!RegExp(r'[A-Z]').hasMatch(v)) return "يجب أن تحتوي على حرف كبير";
                      if (!RegExp(r'[a-z]').hasMatch(v)) return "يجب أن تحتوي على حرف صغير";
                      if (!RegExp(r'[0-9]').hasMatch(v)) return "يجب أن تحتوي على رقم";
                      if (!RegExp(r'[!@#\$%^&*(),.?\":{}|<>]').hasMatch(v)) return "يجب أن تحتوي على رمز";
                      if (v.contains(' ')) return "غير مسموح بالمسافات";
                    }
                    return null;
                  },
                      icon: Icons.lock_outline,
                      obscure: _obNew,
                      suffix: IconButton(
                        icon: Icon(_obNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obNew = !_obNew),
                      )),

                  _field("تأكيد كلمة المرور الجديدة", _confirmPassword, (v) {
                    if (_password.text.isNotEmpty && v != _password.text) {
                      return "كلمتا المرور غير متطابقتان";
                    }
                    return null;
                  },
                      icon: Icons.verified_user_outlined,
                      obscure: _obConfirm,
                      suffix: IconButton(
                        icon: Icon(_obConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obConfirm = !_obConfirm),
                      )),

                  _field("كلمة المرور الحالية", _currentPassword, (v) => null,
                      icon: Icons.lock_clock_outlined,
                      obscure: _obCurrent,
                      suffix: IconButton(
                        icon: Icon(_obCurrent ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obCurrent = !_obCurrent),
                      ),
                      errorText: _currentPasswordError),

                  const SizedBox(height: 24),

                  ///  أزرار (إلغاء + حفظ التعديلات)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: _green),
                          ),
                          child: const Text('إلغاء', style: TextStyle(color: _green, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _loading ? null : _saveChanges,
                          style: FilledButton.styleFrom(
                            backgroundColor: _green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text('حفظ التعديلات',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  ///  ويدجت مساعدة لإنشاء حقل إدخال بنمط موحد
  Widget _field(
    String label,
    TextEditingController c,
    String? Function(String?)? v, {
    bool obscure = false,
    IconData? icon,
    Widget? suffix,
    TextInputType? keyboard,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        validator: v,
        obscureText: obscure,
        keyboardType: keyboard,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
