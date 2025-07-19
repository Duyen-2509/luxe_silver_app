import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class VoucherRepository {
  // Lấy danh sách voucher
  Future<List<Map<String, dynamic>>> getVouchers() async {
    final response = await http.get(
      Uri.parse('${ApiService().baseUrl}voucher'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['voucher'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Không lấy được danh sách voucher');
    }
  }

  // Lấy danh sách loại voucher
  Future<List<Map<String, dynamic>>> getVoucherTypesRaw() async {
    final response = await http.get(
      Uri.parse('${ApiService().baseUrl}loai-voucher'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['loai_voucher'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Không lấy được danh sách loại voucher');
    }
  }

  // Thêm voucher mới
  Future<bool> addVoucher(Map<String, dynamic> voucherData) async {
    print('Dữ liệu gửi lên: $voucherData');
    final response = await http.post(
      Uri.parse('${ApiService().baseUrl}voucher'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(voucherData),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Cập nhật voucher
  Future<bool> updateVoucher(int id, Map<String, dynamic> voucherData) async {
    final response = await http.put(
      Uri.parse('${ApiService().baseUrl}voucher/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(voucherData),
    );
    return response.statusCode == 200;
  }

  // Ẩn vouvher
  Future<bool> hideVoucher(int id) async {
    final response = await http.post(
      Uri.parse('${ApiService().baseUrl}voucher/hide/$id'),
    );
    return response.statusCode == 200;
  }

  // giảm
  Future<bool> useVoucher(int id) async {
    final response = await http.post(
      Uri.parse('${ApiService().baseUrl}voucher/use/$id'),
    );
    return response.statusCode == 200;
  }

  // Mở lại voucher
  Future<bool> showVoucher(int id) async {
    final response = await http.post(
      Uri.parse('${ApiService().baseUrl}voucher/show/$id'),
    );
    return response.statusCode == 200;
  }
}
