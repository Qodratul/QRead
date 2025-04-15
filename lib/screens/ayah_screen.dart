import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../service/apiQuran.dart';
import '../service/bookmark_service.dart';

class AyahScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const AyahScreen({Key? key, required this.surahNumber, required this.surahName}) : super(key: key);

  @override
  State<AyahScreen> createState() => _AyahScreenState();
}

class _AyahScreenState extends State<AyahScreen> {
  final ApiQuran _apiQuran = ApiQuran();
  List<dynamic> _ayahs = [];
  List<dynamic> _translations = [];
  final BookmarkService _bookmarkService = BookmarkService();

  bool _isLoading = true;

  final Map<String, String> _translationOptions = {
    'en.asad': 'English (Asad)',
    'id.indonesian': 'Indonesian',
  };

  String _selectedTranslation = 'en.asad';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ayahs = await _apiQuran.getAyahs(widget.surahNumber);
      final translations = await _apiQuran.getTranslations(widget.surahNumber, _selectedTranslation);
      final audios = await _apiQuran.getAudios(widget.surahNumber);

      if (widget.surahNumber != 1 && ayahs.isNotEmpty) {
        ayahs[0]['text'] = ayahs[0]['text'].replaceFirst(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '');
      }

      // Attach audio URLs to each ayah
      for (int i = 0; i < ayahs.length; i++) {
        ayahs[i]['audio'] = audios[i]['audio'];
      }

      setState(() {
        _ayahs = ayahs;
        _translations = translations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTranslationChanged(String? newTranslation) {
    if (newTranslation != null) {
      setState(() {
        _selectedTranslation = newTranslation;
      });
      _fetchData();
    }
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAll = false;
  int? _currentAudioIndex;
  int? _currentlyPlayingAyah;
  bool _isAudioPlaying = false;
  StreamSubscription<void>? _audioCompleteSubscription;

  Future<void> _playAllAudios({required int startIndex}) async {
    if (_isPlayingAll) {
      // Stop playback
      await _stopAllAudio();
    } else {
      setState(() {
        _isPlayingAll = true;
        _currentAudioIndex = startIndex;
      });
      _startAudioSequence();
    }
  }

  Future<void> _stopAllAudio() async {
    await _audioPlayer.stop();
    await _audioCompleteSubscription?.cancel();
    setState(() {
      _isPlayingAll = false;
      _currentlyPlayingAyah = null;
      _currentAudioIndex = null;
      _isAudioPlaying = false;
    });
  }

  Future<void> _startAudioSequence() async {
    while (_isPlayingAll && _currentAudioIndex != null && _currentAudioIndex! < _ayahs.length) {
      final ayahIndex = _currentAudioIndex!;
      final audioUrl = _ayahs[ayahIndex]['audio'];

      setState(() {
        _currentlyPlayingAyah = ayahIndex;
        _isAudioPlaying = true;
      });

      try {
        await _audioPlayer.play(UrlSource(audioUrl));
        await _audioPlayer.onPlayerComplete.first;

        setState(() {
          _currentAudioIndex = _currentAudioIndex! + 1;
          _isAudioPlaying = false;
        });

        await Future.delayed(const Duration(milliseconds: 300)); // optional delay
      } catch (e) {
        print('Audio error: $e');
        setState(() {
          _currentAudioIndex = _currentAudioIndex! + 1;
          _isAudioPlaying = false;
        });
      }
    }

    // Done playing all
    await _stopAllAudio();
  }

  Future<void> _saveBookmark(int ayahNumber) async {
    await _bookmarkService.saveLastRead(widget.surahNumber, widget.surahName, ayahNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark saved!')),
    );
  }

  @override
  void dispose() {
    _audioCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.surahName,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              if (_currentlyPlayingAyah != null) {
                _saveBookmark(_currentlyPlayingAyah! + 1);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedTranslation,
              items: _translationOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: _onTranslationChanged,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _ayahs.length,
              itemBuilder: (context, index) {
                final ayah = _ayahs[index];
                final translation = _translations[index];
                final audioUrl = ayah['audio']; // Audio URL from API

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _currentlyPlayingAyah == index
                          ? Colors.green[200] // Highlight color
                          : Colors.green[100],
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: Text(
                              ayah['numberInSurah'].toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  ayah['text'], // Ayah text
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'AlQuran',
                                    height: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  translation['text'], // Translation
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: Icon(
                                    _isPlayingAll && _currentlyPlayingAyah == index
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.green[700],
                                  ),
                                  onPressed: () {
                                    _playAllAudios(startIndex: index);
                                  },
                                ),
                              ],
                            ),
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
    );
  }
}
