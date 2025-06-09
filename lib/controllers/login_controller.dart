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
}
