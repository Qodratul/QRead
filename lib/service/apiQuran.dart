import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiQuran {
  final String baseUrl = 'http://api.alquran.cloud/v1';

  //surah fecth
  Future<List<dynamic>> getSurah() async {
    final response = await http.get(Uri.parse('$baseUrl/surah'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data']; // ini memang List
    } else {
      throw Exception('Failed to load surah');
    }
  }

  // Fetch Ayahs
  Future<List<dynamic>> getAyahs(int surahNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/surah/$surahNumber/quran-simple'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data']['ayahs'];
      return data;
    } else {
      throw Exception('Failed to load ayahs');
    }
  }

  // Fetch Translations
  Future<List<dynamic>> getTranslations(int surahNumber, String selectedTranslation) async {
    final response = await http.get(Uri.parse('$baseUrl/surah/$surahNumber/$selectedTranslation'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data']['ayahs'];
      return data;
    } else {
      throw Exception('Failed to load translations');
    }
  }

  Future<List<dynamic>> getAudios(int surahNumber) async {
      final response = await http.get(Uri.parse('$baseUrl/surah/$surahNumber/ar.abdulbasitmurattal'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data']['ayahs'];
      return data;
    } else {
      throw Exception('Failed to load ayahs');
    }
  }
}


