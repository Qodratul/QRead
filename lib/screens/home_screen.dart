import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'quran_screen.dart';
import 'hadist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text(
                "Home",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
              centerTitle: true,
            ),
        )
    );
  }
}

