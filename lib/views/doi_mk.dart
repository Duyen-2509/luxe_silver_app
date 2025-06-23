import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/dieukien%20.dart';
import 'package:luxe_silver_app/controllers/user_controller.dart';
import 'package:luxe_silver_app/repository/user_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import 'package:luxe_silver_app/views/dang_nhap.dart';
import '../constant/app_color.dart';
import '../constant/app_styles.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String phone;
  const ChangePasswordScreen({super.key, required this.phone});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? passwordError;
  String? confirmPasswordError;

  Future<void> _changePassword() async {
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    bool hasError = false;

    if (!validator.isValid(newPassword)) {
      passwordError = 'Mật khẩu phải ít nhất 8 ký tự và có ký tự đặc biệt!';
      hasError = true;
    }
    if (confirmPassword != newPassword) {
      confirmPasswordError = 'Xác nhận mật khẩu không khớp!';
      hasError = true;
    }
    setState(() {});
    if (hasError) return;

    setState(() => isLoading = true);

    // Gọi controller đổi mật khẩu qua số điện thoại (quên mật khẩu)
    final apiService = ApiService();
    final userRepo = UserRepository(apiService);
    final userController = UserController(userRepo);

    final message = await userController.changePasswordByPhone(
      phone: widget.phone,
      newPassword: newPassword,
    );

    setState(() => isLoading = false);

    if (message == 'Đổi mật khẩu thành công') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message!)));
      // Chuyển về màn hình đăng nhập và xóa hết các màn hình trước đó
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } else if (message != null &&
        message.contains('Không tìm thấy khách hàng')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại chưa đăng ký tài khoản!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message ?? 'Có lỗi xảy ra')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: const Icon(Icons.lock),
                border: AppStyles.textFieldBorder,
                errorText: passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.buttonBackground,
              ),
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                        'Đổi mật khẩu',
                        style: TextStyle(color: AppColors.buttonText),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
