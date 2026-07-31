import 'package:shared_preferences/shared_preferences.dart';

/// Servicio singleton de preferencias del usuario (persistidas con
/// SharedPreferences): velocidad, tamaño de letra, tema, etc.
class SettingsService {
  SettingsService._internal();
  static final SettingsService instance = SettingsService._internal();

  int speed = 3; // 1..5
  double fontSize = 42;
  bool mirrorMode = false;
  bool darkMode = true;
  bool keepScreenOn = true;
  bool highlightNumbers = true;
  bool highlightLaws = true;
  bool highlightDates = true;
  bool highlightMoney = true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    speed = prefs.getInt('speed') ?? 3;
    fontSize = prefs.getDouble('fontSize') ?? 42;
    mirrorMode = prefs.getBool('mirrorMode') ?? false;
    darkMode = prefs.getBool('darkMode') ?? true;
    keepScreenOn = prefs.getBool('keepScreenOn') ?? true;
    highlightNumbers = prefs.getBool('highlightNumbers') ?? true;
    highlightLaws = prefs.getBool('highlightLaws') ?? true;
    highlightDates = prefs.getBool('highlightDates') ?? true;
    highlightMoney = prefs.getBool('highlightMoney') ?? true;
  }

  Future<void> setSpeed(int value) async {
    speed = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('speed', value);
  }

  Future<void> setFontSize(double value) async {
    fontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', value);
  }

  Future<void> setMirrorMode(bool value) async {
    mirrorMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mirrorMode', value);
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> setKeepScreenOn(bool value) async {
    keepScreenOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepScreenOn', value);
  }

  Future<void> setHighlight(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (key) {
      case 'numbers':
        highlightNumbers = value;
        await prefs.setBool('highlightNumbers', value);
        break;
      case 'laws':
        highlightLaws = value;
        await prefs.setBool('highlightLaws', value);
        break;
      case 'dates':
        highlightDates = value;
        await prefs.setBool('highlightDates', value);
        break;
      case 'money':
        highlightMoney = value;
        await prefs.setBool('highlightMoney', value);
        break;
    }
  }

  /// Convierte el nivel 1-5 en píxeles de scroll por tick (~60fps).
  double get pxPerTick {
    const map = {1: 0.7, 2: 1.3, 3: 2.0, 4: 3.0, 5: 4.2};
    return map[speed] ?? 2.0;
  }

  String get speedLabel {
    const labels = {1: 'Muy lenta', 2: 'Lenta', 3: 'Normal', 4: 'Rápida', 5: 'Muy rápida'};
    return labels[speed] ?? 'Normal';
  }
}
