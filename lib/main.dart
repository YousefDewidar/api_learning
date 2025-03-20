import 'package:flutter/material.dart';
import 'package:quran_library/quran.dart';


void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        useMaterial3: false,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: false,
      ),

      // home: WebScrapingScreen(),
      home: const QuranTestApp(),
    );
  }
}

class QuranTestApp extends StatefulWidget {
  const QuranTestApp({super.key});

  @override
  State<QuranTestApp> createState() => _QuranTestAppState();
}

class _QuranTestAppState extends State<QuranTestApp> {
  @override
  void initState() {
    super.initState();
    QuranLibrary().init();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: QuranLibraryScreen(),

    );
  }
}
