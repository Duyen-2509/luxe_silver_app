import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class HoaDonRepository {
  final String baseUrl = ApiService().baseUrl;

  Future<List<Map<String, dynamic>>> getHoaDonList() async {
    final response = await http.get(Uri.parse('${baseUrl}hoadon'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['hoadon']);
    }
    throw Exception('Lấy danh sách hóa đơn thất bại');
  }

  Future<List<Map<String, dynamic>>> getChiTietHoaDon(String mahd) async {
    final response = await http.get(
      Uri.parse('${baseUrl}hoadon/$mahd/chitiet'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['chitiet_hd']);
    }
    throw Exception('Lấy chi tiết hóa đơn thất bại');
  }

  Future<List<Map<String, dynamic>>> getTrangThaiHoaDon() async {
    final response = await http.get(Uri.parse('${baseUrl}trangthai-hoadon'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['trangthai_hd']);
    }
    throw Exception('Lấy trạng thái hóa đơn thất bại');
  }

  Future<Map<String, dynamic>> addHoaDon(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${baseUrl}hoadon/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Tạo hóa đơn thất bại');
  }

  Future<bool> updateTrangThaiHoaDon(
    String mahd,
    int idTtdh, {
    int? idNv,
  }) async {
    final body = {'id_ttdh': idTtdh};
    if (idNv != null) body['id_nv'] = idNv;
    final response = await http.put(
      Uri.parse('${baseUrl}hoadon/$mahd/trangthai'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateNhanVien(String mahd, int idNv) async {
    final response = await http.put(
      Uri.parse('${baseUrl}hoadon/$mahd/nhanvien'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_nv': idNv}),
    );
    return response.statusCode == 200;
  }
}
