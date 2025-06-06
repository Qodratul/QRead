import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiQuran {
  final String _baseUrl = 'http://api.alquran.cloud/v1';

  Future<List<dynamic>> getSurah() async {
    final response = await http.get(Uri.parse('$_baseUrl/surah'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Failed to load Surahs');
    }
  }

  Future<List<dynamic>> getAyahs(int surahNumber) async {
    final response = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data']['ayahs'];
    } else {
      throw Exception('Failed to load Ayahs');
    }
  }

  Future<List<dynamic>> getJuzs() async {
    List<dynamic> allJuzs = [];
    for (int i = 1; i <= 30; i++) {
      try {
        Map<String, dynamic> juz = await _getJuzMetadata(i);
        allJuzs.add(juz);
      } catch (e) {
        print('Error fetching juz $i: $e');
      }
    }

    return allJuzs;
  }

  Future<Map<String, dynamic>> _getJuzMetadata(int juzNumber) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/juz/$juzNumber'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final juzData = jsonData['data'];

        final surahsMap = juzData['surahs'] as Map<String, dynamic>;
        final surahKeys = surahsMap.keys.toList();
        final surahsList = [];
        int totalVerses = 0;

        for (var key in surahKeys) {
          final surah = surahsMap[key];
          final ayahsCount = (surah['ayahs'] as List).length;
          totalVerses += ayahsCount;

          surahsList.add({
            'number': surah['number'],
            'englishName': surah['englishName'],
            'name': surah['name'],
            'verseCount': ayahsCount,
          });
        }

        return {
          'number': juzNumber,
          'surahs': surahsList,
          'totalVerses': totalVerses,
        };
      } else {
        throw Exception('Failed to load Juz $juzNumber metadata');
      }
    } catch (e) {
      print('Error in _getJuzMetadata for juz $juzNumber: $e');
      return {
        'number': juzNumber,
        'surahs': [],
        'totalVerses': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getJuzDetail(int juzNumber, String edition) async {
    final response = await http.get(Uri.parse('$_baseUrl/juz/$juzNumber/$edition'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to load Juz $juzNumber details');
    }
  }

  Future<List<dynamic>> getTranslations(int surahNumber, String edition) async {
    final response = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber/$edition'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data']['ayahs'];
    } else {
      throw Exception('Failed to load Translations');
    }
  }

  Future<List<dynamic>> getAudios(int surahNumber) async {
    const audioEdition = 'ar.alafasy';
    final response = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber/$audioEdition'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data']['ayahs'];
    } else {
      throw Exception('Failed to load Audio');
    }
  }

  Future<List<dynamic>> getAyahsFromJuz(int juzNumber, String edition) async {
    final response = await http.get(Uri.parse('$_baseUrl/juz/$juzNumber/$edition'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> ayahs = [];
      final surahsMap = jsonData['data']['surahs'] as Map<String, dynamic>;

      surahsMap.forEach((key, surah) {
        final surahAyahs = surah['ayahs'] as List;
        for (var ayah in surahAyahs) {
          ayah['surahNumber'] = surah['number'];
          ayah['surahName'] = surah['englishName'];
          ayahs.add(ayah);
        }
      });

      return ayahs;
    } else {
      throw Exception('Failed to load Ayahs from Juz $juzNumber');
    }
  }
}