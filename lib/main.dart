import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:luxe_silver_app/controllers/user_controller.dart';
import 'package:luxe_silver_app/repository/user_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import 'package:luxe_silver_app/views/trang_chu_tam.dart';
import 'constant/app_color.dart';
import 'views/dang_nhap.dart';
import 'views/dang_ky.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/trang_chu.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51RbOzCQeqMqoqiojpkwdBegQKSnSvIJWNN7syWcQIyhw2G3DATUMIIFLaM7LdD6cHO1PJ8GHws7PiIvyQOiOwlWh00rZjTZjPf';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Khởi tạo notification
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(LuxeSilverApp());
}

class LuxeSilverApp extends StatelessWidget {
  const LuxeSilverApp({super.key});
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Hàm lấy lại userData từ SharedPreferences và server
  Future<Map<String, dynamic>?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id = prefs.getInt('id');
    final role = prefs.getString('role');
    if (token != null && id != null && role != null) {
      final apiService = ApiService();
      final userRepository = UserRepository(apiService);
      final userController = UserController(userRepository);
      Map<String, dynamic>? user;
      if (role == 'khach_hang') {
        user = await userController.getUserById(id);
      } else {
        user = await userController.getStaffById(id);
      }
      if (user != null) {
        user['role'] = role;
      }
      return user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxeSilver',
      debugShowCheckedModeBanner: false,
      //initialRoute: '/',
      theme: ThemeData(scaffoldBackgroundColor: AppColors.background),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => HomeScreen(userData: {/*...*/}),
      },
      home: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data != null) {
            // Đã đăng nhập, truyền userData vào HomeScreen
            return HomeScreen(userData: snapshot.data!);
          } else {
            // Chưa đăng nhập, vào GuestHomeScreen
            return const GuestHomeScreen();
          }
        },
      ),
    );
  }
}
