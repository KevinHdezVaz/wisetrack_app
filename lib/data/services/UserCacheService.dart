import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/User/UserDetail.dart';
 
class UserCacheService {
  static const String _userCacheKey = 'current_user_data';

  /// Guarda el objeto UserData en SharedPreferences convirtiéndolo a un String JSON.
  static Future<void> saveUserData(UserData userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = json.encode(userData.toJson());
      await prefs.setString(_userCacheKey, userJsonString);
      print('User data saved to cache.');
    } catch (e) {
      print('Failed to save user data to cache: $e');
    }
  }

  /// Lee el String JSON de SharedPreferences y lo convierte de nuevo a un objeto UserData.
  /// Devuelve null si no hay datos guardados.
  static Future<UserData?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userCacheKey);

      if (userJsonString != null) {
        print('User data found in cache.');
        return UserData.fromJson(json.decode(userJsonString));
      }
    } catch (e) {
      print('Failed to retrieve user data from cache: $e');
    }
    print('No user data in cache.');
    return null;
  }

  /// Limpia los datos del usuario de la caché. Esencial para el logout.
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
    print('User data cleared from cache.');
  }
}