import 'package:flutter/material.dart';
import 'package:luxe_silver_app/views/home_screen.dart';
import '../constant/app_color.dart';
import '../constant/app_styles.dart';
import '../constant/image.dart';
import '../constant/dieukien .dart';
import '../repository/auth_repository.dart';
import '../services/api_service.dart';
import '../controllers/login_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Khởi tạo repository để gọi API
  final AuthRepository authRepository = AuthRepository(ApiService());
  final loginController = LoginController();

  // Controller cho các ô nhập liệu
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Biến điều khiển ẩn/hiện mật khẩu
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Biến lưu lỗi để hiển thị dưới ô nhập
  String? passwordError;
  String? confirmPasswordError;

  /// Hàm xử lý đăng ký
  void _signUp(BuildContext context) async {
    // Reset lỗi trước khi kiểm tra
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    // Lấy dữ liệu từ các ô nhập
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Kiểm tra các ô không được để trống
    if (name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    // Kiểm tra điều kiện mật khẩu
    if (!PasswordValidator.isValid(password)) {
      setState(() {
        passwordError = 'Mật khẩu phải ít nhất 8 ký tự và có ký tự đặc biệt!';
      });
      return;
    }

    // Kiểm tra nhập lại mật khẩu
    if (password != confirmPassword) {
      setState(() {
        confirmPasswordError = 'Nhập lại mật khẩu không khớp!';
      });
      return;
    }

    // Gọi API đăng ký
    final result = await authRepository.registerWithPhone(
      name,
      phone,
      password,
    );

    if (result.containsKey('id')) {
      // Đăng ký thành công, chuyển sang trang đăng nhập
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
      Navigator.pop(context); // Quay về trang đăng nhập
    } else {
      // Đăng ký thất bại, hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Đăng ký thất bại')),
      );
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi không dùng nữa
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
              // Logo
              Image.asset(AppImages.logo, width: 500, height: 300),
              // Ô nhập họ tên
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Họ tên',
                  border: AppStyles.textFieldBorder,
                ),
              ),
              const SizedBox(height: 16),
              // Ô nhập số điện thoại
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  labelText: 'Số điện thoại',
                  border: AppStyles.textFieldBorder,
                ),
              ),
              const SizedBox(height: 16),
              // Ô nhập mật khẩu
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Mật khẩu',
                  border: AppStyles.textFieldBorder,
                  errorText: passwordError, // Hiển thị lỗi ở đây
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
              const SizedBox(height: 16),
              // Ô nhập lại mật khẩu
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: 'Nhập lại mật khẩu',
                  border: AppStyles.textFieldBorder,
                  errorText: confirmPasswordError, // Hiển thị lỗi ở đây
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Nút đăng ký
              ElevatedButton(
                onPressed: () => _signUp(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.buttonBackground,
                ),
                child: const Text(
                  'Đăng ký',
                  style: TextStyle(color: AppColors.buttonText),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Hoặc'),
              // Nút đăng ký bằng Google (nếu có)
              IconButton(
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: AppStyles.googleIconSize,
                  color: AppColors.googleIconColor,
                ),
                onPressed: () async {
                  final userData = await loginController.loginWithGoogle();
                  if (userData != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(userData: userData),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đăng nhập Google thất bại!'),
                      ),
                    );
                  }
                },
              ),
              // Đường dẫn chuyển sang đăng nhập
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bạn đã có tài khoản?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Đăng nhập'),
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
