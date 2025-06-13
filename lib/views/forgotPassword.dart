import 'package:flutter/material.dart';
import 'package:luxe_silver_app/views/otpScreen.dart';
import '../constant/app_color.dart';
import '../constant/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Nhập số điện thoại để nhận mã OTP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: const Icon(Icons.phone),
                border: AppStyles.textFieldBorder,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                String phone = phoneController.text.trim();
                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập số điện thoại'),
                    ),
                  );
                  return;
                }
                // Chuyển số 0 đầu thành +84
                if (phone.startsWith('0')) {
                  phone = '+84${phone.substring(1)}';
                }
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: phone,
                  timeout: const Duration(seconds: 60),
                  verificationCompleted: (PhoneAuthCredential credential) {},
                  verificationFailed: (FirebaseAuthException e) {
                    print('Lỗi gửi OTP: ${e.code} - ${e.message}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gửi OTP thất bại: ${e.message}')),
                    );
                  },
                  codeSent: (String verificationId, int? resendToken) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã gửi mã OTP đến $phone')),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => OtpScreen(
                              phone: phone,
                              verificationId: verificationId,
                            ),
                      ),
                    );
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {},
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.buttonBackground,
              ),
              child: const Text(
                'Gửi mã OTP',
                style: TextStyle(color: AppColors.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
