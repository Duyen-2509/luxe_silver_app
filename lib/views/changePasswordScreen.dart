import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<void> _changePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    setState(() => isLoading = true);

    // Gọi API đổi mật khẩu (sửa lại URL cho đúng API của bạn)
    final url = Uri.parse('http://<YOUR_API_URL>/api/change-password');
    final response = await http.post(
      url,
      body: {'phone': widget.phone, 'password': newPassword},
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
      Navigator.pop(context); // Quay lại màn hình trước
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đổi mật khẩu thất bại: ${response.body}')),
      );
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: const Icon(Icons.lock),
                border: AppStyles.textFieldBorder,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
                border: AppStyles.textFieldBorder,
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
