import 'package:flutter/material.dart';

import '../constant/app_color.dart';
import '../constant/app_styles.dart';
import '../constant/image.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

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
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Nhập mật khẩu',
                  border: AppStyles.textFieldBorder,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Quên mật khẩu?'),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Xử lý đăng nhập
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
              IconButton(
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: AppStyles.googleIconSize,
                  color: AppColors.googleIconColor,
                ),
                onPressed: () {
                  // Xử lý Google login
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
