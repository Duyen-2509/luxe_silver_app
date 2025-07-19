import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sanPham_model.dart';
import '../services/api_service.dart';

class ProductDataRepository {
  final ApiService apiService;
  ProductDataRepository(this.apiService);

  Future<List<SanPham>> fetchProducts() async {
    final response = await http.get(Uri.parse('${apiService.baseUrl}products'));
    print('############################################');
    print(response.body);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['products'];
      return data.map((json) => SanPham.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<SanPham> fetchProductDetail(int id) async {
    final response = await http.get(
      Uri.parse('${apiService.baseUrl}products/$id'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['product'];
      return SanPham.fromJson(data);
    } else {
      throw Exception('Failed to load product detail');
    }
  }
}
