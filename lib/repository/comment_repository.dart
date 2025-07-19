import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class CommentRepository {
  final ApiService apiService;
  CommentRepository(this.apiService);

  // Đánh giá sản phẩm
  Future<String?> addComment(Map<String, dynamic> data) async {
    final url = Uri.parse('${apiService.baseUrl}binhluan');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'];
    } else {
      print('API error: ${response.statusCode} - ${response.body}');
      return 'Lỗi: ${response.statusCode} - ${response.body}';
    }
  }

  // Sửa đánh giá
  Future<String?> editComment(int idBl, Map<String, dynamic> data) async {
    final url = Uri.parse('${apiService.baseUrl}binhluan/$idBl');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body)['message'];
  }

  // Xóa đánh giá
  Future<String?> deleteComment(int idBl, int idKh) async {
    final url = Uri.parse('${apiService.baseUrl}binhluan/$idBl');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_kh': idKh}),
    );
    return jsonDecode(response.body)['message'];
  }

  // Nhân viên trả lời bình luận
  Future<String?> replyComment(int idBl, Map<String, dynamic> data) async {
    final url = Uri.parse('${apiService.baseUrl}binhluan/$idBl/traloi');
    print('Gọi API: $url');
    print('Body: $data');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'];
    } else {
      throw Exception('Lỗi: ${response.body}');
    }
  }

  // Lấy danh sách bình luận theo sản phẩm
  Future<List<Map<String, dynamic>>> fetchComments(int idSp) async {
    final url = Uri.parse('${apiService.baseUrl}binhluan/sanpham/$idSp');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['binhluan'] ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchStatistic(int idSp) async {
    final url = Uri.parse('${apiService.baseUrl}binhluan/thongke/$idSp');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'so_luot': 0, 'trung_binh': 5};
  }

  // Nhân viên xóa trả lời bình luận
  Future<String?> deleteReply(int idCtbl, int idNv) async {
    final url = Uri.parse('${apiService.baseUrl}traloi-binhluan/$idCtbl');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_nv': idNv}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'];
    } else {
      return jsonDecode(response.body)['message'] ?? 'Lỗi xóa trả lời';
    }
  }
}
