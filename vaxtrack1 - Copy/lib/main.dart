import 'package:flutter/material.dart';
import 'package:vaxtrack/theme.dart';
import 'package:vaxtrack/login_screen.dart';

void main() {
  runApp(const VaxTrackApp());
}

class VaxTrackApp extends StatelessWidget {
  const VaxTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaxTrack - Family Vaccination Companion',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
