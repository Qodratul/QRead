import 'package:flutter/material.dart';

class HadistScreen extends StatefulWidget {
  const HadistScreen({super.key});

  @override
  State<HadistScreen> createState() => _HadistScreenState();
}

class _HadistScreenState extends State<HadistScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text(
              "Hadist",
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
