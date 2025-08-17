import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../core/theme/app_theme.dart';
import '../cubit/navigation/navigation_cubit.dart';
import '../cubit/navigation/navigation_state.dart';
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
  double? _lastX, _lastY, _lastZ;
  int _shakeCount = 0;
  DateTime? _firstShakeTime;
  static const int shakeTimeoutMs = 3000;
  static const double shakeSensitivity = 15;

  Timer? _silenceTimer;

  DateTime? _listeningStartTime;
  int _listeningDurationSec = 0;
  String _micStatusMsg = "";

  @override
  void initState() {
    super.initState();

    _sttService.initialize(
      onResult: (text) {
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "⏹️ تم إيقاف المايك بعد $_listeningDurationSec ثانية (انتهاء الجلسة)",
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );

    _accelSubscription = accelerometerEvents.listen(_handleAccelerometer);
  }

  void _handleAccelerometer(AccelerometerEvent event) async {
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    if (_lastX != null && _lastY != null && _lastZ != null) {
      double deltaX = (x - _lastX!).abs();
      double deltaY = (y - _lastY!).abs();
      double deltaZ = (z - _lastZ!).abs();

      double shake = deltaX + deltaY + deltaZ;

      if (shake > shakeSensitivity) {
        final now = DateTime.now();
        if (_firstShakeTime == null ||
            now.difference(_firstShakeTime!) > Duration(milliseconds: shakeTimeoutMs)) {
          _firstShakeTime = now;
          _shakeCount = 1;
        } else {
          _shakeCount++;
          if (_shakeCount >= 2) {
            _startListeningWithTimer();
            _shakeCount = 0;
            _firstShakeTime = null;
          }
        }
      }
    }
    _lastX = x;
    _lastY = y;
    _lastZ = z;
  }

  void _startListeningWithTimer() async {
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
    await _sttService.stopListening();
    setState(() {
      _isListening = false;
      _listeningDurationSec = _listeningStartTime != null
          ? DateTime.now().difference(_listeningStartTime!).inSeconds
          : 0;
      _micStatusMsg =
      "⏹️ تم إيقاف المايك بعد $_listeningDurationSec ثانية بسبب الصمت";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "⏹️ تم إيقاف المايك بعد $_listeningDurationSec ثانية بسبب الصمت",
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _accelSubscription?.cancel();
    _sttService.stopListening();
    super.dispose();
  }

  void _handleVoiceCommand(String text) {
    final textLower = text.toLowerCase().trim();

    final commands = {
      0: ["الرئيسية", "home", "هوم", "الصفحة الرئيسية"],
      1: ["القارئ", "reader", "pdf", "قراءة", "بي دي اف"],
      2: ["السجل", "history", "هيستوري", "سجل"],
      3: ["الاتصال", "connectivity", "كونكت", "كونكتيفيتي", "الاتصالات"],
      4: ["الإعدادات", "settings", "ستنجز", "setting", "اعدادات"],
    };

    for (final entry in commands.entries) {
      for (final key in entry.value) {
        if (textLower.contains(key)) {
          context.read<NavigationCubit>().changePage(entry.key);
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("لم يتم التعرف على أمر تنقل!")),
    );
  }

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
            body: Stack(
              children: [
                screens[state.index],
                if (_isListening)
                  Positioned(
                    left: 0, right: 0, bottom: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_lastCommand.isNotEmpty)
                  Positioned(
                    left: 0, right: 0, bottom: 94,
                    child: Center(child: Text(
                      "الأمر الصوتي: $_lastCommand",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )),
                  ),
                if (_micStatusMsg.isNotEmpty)
                  Positioned(
                    left: 0, right: 0, bottom: 170,
                    child: Center(child: Text(
                      _micStatusMsg,
                      style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                    )),
                  ),
              ],
            ),
            bottomNavigationBar: _buildCustomNavBar(context, state.index),
            floatingActionButton: FloatingActionButton(
              heroTag: "stt_fab",
              onPressed: _startListeningWithTimer,
              child: Icon(Icons.mic),
              tooltip: "فعّل التنقل الصوتي",
            ),
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
