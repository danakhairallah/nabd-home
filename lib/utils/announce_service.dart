import 'package:flutter/semantics.dart';
// import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AnnounceService {
  static void announceLanguageChange(BuildContext context, bool isArabic) {
    final message = isArabic
        ? "تم اختيار اللغة العربية بنجاح."
        : "English language selected successfully.";

    SemanticsService.announce(
      message,
      isArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}
