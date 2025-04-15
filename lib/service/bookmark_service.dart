import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _lastReadKey = 'last_read';

  Future<void> saveLastRead(int surahNumber, String surahName, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReadKey, '$surahNumber|$surahName|$ayahNumber');
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRead = prefs.getString(_lastReadKey);
    if (lastRead != null) {
      final parts = lastRead.split('|');
      return {
        'surahNumber': int.parse(parts[0]),
        'surahName': parts[1],
        'ayahNumber': int.parse(parts[2]),
      };
    }
    return null;
  }
}