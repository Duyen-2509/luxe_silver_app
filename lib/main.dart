import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:luxe_silver_app/views/thanh_toan.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constant/app_color.dart';
import 'views/dang_nhap.dart';
import 'views/dang_ky.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51RbOzCQeqMqoqiojpkwdBegQKSnSvIJWNN7syWcQIyhw2G3DATUMIIFLaM7LdD6cHO1PJ8GHws7PiIvyQOiOwlWh00rZjTZjPf';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(LuxeSilverApp());
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
