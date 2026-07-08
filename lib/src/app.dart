import 'package:flutter/material.dart';

import 'controllers/app_controller.dart';
import 'data/app_database.dart';
import 'screens/home_page.dart';

class AssetManagementApp extends StatefulWidget {
  const AssetManagementApp({super.key});

  @override
  State<AssetManagementApp> createState() => _AssetManagementAppState();
}

class _AssetManagementAppState extends State<AssetManagementApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(AppDatabase())..load();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة الأصول',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B6B5F)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8F7),
          foregroundColor: Color(0xFF173832),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(controller: controller),
      ),
    );
  }
}
