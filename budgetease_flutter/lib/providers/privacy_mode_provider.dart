import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Privacy Mode Provider for blurring sensitive amounts
class PrivacyModeProvider extends ChangeNotifier {
  bool _isPrivacyMode = false;
  static const String _key = 'privacy_mode_enabled';

  bool get isPrivacyMode => _isPrivacyMode;

  /// Initialize privacy mode from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPrivacyMode = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  /// Toggle privacy mode on/off
  Future<void> toggle() async {
    _isPrivacyMode = !_isPrivacyMode;
    
    // Save to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isPrivacyMode);
    
    // Haptic feedback
    // HapticFeedback.mediumImpact(); // Will add later
    
    notifyListeners();
  }

  /// Set privacy mode explicitly
  Future<void> setPrivacyMode(bool enabled) async {
    if (_isPrivacyMode == enabled) return;
    
    _isPrivacyMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
    notifyListeners();
  }
}
