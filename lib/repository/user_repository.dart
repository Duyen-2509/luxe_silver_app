import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository(this.apiService);

  String convertPhoneToVN(String phone) {
    if (phone.startsWith('+84')) {
      return '0' + phone.substring(3);
    }
    return phone;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${apiService.baseUrl}update-profile');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.TOKEN}',
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<String?> changePassword({
    required int idKh,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('${apiService.baseUrl}change-password');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.TOKEN}',
      },
      body: jsonEncode({
        'id_kh': idKh,
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    final data = jsonDecode(response.body);
    if (data['message'] != null) {
      return data['message'];
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int idKh) async {
    final url = Uri.parse('${apiService.baseUrl}get-user/$idKh');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.TOKEN}',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<String?> changePasswordByPhone({
    required String phone,
    required String newPassword,
  }) async {
    final phoneVN = convertPhoneToVN(phone); // Sử dụng hàm chuyển đổi
    final url = Uri.parse('${apiService.baseUrl}change-password-by-phone');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'sodienthoai': phoneVN, 'new_password': newPassword}),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    print('Số điện thoại gửi lên: $phoneVN');

    if (response.headers['content-type']?.contains('application/json') ==
        true) {
      final data = jsonDecode(response.body);
      if (data['message'] != null) {
        return data['message'];
      }
      return 'Có lỗi xảy ra';
    } else {
      return 'Lỗi server: ${response.statusCode}';
    }
  }

  Future<Map<String, dynamic>> addStaff({
    required String ten,
    required String sodienthoai,
    //required String email,
    required String password,
    String? diachi,
    String? ngaysinh,
    String? gioitinh,
  }) async {
    final url = Uri.parse('${apiService.baseUrl}staff/add');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${ApiService.TOKEN}',
      },
      body: jsonEncode({
        'ten': ten,
        'sodienthoai': sodienthoai,
        // 'email': email,
        'password': password,
        'diachi': diachi,
        'ngaysinh': ngaysinh,
        'gioitinh': gioitinh,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 422) {
      // Trả về lỗi chi tiết cho UI xử lý
      final error = jsonDecode(response.body);
      return Future.error(error['message'] ?? 'Dữ liệu không hợp lệ');
    } else {
      print('Lỗi server: ${response.statusCode}');
      print(response.body);
      throw Exception('Lỗi server');
    }
  }

  Future<Map<String, dynamic>> updateStaff({
    required int idNv,
    String? ten,
    String? diachi,
    String? ngaysinh,
    String? gioitinh,
  }) async {
    final url = Uri.parse('${apiService.baseUrl}staff/update');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.TOKEN}',
      },
      body: jsonEncode({
        'id_nv': idNv,
        if (ten != null) 'ten': ten,
        if (diachi != null) 'diachi': diachi,
        if (ngaysinh != null) 'ngaysinh': ngaysinh,
        if (gioitinh != null) 'gioitinh': gioitinh,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>?> getStaffById(int idNv) async {
    final url = Uri.parse('${apiService.baseUrl}nhan-vien/$idNv');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.TOKEN}',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllStaff() async {
    final url = Uri.parse('${apiService.baseUrl}staff');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.TOKEN}',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> hideStaff(int idNv) async {
    final url = Uri.parse('${apiService.baseUrl}staff/hide');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.TOKEN}',
      },
      body: jsonEncode({'id_nv': idNv}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> unhideStaff(int idNv) async {
    final url = Uri.parse('${apiService.baseUrl}staff/unhide');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.TOKEN}',
      },
      body: jsonEncode({'id_nv': idNv}),
    );
    return jsonDecode(response.body);
  }
}
