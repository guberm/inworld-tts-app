import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tts_settings.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._internal();
  factory SettingsService() => instance;
  SettingsService._internal();

  TTSSettings _settings = TTSSettings();
  TTSSettings get settings => _settings;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('tts_settings');
    if (settingsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(settingsJson);
      _settings = TTSSettings.fromJson(decoded);
    }
  }

  Future<void> saveSettings(TTSSettings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_settings', jsonEncode(settings.toJson()));
  }

  Future<void> updateApiKey(String apiKey) async {
    _settings.apiKey = apiKey;
    await saveSettings(_settings);
  }
}
