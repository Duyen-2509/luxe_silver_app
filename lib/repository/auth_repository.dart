import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository(this.apiService);

  /// Đăng nhập bằng số điện thoại và mật khẩu
  Future<Map<String, dynamic>> loginWithPhone(
    String phone,
    String password,
  ) async {
    final url = Uri.parse(apiService.baseUrl + 'login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sodienthoai': phone, 'password': password}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {'error': errorData['message'] ?? 'Đăng nhập thất bại'};
      }
    } catch (e) {
      return {'error': 'Không thể kết nối đến server'};
    }
  }

  /// Đăng ký tài khoản mới
  Future<Map<String, dynamic>> registerWithPhone(
    String name,
    String phone,
    String password,
  ) async {
    final url = Uri.parse(apiService.baseUrl + 'register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ten': name,
          'sodienthoai': phone,
          'password': password,
        }),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {'error': errorData['message'] ?? 'Đăng ký thất bại'};
      }
    } catch (e) {
      return {'error': 'Không thể kết nối đến server'};
    }
  }

  /// Đăng nhập Google (gửi dữ liệu lên API Laravel)
  Future<Map<String, dynamic>?> loginWithGoogleApi({
    required String email,
    required String name,
    String? phone,
  }) async {
    final url = Uri.parse(apiService.baseUrl + 'login-google');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'ten': name, 'sodienthoai': phone}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
