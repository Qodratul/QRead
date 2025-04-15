import 'package:app_alquran/screens/home_screen.dart';
import 'package:app_alquran/service/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    _isDarkMode = await ThemeService.getThemePreference();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await ThemeService.saveThemePreference(_isDarkMode);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'QuranRead',
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}