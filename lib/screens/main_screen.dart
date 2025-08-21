import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../core/theme/app_theme.dart';
import '../cubit/navigation/navigation_cubit.dart';
import '../cubit/navigation/navigation_state.dart';
import 'Profile_screen.dart';
import 'connectivity_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'pdfreader_screen.dart';
import 'setting_screen.dart';
import '../stt_service.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> screens = [
    HomeScreen(),
    PdfReaderScreen(),
    HistoryScreen(),
    Connectivity(),
    SettingScreen(),
  ];

  final STTService _sttService = STTService();
  String _lastCommand = "";
  bool _isListening = false;

  StreamSubscription? _accelSubscription;
  int _shakeCount = 0;
  DateTime? _lastShakeTime;
  final double shakeThreshold = 2.0;
  final int shakeIntervalMs = 700;

  Timer? _silenceTimer;

  DateTime? _listeningStartTime;
  int _listeningDurationSec = 0;
  String _micStatusMsg = "";

  int? _lastAnnouncedIndex;

  @override
  void initState() {
    super.initState();

    _sttService.initialize(
      onResult: (text) {
        print("أمر صوتي مكتشف: $text");
        setState(() => _lastCommand = text);
        _startSilenceTimer();
      },
      onCompletion: (text) {
        setState(() {
          _isListening = false;
          _lastCommand = text;
          _listeningDurationSec = _listeningStartTime != null
              ? DateTime.now().difference(_listeningStartTime!).inSeconds
              : 0;
          _micStatusMsg =
              "⏹️ تم إيقاف المايك بعد $_listeningDurationSec ثانية (انتهاء الجلسة)";
        });
        _silenceTimer?.cancel();
        _handleVoiceCommand(text);
      },
    );

    _accelSubscription = accelerometerEvents.listen(_handleAccelerometer);
  }

  void _handleAccelerometer(AccelerometerEvent event) {
    double gX = event.x / 9.8;
    double gY = event.y / 9.8;
    double gZ = event.z / 9.8;
    double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

    if (gForce > shakeThreshold) {
      _startListeningWithTimer();
      _lastShakeTime = DateTime.now();
    }
  }

  void _startListeningWithTimer() async {
    FocusScope.of(context).unfocus();

    // HapticFeedback.vibrate();

    print("🎤 تم تشغيل المايك للاستماع");
    setState(() {
      _isListening = true;
      _lastCommand = "";
      _micStatusMsg = "🎤 المايك يعمل...";
      _listeningStartTime = DateTime.now();
      _listeningDurationSec = 0;
    });
    await _sttService.startListening();
    _startSilenceTimer();
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(Duration(seconds: 10), () {
      _stopListeningDueToSilence();
    });
  }

  void _stopListeningDueToSilence() async {
    print("⏹️ تم إيقاف المايك بسبب الصمت (${_listeningDurationSec} ثانية)");
    await _sttService.stopListening();
    setState(() {
      _isListening = false;
      _listeningDurationSec = _listeningStartTime != null
          ? DateTime.now().difference(_listeningStartTime!).inSeconds
          : 0;
      _micStatusMsg =
          "⏹️ تم إيقاف المايك بعد $_listeningDurationSec ثانية بسبب الصمت";
    });
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _accelSubscription?.cancel();
    _sttService.stopListening();
    super.dispose();
  }

  void _handleVoiceCommand(String text) {
    print("جارٍ تحليل الأمر الصوتي: $text");

    final textLower = text.toLowerCase().trim();
    final profileCommands = [
      "الملف الشخصي",
      "الحساب",
      "بروفايل",
      "profile",
      "account",
      "أدخل على الحساب",
      "افتح حسابي"
    ];

    for (final key in profileCommands) {
      if (textLower.contains(key)) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage()),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          _announcePage("تم فتح الملف الشخصي");
        });
        return;
      }
    }

    final commands = {
      0: ["الرئيسية", "home", "الصفحة الرئيسية"],
      1: ["القارئ", "reader", "pdf", "قراءة", "بي دي اف"],
      2: ["السجل", "history", "هيستوري", "سجل"],
      3: ["الاتصال", "connectivity", "كونكت", "كونكتيفيتي", "الاتصالات"],
      4: ["الإعدادات", "settings", "ستنجز", "setting", "اعدادات"],
    };

    for (final entry in commands.entries) {
      for (final key in entry.value) {
        if (textLower.contains(key)) {
          context.read<NavigationCubit>().changePage(entry.key);
          Future.delayed(const Duration(milliseconds: 200), () {
            String pageTitle = _getPageTitle(entry.key);
            _announcePage("أنت الآن في صفحة $pageTitle");
          });
          return;
        }
      }
    }
  }

  Future<void> _announcePage(String pageName) async {
    Semantics(
      child: Text(pageName),
      label: pageName,
      excludeSemantics: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: _isListening,
      child: GestureDetector(
        onTap: () {
          if (_isListening) {
            _stopListeningDueToSilence();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.mainGradient,
          ),
          child: BlocBuilder<NavigationCubit, NavigationState>(
            builder: (context, state) {
              if (_lastAnnouncedIndex != state.index) {
                _lastAnnouncedIndex = state.index;
                Future.delayed(const Duration(milliseconds: 200), () {
                  String pageTitle = _getPageTitle(state.index);
                  _announcePage(pageTitle);
                });
              }
              return Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: screens[state.index],
                  ),
                  if (_isListening)
                    ModalBarrier(
                      dismissible: false,
                      color: Colors.black.withOpacity(0.01),
                    ),
                  if (_isListening)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      ignoring: _isListening,
                      child: _buildCustomNavBar(context, state.index),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 90,
                    child: IgnorePointer(
                      ignoring: _isListening,
                      child: FloatingActionButton(
                        heroTag: "stt_fab",
                        onPressed: _startListeningWithTimer,
                        child: Icon(Icons.mic),
                        tooltip: "فعّل التنقل الصوتي",
                      ),
                    ),
                  ),
                  Semantics(
                    excludeSemantics: true,
                    child: Visibility(
                      visible: false,
                      child: Center(
                        child: Text(
                          "الأمر الصوتي: $_lastCommand",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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
            _navItem(context, Icons.history_outlined, 2, selectedIndex),
            _navItem(context, Icons.compare_arrows_outlined, 3, selectedIndex),
            _navItem(context, Icons.settings_outlined, 4, selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context, IconData icon, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    final labels = [
      tr('home'),
      tr('pdfreader'),
      tr('history'),
      tr('connectivity'),
      tr('setting'),
    ];
    return Semantics(
      button: true,
      selected: isSelected,
      label: labels[index],
      child: GestureDetector(
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
      ),
    );
  }
}

String _getPageTitle(int index) {
  switch (index) {
    case 0:
      return "الرئيسية";
    case 1:
      return "القارئ";
    case 2:
      return "السجل";
    case 3:
      return "الاتصال";
    case 4:
      return "الإعدادات";
    default:
      return "";
  }
}
