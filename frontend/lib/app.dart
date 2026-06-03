import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class CosmoApp extends StatelessWidget {
  const CosmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2f7d4f),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfff8faf7),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
