import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkService {
  static const String _lastReadKey = 'lastRead';

  Future<void> saveLastRead(int surahNumber, String surahName, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();

    final lastReadData = {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await prefs.setString(_lastReadKey, jsonEncode(lastReadData));
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastReadJson = prefs.getString(_lastReadKey);

    if (lastReadJson == null) {
      return null;
    }

    return jsonDecode(lastReadJson) as Map<String, dynamic>;
  }

  Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastReadKey);
  }
}