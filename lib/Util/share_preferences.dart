import 'package:shared_preferences/shared_preferences.dart';

class S1 {
  Future<void> saveValue({required String key, required bool value}) async {
    final SharedPreferences sharePreference = await SharedPreferences.getInstance();
    try {
      // if (kDebugMode) {
      //   print("Token from cache: $value");
      // }
      await sharePreference.setBool(key, value);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getValue({required String key}) async {
    final SharedPreferences sharePreference = await SharedPreferences.getInstance();
    //log("log 1: ${sharePreference.getString(key)}");
    return sharePreference.getBool(key)!;
  }
}
