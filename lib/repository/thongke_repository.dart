import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ThongKeRepository {
  final String baseUrl = ApiService().baseUrl;

  Future<Map<String, dynamic>> fetchThongKe({
    required String kieu, // 'ngay', 'thang', 'nam'
    String? ngay,

    int? thang,
    int? nam,
  }) async {
    final params = <String, dynamic>{'kieu': kieu};
    if (ngay != null) params['ngay'] = ngay;

    if (thang != null) params['thang'] = thang.toString();
    if (nam != null) params['nam'] = nam.toString();

    final uri = Uri.parse('${baseUrl}thongke').replace(queryParameters: params);
    final response = await http.get(uri);
    print('API url: $uri');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Lấy thống kê thất bại');
    }
  }
}
