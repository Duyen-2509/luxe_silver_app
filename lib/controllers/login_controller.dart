import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luxe_silver_app/repository/auth_repository.dart';

import '../services/api_service.dart';

class LoginController {
  final ApiService apiService = ApiService();

  late final AuthRepository authRepository = AuthRepository(apiService);

  /// Đăng nhập bằng số điện thoại và mật khẩu
  /// Trả về true nếu thành công, false nếu thất bại
  Future<bool> login(String phone, String password) async {
    final response = await authRepository.loginWithPhone(phone, password);
    if (response.containsKey('id') && response.containsKey('sodienthoai')) {
      // Có thể lưu thông tin user vào local nếu cần
      return true;
    }
    return false;
  }

  /// Đăng nhập và trả về dữ liệu user nếu thành công, null nếu thất bại
  Future<Map<String, dynamic>?> loginAndGetUser(
    String phone,
    String password,
  ) async {
    final response = await authRepository.loginWithPhone(phone, password);
    if (response.containsKey('id') && response.containsKey('sodienthoai')) {
      return response;
    }
    return null;
  }

  /// Đăng nhập Google và trả về userData nếu thành công, null nếu thất bại
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập với Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final email = user.email ?? '';
        final name = user.displayName ?? '';
        final phone = user.phoneNumber;

        // Gọi AuthRepository để gửi dữ liệu lên API Laravel
        return await authRepository.loginWithGoogleApi(
          email: email,
          name: name,
          phone: phone,
          token: googleAuth.idToken ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
