import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  // Ensure SharedPreferences is initialized
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Check if onboarding has been seen
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_hasSeenOnboardingKey) ?? false;
    } catch (e) {
      print('Error reading onboarding status: $e');
      return false; // Default to false if there's an error
    }
  }

  // Mark onboarding as seen
  static Future<void> setOnboardingSeen() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_hasSeenOnboardingKey, true);
    } catch (e) {
      print('Error setting onboarding status: $e');
    }
  }
}
