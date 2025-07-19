import 'package:flutter/material.dart';
import 'package:luxe_silver_app/views/trang_chu.dart';
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
  String? nameError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  /// Hàm xử lý đăng ký
  void _signUp(BuildContext context) async {
    setState(() {
      nameError = null;
      phoneError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    // Lấy dữ liệu từ các ô nhập
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    bool hasError = false;
    // Kiểm tra các ô không được để trống
    if (name.isEmpty) {
      nameError = 'Vui lòng nhập họ tên!';
      hasError = true;
    }
    if (phone.isEmpty) {
      phoneError = 'Vui lòng nhập số điện thoại!';
      hasError = true;
    } else if (!validator.phoneValidator(phone)) {
      phoneError = 'Số điện thoại không hợp lệ!';
      hasError = true;
    }
    if (password.isEmpty) {
      passwordError = 'Vui lòng nhập mật khẩu!';
      hasError = true;
    } else if (!validator.isValid(password)) {
      passwordError = 'Mật khẩu phải ít nhất 8 ký tự và có ký tự đặc biệt!';
      hasError = true;
    }
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Vui lòng nhập lại mật khẩu!';
      hasError = true;
    } else if (password != confirmPassword) {
      confirmPasswordError = 'Nhập lại mật khẩu không khớp!';
      hasError = true;
    }
    setState(() {});
    if (hasError) return;
    // Thêm kiểm tra số điện thoại hợp lệ
    if (!validator.phoneValidator(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại không hợp lệ!')),
      );
      return;
    }

    // Kiểm tra điều kiện mật khẩu
    if (!validator.isValid(password)) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
      Navigator.pop(context);
    } else {
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
                  errorText: nameError,
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
                  errorText: phoneError,
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
                  errorText: passwordError,
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
                  errorText: confirmPasswordError,
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
