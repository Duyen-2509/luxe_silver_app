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

  // Xác nhận đã giao hàng (nhân viên)
  Future<bool> daGiaoHang(String mahd) async {
    final response = await http.post(
      Uri.parse('${baseUrl}hoadon/$mahd/da-giao'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  // Xác nhận đã nhận hàng (khách)
  Future<bool> daNhanHang(String mahd) async {
    final response = await http.post(
      Uri.parse('${baseUrl}hoadon/$mahd/da-nhan'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  // Khách gửi yêu cầu trả hàng
  Future<bool> traHang(String mahd, String lyDoKh) async {
    final response = await http.post(
      Uri.parse('${baseUrl}hoadon/$mahd/tra-hang'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ly_do_kh': lyDoKh}),
    );
    return response.statusCode == 200;
  }

  // Khách hủy đơn (chưa giao)
  Future<bool> huyDon(String mahd, String lyDoKh) async {
    final response = await http.post(
      Uri.parse('${baseUrl}hoadon/$mahd/huy'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ly_do_kh': lyDoKh}),
    );
    return response.statusCode == 200;
  }

  // Nhân viên hủy đơn (đã giao hoặc đang xử lý)
  Future<bool> huyDonNV(String mahd, String lyDoNv) async {
    final response = await http.post(
      Uri.parse('${baseUrl}hoadon/$mahd/huy-nv'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ly_do_nv': lyDoNv}),
    );
    return response.statusCode == 200;
  }

  // Duyệt trả hàng (nhân viên)
  Future<bool> duyetTraHang(
    String mahd,
    bool pheDuyet, {
    String? lyDoNv,
  }) async {
    final Map<String, dynamic> body = {'pheduyet': pheDuyet};
    if (lyDoNv != null) body['ly_do_nv'] = lyDoNv;
    final response = await http.post(
      Uri.parse('${baseUrl}hoadon/$mahd/duyet-tra-hang'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return response.statusCode == 200;
  }

  // Các API khác nếu cần (ví dụ: lấy đơn sắp hết hạn, đơn chờ trả hàng, kiểm tra trả hàng...)
  Future<List<Map<String, dynamic>>> getDonSapHetHan() async {
    final response = await http.get(Uri.parse('${baseUrl}hoadon/sap-het-han'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['hoadon']);
    }
    throw Exception('Lấy đơn sắp hết hạn thất bại');
  }

  Future<List<Map<String, dynamic>>> getDonChoTraHang() async {
    final response = await http.get(Uri.parse('${baseUrl}hoadon/cho-tra-hang'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['hoadon']);
    }
    throw Exception('Lấy đơn chờ trả hàng thất bại');
  }

  Future<Map<String, dynamic>> kiemTraTraHang(String mahd) async {
    final response = await http.get(
      Uri.parse('${baseUrl}hoadon/$mahd/kiem-tra-tra-hang'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Kiểm tra trả hàng thất bại');
  }

  // Gán hoặc cập nhật nhân viên xử lý cho đơn hàng
  Future<bool> ganNhanVien(String mahd, int idNv) async {
    final response = await http.post(
      Uri.parse('${baseUrl}hoadon/$mahd/gan-nhan-vien'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_nv': idNv}),
    );
    return response.statusCode == 200;
  }
}
