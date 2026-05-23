import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();
  ThemeService._internal();

  String _themeMode = 'system';
  String _themeColorKey = 'blue';
  bool _dynamicColorEnabled = false;
  bool _oledEnabled = false;

  String get themeMode => _themeMode;
  String get themeColorKey => _themeColorKey;
  bool get dynamicColorEnabled => _dynamicColorEnabled;
  bool get oledEnabled => _oledEnabled;

  static const Map<String, Color> presetColors = {
    'blue': Colors.blue,
    'teal': Colors.teal,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'red': Colors.red,
    'pink': Colors.pink,
    'green': Colors.green,
  };

  Color get currentSeedColor => presetColors[_themeColorKey] ?? Colors.blue;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getString('themeMode') ?? 'system';
    
    // Backwards compatibility migration
    if (_themeMode == 'oled') {
      _themeMode = 'dark';
      _oledEnabled = true;
      await prefs.setString('themeMode', 'dark');
      await prefs.setBool('oledEnabled', true);
    } else {
      _oledEnabled = prefs.getBool('oledEnabled') ?? false;
    }

    _themeColorKey = prefs.getString('themeColorKey') ?? 'blue';
    _dynamicColorEnabled = prefs.getBool('dynamicColorEnabled') ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
    notifyListeners();
  }

  Future<void> setOledEnabled(bool enabled) async {
    if (_oledEnabled == enabled) return;
    _oledEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('oledEnabled', enabled);
    notifyListeners();
  }

  Future<void> setThemeColorKey(String colorKey) async {
    if (_themeColorKey == colorKey) return;
    _themeColorKey = colorKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColorKey', colorKey);
    notifyListeners();
  }

  Future<void> setDynamicColorEnabled(bool enabled) async {
    if (_dynamicColorEnabled == enabled) return;
    _dynamicColorEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dynamicColorEnabled', enabled);
    notifyListeners();
  }
}
