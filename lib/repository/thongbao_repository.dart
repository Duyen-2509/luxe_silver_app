import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ThongBaoRepository {
  final String baseUrl = ApiService().baseUrl;

  Future<Map<String, List<dynamic>>> fetchThongBaoKhach(int idKh) async {
    final response = await http.get(
      Uri.parse('${baseUrl}thong-bao/khach/$idKh'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'don_hang': data['don_hang'] ?? [],
        'binh_luan': data['binh_luan'] ?? [],
      };
    } else {
      throw Exception('Lỗi khi lấy thông báo');
    }
  }

  Future<Map<String, List<dynamic>>> fetchThongBaoNhanVien(int idNv) async {
    final response = await http.get(
      Uri.parse('${baseUrl}thong-bao/nhanvien/$idNv'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'don_hang': data['don_hang'] ?? [],
        'binh_luan': data['binh_luan'] ?? [],
      };
    } else {
      throw Exception('Lỗi khi lấy thông báo');
    }
  }

  Future<bool> danhDauDaDoc(int idTb) async {
    final response = await http.post(
      Uri.parse('${baseUrl}thong-bao/danh-dau-da-doc'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id_tb': idTb}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Lỗi khi đánh dấu đã đọc');
    }
  }
}
