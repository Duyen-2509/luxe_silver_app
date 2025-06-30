import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService apiService;
  ProductRepository(this.apiService);
  Future<String?> addProduct({
    required String tensp,
    required String gioitinh,
    required String chatlieu,
    required String tenpk,
    required int idLoai,
    required String mota,
    required String donvi,
    required List<Map<String, String>> sizes,
    required bool isFreesize,
    required List<File> images,
  }) async {
    var uri = Uri.parse('${apiService.baseUrl}add-product');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    request.fields['tensp'] = tensp;
    // Lấy giá đầu tiên để hiển thị ngoài bảng sản phẩm (nếu cần)
    request.fields['gia'] = sizes.isNotEmpty ? (sizes[0]['price'] ?? '0') : '0';
    request.fields['gioitinh'] = gioitinh;
    request.fields['chatlieu'] = chatlieu;
    request.fields['tenpk'] = tenpk;
    request.fields['id_loai'] = idLoai.toString();
    request.fields['mota'] = mota;
    request.fields['donvi'] = donvi;
    request.fields['is_freesize'] = isFreesize ? '1' : '0';
    for (int i = 0; i < sizes.length; i++) {
      request.fields['sizes[$i][size]'] = sizes[i]['size'] ?? '';
      request.fields['sizes[$i][quantity]'] = sizes[i]['quantity'] ?? '';
      request.fields['sizes[$i][price]'] = sizes[i]['price'] ?? '';
      // Nếu cần gửi đơn vị:
      if (sizes[i]['donvi'] != null) {
        request.fields['sizes[$i][donvi]'] = sizes[i]['donvi']!;
      }
    }

    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images[]',
          image.path,
          contentType: MediaType('image', 'jpeg'),
          filename: basename(image.path),
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return 'Thêm sản phẩm thành công';
    } else {
      return 'Lỗi: ${response.body}';
    }
  }

  // Cập nhật sản phẩm
  Future<String?> updateProduct({
    required int id,
    required String tensp,
    required String gioitinh,
    required String chatlieu,
    required String tenpk,
    required int idLoai,
    required String mota,
    required int trangthai,
    List<File>? images,
    List<String>? deleteImages,
    required List<Map<String, String>> sizes,
    required bool isFreesize,
    required String donvi, //
  }) async {
    var uri = Uri.parse('${apiService.baseUrl}products/$id');
    var request = http.MultipartRequest('POST', uri); // Dùng POST + _method=PUT
    request.fields['_method'] = 'PUT';

    request.fields['tensp'] = tensp;
    request.fields['gioitinh'] = gioitinh;
    request.fields['chatlieu'] = chatlieu;
    request.fields['tenpk'] = tenpk;
    request.fields['id_loai'] = idLoai.toString();
    request.fields['mota'] = mota;
    request.fields['trangthai'] = trangthai.toString();
    // Thêm size, donvi, isFreesize
    request.fields['donvi'] = donvi;
    request.fields['is_freesize'] = isFreesize ? '1' : '0';
    for (int i = 0; i < sizes.length; i++) {
      request.fields['sizes[$i][size]'] = sizes[i]['size'] ?? '';
      request.fields['sizes[$i][quantity]'] = sizes[i]['quantity'] ?? '';
      request.fields['sizes[$i][price]'] = sizes[i]['price'] ?? '';
      if (sizes[i]['donvi'] != null) {
        request.fields['sizes[$i][donvi]'] = sizes[i]['donvi']!;
      }
    }
    // Thêm ảnh mới
    if (images != null && images.isNotEmpty) {
      for (var img in images) {
        request.files.add(
          await http.MultipartFile.fromPath('images[]', img.path),
        );
      }
    }

    // Nếu có ảnh cần xóa
    if (deleteImages != null && deleteImages.isNotEmpty) {
      for (var i = 0; i < deleteImages.length; i++) {
        request.fields['delete_images[$i]'] = deleteImages[i];
      }
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return 'Cập nhật sản phẩm thành công';
    } else {
      return 'Lỗi: ${response.body}';
    }
  }

  // Ẩn sản phẩm
  Future<String?> hideProduct(int id) async {
    var uri = Uri.parse('${apiService.baseUrl}products/$id/hide');
    var response = await http.put(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      return 'Ẩn sản phẩm thành công';
    } else {
      return 'Lỗi: ${response.body}';
    }
  }

  // Hiện sản phẩm
  Future<String?> showProduct(int id) async {
    var uri = Uri.parse('${apiService.baseUrl}products/$id/show');
    var response = await http.put(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      return 'Hiện sản phẩm thành công';
    } else {
      return 'Lỗi: ${response.body}';
    }
  }

  // Cập nhật số lượng kho
  Future<String?> updateStock(int id, int soluongKho) async {
    var uri = Uri.parse('${apiService.baseUrl}products/$id/stock');
    var response = await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'soluong_kho': soluongKho}),
    );
    if (response.statusCode == 200) {
      return 'Cập nhật số lượng kho thành công';
    } else {
      return 'Lỗi: ${response.body}';
    }
  }
}
