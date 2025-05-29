import 'package:flutter/material.dart';
import 'constant/app_color.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';

void main() {
  runApp(const LuxeSilverApp());
}

class LuxeSilverApp extends StatelessWidget {
  const LuxeSilverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxeSilver',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      theme: ThemeData(scaffoldBackgroundColor: AppColors.background),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
