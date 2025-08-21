import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../utils/announce_service.dart';
import 'Profile_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late bool isArabic;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isArabic = context.locale.languageCode == 'ar';
  }

  void _changeLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('switch_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(context);
                setState(() {
                  isArabic = true;
                });
                AnnounceService.announceLanguageChange(context, true);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
                setState(() {
                  isArabic = false;
                });
                AnnounceService.announceLanguageChange(context, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    print('Logout');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Semantics(
              header: true,
              label: 'setting'.tr(),
              excludeSemantics: false,
              child: Text(
                'setting'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 120),
            _buildSettingsOption(
              icon: Icons.person,
              text: 'profile'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            _buildSettingsOption(
              icon: Icons.language,
              text: 'switch_language'.tr(),
              onTap: () {
                _changeLanguageDialog();
              },
            ),
            _buildSettingsOption(
              icon: Icons.logout,
              text: 'logout'.tr(),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF313131),
              size: 25,
            ),
          ),
          title: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Divider(color: Colors.white),
        ),
      ],
    );
  }
}
