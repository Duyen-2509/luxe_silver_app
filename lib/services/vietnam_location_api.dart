import 'dart:convert';
import 'package:http/http.dart' as http;

// Hàm lấy danh sách tỉnh/thành
Future<List<Map<String, dynamic>>> fetchCities() async {
  final res = await http.get(Uri.parse('https://provinces.open-api.vn/api/p/'));
  final List data = json.decode(utf8.decode(res.bodyBytes));
  return data.cast<Map<String, dynamic>>();
}

// Hàm lấy danh sách quận/huyện theo id tỉnh/thành
Future<List<Map<String, dynamic>>> fetchDistricts(int cityId) async {
  final res = await http.get(
    Uri.parse('https://provinces.open-api.vn/api/p/$cityId?depth=2'),
  );
  final data = json.decode(utf8.decode(res.bodyBytes));
  return (data['districts'] as List).cast<Map<String, dynamic>>();
}

// Hàm lấy danh sách phường/xã theo id quận/huyện
Future<List<Map<String, dynamic>>> fetchWards(int districtId) async {
  final res = await http.get(
    Uri.parse('https://provinces.open-api.vn/api/d/$districtId?depth=2'),
  );
  final data = json.decode(utf8.decode(res.bodyBytes));
  return (data['wards'] as List).cast<Map<String, dynamic>>();
}
