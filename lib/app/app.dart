import 'package:flutter/material.dart';
import '../features/auth/splash_page.dart';
import 'theme.dart';

class MobileSmileApp extends StatelessWidget {
  const MobileSmileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Smile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}