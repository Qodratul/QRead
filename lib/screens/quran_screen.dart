import "package:flutter/material.dart";
import '../service/apiQuran.dart';
import '../service/bookmark_service.dart';
import 'ayah_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  QuranScreenState createState() => QuranScreenState();
}

class QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BookmarkService _bookmarkService = BookmarkService();
  List<dynamic> _allSurahs = [];
  List<dynamic> _filteredSurahs = [];
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _fetchSurahs();
    _loadLastRead();
  }

  Future<void> _fetchSurahs() async {
    try {
      final surahs = await ApiQuran().getSurah();
      setState(() {
        _allSurahs = surahs;
        _filteredSurahs = surahs;
      });
    } catch (e) {
      print('Error fetching surahs: $e');
    }
  }

  void _filterSurahs(String query) {
    final filtered = _allSurahs.where((surah) {
      final number = surah['number'].toString();
      final englishName = surah['englishName'].toLowerCase();
      final name = surah['name'].toLowerCase();
      final translation = surah['englishNameTranslation'].toLowerCase();
      final searchQuery = query.toLowerCase();

      return number.contains(searchQuery) ||
          englishName.contains(searchQuery) ||
          name.contains(searchQuery) ||
          translation.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredSurahs = filtered;
    });
  }

  Future<void> _loadLastRead() async {
    final lastRead = await _bookmarkService.getLastRead();
    setState(() {
      _lastRead = lastRead;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text(
            "Quran",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (_lastRead != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AyahScreen(
                        surahNumber: _lastRead!['surahNumber'],
                        surahName: _lastRead!['surahName'],
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.green[100],
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue Reading',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Surah: ${_lastRead!['surahName']} (No. ${_lastRead!['surahNumber']})',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Ayah: ${_lastRead!['ayahNumber']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSurahs,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20.0),
                  ),
                ),
              ),
            ),
            // Surah List
            Expanded(
              child: _filteredSurahs.isEmpty
                  ? const Center(child: Text('No Surah found'))
                  : ListView.builder(
                itemCount: _filteredSurahs.length,
                itemBuilder: (context, index) {
                  final surah = _filteredSurahs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AyahScreen(surahNumber: surah['number'],
                                  surahName: surah['englishName']),
                            ),
                          );
                        },
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Transform.rotate(
                                angle: 0.785398,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.grey.withOpacity(0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: -0.785398,
                                      child: Text(
                                        surah['number'].toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surah['englishName'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    surah['englishNameTranslation'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                      Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  surah['name']
                                      .replaceAll('سُورَةُ ', ''),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'AlQuran',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${surah['numberOfAyahs']} ayah',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                    Colors.black.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}