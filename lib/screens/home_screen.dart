import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.secondary, AppTheme.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Semantics(
              header: true,
              label: tr('home'),
              child: Text(
                tr('home'),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 180),
            const CircleAvatar(
              radius: 110,
              backgroundColor: Colors.black,
            ),
            const SizedBox(height: 80),
            Container(
              width: 100,
              height: 98,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppTheme.textSecondary,
                    ),
                    iconSize: 34,
                  ),
                  const SizedBox(height: 2),
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFF0A286B),
                    child: Icon(Icons.add, color: Colors.white, size: 23),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
