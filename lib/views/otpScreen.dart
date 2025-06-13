import 'package:flutter/material.dart';
import 'package:luxe_silver_app/views/changePasswordScreen.dart';
import '../constant/app_color.dart';
import '../constant/app_styles.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  const OtpScreen({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực OTP'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Nhập mã OTP đã gửi đến số\n${widget.phone}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Mã OTP',
                prefixIcon: const Icon(Icons.lock),
                border: AppStyles.textFieldBorder,
              ),
              maxLength: 6,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final otp = otpController.text.trim();
                // TODO: Xử lý xác thực OTP ở đây
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Đã nhập mã OTP: $otp')));
                // Điều hướng sang màn hình đổi mật khẩu nếu xác thực thành công
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChangePasswordScreen(phone: widget.phone),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.buttonBackground,
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: AppColors.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
