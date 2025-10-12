import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailService {
  static const String supportEmail = 'support@herbscanner.app';
  static const String appName = 'تطبيق عُشبة';

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
        query:
            'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
      );

      final ok = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('لا يمكن فتح تطبيق البريد');
    } catch (e) {
      handleNoEmailClient(context);
    }
  }

  static void handleNoEmailClient(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
