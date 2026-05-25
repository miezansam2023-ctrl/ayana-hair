import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/panier_manager.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PanierManager(),
      child: const AyanaHairApp(),
    ),
  );
}

class AyanaHairApp extends StatelessWidget {
  const AyanaHairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayana Hair',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFC9A84C),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}