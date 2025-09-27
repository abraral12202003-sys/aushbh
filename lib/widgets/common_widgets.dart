// common_widgets.dart
// المسؤول: مشترك
// الغرض: عناصر واجهة مشتركة ومعاد استخدامها


import 'package:flutter/material.dart';

// TODO: CustomTextField - حقل نص مخصص مع validation
/* تعليمات CustomTextField:
   ╔════════════════════════════════════════════════════════════════╗
   ║                        حقل النص المخصص                        ║
   ╚════════════════════════════════════════════════════════════════╝

   class CustomTextField extends StatelessWidget {
     final TextEditingController controller;
     final String labelText;
     final String? hintText;
     final IconData? prefixIcon;
     final Widget? suffixIcon;
     final bool obscureText;
     final TextInputType keyboardType;
     final String? Function(String?)? validator;
     final void Function(String)? onChanged;
     final FocusNode? focusNode;

     const CustomTextField({
       Key? key,
       required this.controller,
       required this.labelText,
       this.hintText,
       this.prefixIcon,
       this.suffixIcon,
       this.obscureText = false,
       this.keyboardType = TextInputType.text,
       this.validator,
       this.onChanged,
       this.focusNode,
     }) : super(key: key);

     @override
     Widget build(BuildContext context) {
       return TextFormField(
         controller: controller,
         obscureText: obscureText,
         keyboardType: keyboardType,
         validator: validator,
         onChanged: onChanged,
         focusNode: focusNode,
         decoration: InputDecoration(
           labelText: labelText,
           hintText: hintText,
           prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
           suffixIcon: suffixIcon,
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(10),
           ),
           focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(10),
             borderSide: BorderSide(color: Color(0xFF4CAF50)),
           ),
         ),
       );
     }
   }
*/

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: تنفيذ التصميم الكامل
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }
}

// TODO: CustomButton - زر مخصص بالألوان الموحدة
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: تنفيذ التصميم الكامل
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4CAF50),
      ),
      child: isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(text),
    );
  }
}

// TODO: LoadingIndicator - مؤشر تحميل مخصص
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}

// TODO: ErrorMessage - رسالة خطأ مخصصة
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: تنفيذ التصميم الكامل
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }
}

// TODO: SuccessMessage - رسالة نجاح مخصصة
class SuccessMessage extends StatelessWidget {
  final String message;

  const SuccessMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

// TODO: CustomCard - كارت مخصص للأعشاب
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CustomCard({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: تنفيذ التصميم الكامل
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

// TODO: EmptyState - حالة القائمة الفارغة
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(subtitle, textAlign: TextAlign.center),
          if (buttonText != null && onButtonPressed != null) ...[
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonText!),
            ),
          ],
        ],
      ),
    );
  }
}