import '../repository/hoadon_repository.dart';

class HoaDonController {
  final HoaDonRepository _repository = HoaDonRepository();

  Future<List<Map<String, dynamic>>> fetchHoaDonList() async {
    return await _repository.getHoaDonList();
  }

  Future<List<Map<String, dynamic>>> fetchChiTietHoaDon(String mahd) async {
    return await _repository.getChiTietHoaDon(mahd);
  }

  Future<List<Map<String, dynamic>>> fetchTrangThaiHoaDon() async {
    return await _repository.getTrangThaiHoaDon();
  }

  Future<Map<String, dynamic>> addHoaDon(Map<String, dynamic> data) async {
    return await _repository.addHoaDon(data);
  }

  Future<bool> updateTrangThaiHoaDon(
    String mahd,
    int idTtdh, {
    int? idNv,
  }) async {
    return await _repository.updateTrangThaiHoaDon(mahd, idTtdh, idNv: idNv);
  }

  Future<bool> updateNhanVien(String mahd, int idNv) async {
    return await _repository.updateNhanVien(mahd, idNv);
  }
}
