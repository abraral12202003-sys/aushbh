import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class EmailService {
  static const String supportEmail = 'support@herbscanner.app';
  static const String appName = 'تطبيق عُشبة';

  // فتح تطبيق البريد
  static Future<void> openEmailClient({
    required BuildContext context,
    String subject = 'طلب دعم فني لتطبيق عُشبة',
    String body = 'السلام عليكم فريق الدعم الفني لتطبيق عُشبة\n',
    String? toEmail,
  }) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: toEmail ?? supportEmail,
        query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
      );

      final ok = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('لا يمكن فتح تطبيق البريد');
    } catch (e) {
      handleNoEmailClient(context);
    }
  }

  // التحقق من وجود تطبيق بريد
  static Future<bool> validateEmailClient() async {
    final Uri emailUri = Uri(scheme: 'mailto', path: supportEmail);
    return await canLaunchUrl(emailUri);
  }

  // معالجة حالة عدم وجود تطبيق بريد
  static void handleNoEmailClient(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'لا يمكن فتح تطبيق البريد على هذا الجهاز',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
