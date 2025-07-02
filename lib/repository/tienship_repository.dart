import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class TienShipRepository {
  final String baseUrl = ApiService().baseUrl;

  // Lấy danh sách giá ship
  Future<List<Map<String, dynamic>>> getTienShip() async {
    final response = await http.get(Uri.parse('${baseUrl}tien-ship'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['tien_ship']);
    }
    throw Exception('Lấy danh sách giá ship thất bại');
  }

  // Cập nhật giá ship
  Future<bool> updateTienShip(int id, num gia) async {
    final response = await http.put(
      Uri.parse('${baseUrl}tien-ship/1'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'gia': gia}),
    );
    return response.statusCode == 200;
  }
}
