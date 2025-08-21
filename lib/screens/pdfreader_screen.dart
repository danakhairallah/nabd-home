import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PdfReaderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Semantics(
      header: true,
      label: tr('pdfreader'),
      excludeSemantics: false,
      child: Text(
        tr('pdfreader'),
        style: const TextStyle(fontSize: 24),
      ),
    ));
  }
}
