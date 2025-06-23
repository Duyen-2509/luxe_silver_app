import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ContactRepository {
  final ApiService api = ApiService();

  Future<Map<String, String>> fetchContactInfo(int id) async {
    final response = await http.get(Uri.parse('${api.baseUrl}dat-rieng/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return {
        'phoneNumber': data['sodienthoai'] ?? '',
        'phoneZalo': data['zalo'] ?? '',
      };
    } else {
      throw Exception('Không lấy được thông tin liên hệ');
    }
  }

  Future<bool> updateContactInfo(int id, String phone, String zalo) async {
    final response = await http.put(
      Uri.parse('${api.baseUrl}dat-rieng/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'sodienthoai': phone, 'zalo': zalo}),
    );
    return response.statusCode == 200;
  }
}
