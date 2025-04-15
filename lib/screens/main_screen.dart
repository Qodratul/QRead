import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'hadist_screen.dart';
import 'quran_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  int _selectedIndex = 0;
  List<Widget> _widgetsList = [HomeScreen(), QuranScreen(), HadistScreen()];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: _widgetsList[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.green,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: Colors.white, // Change this to your desired color
            unselectedItemColor: Colors.black, // Optional: Set color for unselected items
            items: const [
              BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(FlutterIslamicIcons.solidQuran), label: "Quran"),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Hadist'),
            ],
          ),
        )
    );
  }
}
