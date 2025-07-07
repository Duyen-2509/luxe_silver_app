import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luxe_silver_app/views/doi_mk.dart';
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
        backgroundColor: AppColors.appBarBackground,
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
              onPressed: () async {
                final otp = otpController.text.trim();

                try {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: otp,
                  );

                  // Đăng nhập với credential
                  await FirebaseAuth.instance.signInWithCredential(credential);

                  // Nếu không lỗi thì OTP đúng
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xác thực OTP thành công!')),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ChangePasswordScreen(phone: widget.phone),
                    ),
                  );
                } catch (e) {
                  // Nếu lỗi thì OTP sai hoặc hết hạn
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mã OTP không hợp lệ hoặc đã hết hạn.'),
                    ),
                  );
                }
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
