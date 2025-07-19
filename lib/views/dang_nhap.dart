import 'package:flutter/material.dart';
import 'package:luxe_silver_app/views/quen_mk.dart';
import 'package:luxe_silver_app/views/trang_chu.dart';
import '../controllers/login_controller.dart';
import '../constant/app_color.dart';
import '../constant/app_styles.dart';
import '../constant/image.dart';
import '../services/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final loginController = LoginController();

  bool _obscurePassword = true;
  Future<void> saveLoginInfo(String token, int id, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('id', id);
    await prefs.setString('role', role);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.logo, width: 500, height: 300),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  labelText: 'Nhập số điện thoại',
                  border: AppStyles.textFieldBorder,
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Nhập mật khẩu',
                  border: AppStyles.textFieldBorder,
                  // Nút hiện/ẩn mật khẩu
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                    ;
                  },
                  child: const Text('Quên mật khẩu?'),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final phone = phoneController.text.trim();
                  final password = passwordController.text;
                  final userData = await loginController.loginAndGetUser(
                    phone,
                    password,
                  );
                  print('userData-------------->: $userData');
                  if (userData != null) {
                    //  nhân viên hoặc admin, gán id_nv cho userData
                    if (userData['role'] == 'admin' ||
                        userData['role'] == 'nhan_vien') {
                      userData['id_nv'] = userData['id_nv'] ?? userData['id'];
                    }

                    // Kiểm tra token
                    final token = userData['token'];
                    if (token != null && token is String && token.isNotEmpty) {
                      if (!userData.containsKey('role') ||
                          userData['role'] == null) {
                        userData['role'] = 'khach_hang';
                      }
                      await saveLoginInfo(
                        token,
                        userData['id_nv'] ?? userData['id'],
                        userData['role'],
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Đăng nhập thất bại: Không nhận được token!',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(userData: userData),
                      ),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sai số điện thoại hoặc mật khẩu'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.buttonBackground,
                ),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(color: AppColors.buttonText),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Hoặc'),
              //gg
              IconButton(
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: AppStyles.googleIconSize,
                  color: AppColors.googleIconColor,
                ),
                onPressed: () async {
                  final userData = await loginController.loginWithGoogle();
                  final token = userData?['token'];
                  if (userData != null &&
                      token != null &&
                      token is String &&
                      token.isNotEmpty) {
                    await saveLoginInfo(
                      token,
                      userData['id_nv'] ?? userData['id'],
                      userData['role'],
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(userData: userData),
                      ),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đăng nhập Google thất bại! Không nhận được token.',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bạn chưa có tài khoản?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Đăng ký'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
