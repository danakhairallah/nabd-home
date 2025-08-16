import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      tr('history'),
      style: const TextStyle(fontSize: 24),
    ));
  }
}
