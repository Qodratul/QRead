import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../service/apiQuran.dart';
import '../service/bookmark_service.dart';
import '../main.dart';

class AyahScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int? bookmarkedAyahNumber;

  const AyahScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.bookmarkedAyahNumber,
  });

  @override
  State<AyahScreen> createState() => _AyahScreenState();
}

class _AyahScreenState extends State<AyahScreen> {
  final ApiQuran _apiQuran = ApiQuran();
  List<dynamic> _ayahs = [];
  List<dynamic> _translations = [];
  final BookmarkService _bookmarkService = BookmarkService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isPlayingAll = false;
  int? _currentAudioIndex;
  int? _currentlyPlayingAyah;
  StreamSubscription<void>? _audioCompleteSubscription;

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

  @override
  void dispose() {
    _audioCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ayahs = await _apiQuran.getAyahs(widget.surahNumber);
      final translations = await _apiQuran.getTranslations(widget.surahNumber, _selectedTranslation);
      final audios = await _apiQuran.getAudios(widget.surahNumber);

      // Remove bismillah from beginning except for surah Al-Fatihah
      if (widget.surahNumber != 1 && ayahs.isNotEmpty) {
        ayahs[0]['text'] = ayahs[0]['text'].replaceFirst(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '');
      }

      // Add audio URLs to ayahs
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
    if (newTranslation != null && newTranslation != _selectedTranslation) {
      setState(() {
        _selectedTranslation = newTranslation;
      });
      _fetchData();
    }
  }

  Future<void> _playAllAudios({required int startIndex}) async {
    if (_isPlayingAll) {
      await _stopAllAudio();
    } else {
      await _stopAllAudio(); // Make sure previous audio is stopped
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
    });
  }

  Future<void> _startAudioSequence() async {
    while (_isPlayingAll && _currentAudioIndex != null && _currentAudioIndex! < _ayahs.length) {
      final index = _currentAudioIndex!;
      final audioUrl = _ayahs[index]['audio'];

      setState(() {
        _currentlyPlayingAyah = index;
      });

      try {
        await _audioPlayer.play(UrlSource(audioUrl));
        await _audioPlayer.onPlayerComplete.first;

        if (!_isPlayingAll) break;

        setState(() {
          _currentAudioIndex = index + 1;
        });

        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('Audio error: $e');
        setState(() {
          _currentAudioIndex = index + 1;
        });
      }
    }

    await _stopAllAudio();
  }

  Future<void> _saveBookmark(int ayahNumber) async {
    await _bookmarkService.saveLastRead(
      widget.surahNumber,
      widget.surahName,
      ayahNumber,
    );

    // Show feedback to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmark saved for ayah $ayahNumber'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<bool> _isBookmarked(int ayahNumber) async {
    final lastRead = await _bookmarkService.getLastRead();
    return lastRead != null &&
        lastRead['surahNumber'] == widget.surahNumber &&
        lastRead['ayahNumber'] == ayahNumber;
  }

  // Get the list of ayahs to display (filtered to start from bookmark if one exists)
  List<dynamic> get _displayedAyahs {
    if (widget.bookmarkedAyahNumber != null) {
      int bookmarkIndex = _ayahs.indexWhere(
              (ayah) => ayah['numberInSurah'] == widget.bookmarkedAyahNumber
      );

      if (bookmarkIndex >= 0) {
        // Start exactly at the bookmarked ayah
        return _ayahs.sublist(bookmarkIndex);
      }
    }

    return _ayahs;
  }

  // Get translations for displayed ayahs
  List<dynamic> get _displayedTranslations {
    if (widget.bookmarkedAyahNumber != null) {
      int bookmarkIndex = _ayahs.indexWhere(
              (ayah) => ayah['numberInSurah'] == widget.bookmarkedAyahNumber
      );

      if (bookmarkIndex >= 0) {
        // Start exactly at the bookmarked ayah
        return _translations.sublist(bookmarkIndex);
      }
    }

    return _translations;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.surahName,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).appBarTheme.iconTheme?.color,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      )
          : Column(
          children: [
      // Translation Selector
      Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode
            ? colorScheme.surface.withOpacity(0.8)
            : colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTranslation,
          icon: Icon(
            Icons.arrow_drop_down,
            color: colorScheme.primary,
          ),
          isExpanded: true,
          dropdownColor: isDarkMode
              ? colorScheme.surface
              : colorScheme.surface,
          style: TextStyle(
            color: isDarkMode
                ? colorScheme.tertiary
                : colorScheme.tertiary,
            fontSize: 16,
          ),
          items: _translationOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: _onTranslationChanged,
        ),
      ),
    ),
            // Bookmark indicator
            if (widget.bookmarkedAyahNumber != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? colorScheme.secondary.withOpacity(0.2)
                      : colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark,
                      color: colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Starting from bookmarked Ayah ${widget.bookmarkedAyahNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? colorScheme.tertiary
                            : colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),

            // Ayah list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _displayedAyahs.length,
                itemBuilder: (context, displayIndex) {
                  final ayah = _displayedAyahs[displayIndex];
                  final translation = _displayedTranslations[displayIndex];
                  final ayahNumber = ayah['numberInSurah'];

                  // Calculate original index for audio playback
                  final originalIndex = _ayahs.indexWhere(
                          (originalAyah) => originalAyah['numberInSurah'] == ayahNumber
                  );

                  return FutureBuilder<bool>(
                    future: _isBookmarked(ayahNumber),
                    builder: (context, snapshot) {
                      final isBookmarked = snapshot.data == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: isBookmarked
                              ? colorScheme.secondary.withOpacity(0.15)
                              : _currentlyPlayingAyah == originalIndex
                              ? colorScheme.primary.withOpacity(0.15)
                              : isDarkMode
                              ? colorScheme.surface.withOpacity(0.4)
                              : colorScheme.surface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: isBookmarked
                              ? Border.all(color: colorScheme.secondary, width: 2.0)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ayah number row
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isBookmarked
                                          ? colorScheme.secondary
                                          : colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        ayahNumber.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Control buttons
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          (_isPlayingAll && _currentlyPlayingAyah == originalIndex)
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_filled,
                                          color: isBookmarked
                                              ? colorScheme.secondary
                                              : colorScheme.primary,
                                          size: 32,
                                        ),
                                        onPressed: () => _playAllAudios(startIndex: originalIndex),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: isBookmarked
                                              ? colorScheme.secondary
                                              : isDarkMode
                                              ? colorScheme.tertiary.withOpacity(0.6)
                                              : colorScheme.tertiary.withOpacity(0.6),
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          _saveBookmark(ayahNumber);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Arabic text
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    ayah['text'],
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 26,
                                      height: 1.8,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? colorScheme.tertiary
                                          : colorScheme.tertiary,
                                      fontFamily: 'AlQuran',
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Translation text
                              Text(
                                translation['text'],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: isDarkMode
                                      ? colorScheme.tertiary.withOpacity(0.85)
                                      : colorScheme.tertiary.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
      ),
    );
  }
}