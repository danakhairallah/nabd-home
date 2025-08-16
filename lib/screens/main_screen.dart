import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/theme/app_theme.dart';
import '../cubit/navigation/navigation_cubit.dart';
import '../cubit/navigation/navigation_state.dart';
import 'connectivity_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'pdfreader_screen.dart';
import 'setting_screen.dart';

class MainScreen extends StatelessWidget {
  final List<Widget> screens = [
    HomeScreen(),
    PdfReaderScreen(),
    HistoryScreen(),
    Connectivity(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.mainGradient,
      ),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: screens[state.index],
            bottomNavigationBar: _buildCustomNavBar(context, state.index),
          );
        },
      ),
    );
  }

  Widget _buildCustomNavBar(BuildContext context, int selectedIndex) {
    return Container(
      height: 74,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x959DA540),
            offset: const Offset(0, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(context, Icons.home_outlined, 0, selectedIndex),
            _navItem(context, Icons.picture_as_pdf_outlined, 1, selectedIndex),
            _navItem(context, Icons.history_outlined,  2, selectedIndex),
            _navItem(context, Icons.compare_arrows_outlined,  3, selectedIndex),
            _navItem(context, Icons.settings_outlined, 4, selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon,  int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => context.read<NavigationCubit>().changePage(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: isSelected ? AppTheme.primary : Colors.grey,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
