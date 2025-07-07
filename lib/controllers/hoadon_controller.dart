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

  // Xác nhận đã giao hàng (nhân viên)
  Future<bool> daGiaoHang(String mahd) async {
    return await _repository.daGiaoHang(mahd);
  }

  // Xác nhận đã giao tới khách (nhân viên)
  Future<bool> daGiaoToi(String mahd) async {
    return await _repository.daGiaoToi(mahd);
  }

  // Xác nhận đã nhận hàng (khách)
  Future<bool> daNhanHang(String mahd) async {
    return await _repository.daNhanHang(mahd);
  }

  // Khách gửi yêu cầu trả hàng
  Future<bool> traHang(String mahd, String lyDoKh) async {
    return await _repository.traHang(mahd, lyDoKh);
  }

  // Khách hủy đơn (chưa giao)
  Future<bool> huyDon(String mahd, String lyDoKh) async {
    return await _repository.huyDon(mahd, lyDoKh);
  }

  // Nhân viên hủy đơn (đã giao hoặc đang xử lý)
  Future<bool> huyDonNV(String mahd, String lyDoNv, int idNv) async {
    return await _repository.huyDonNV(mahd, lyDoNv, idNv);
  }

  // Duyệt trả hàng (nhân viên)
  Future<bool> duyetTraHang(
    String mahd,
    bool pheDuyet, {
    String? lyDoNv,
    int? idNv,
  }) async {
    return await _repository.duyetTraHang(
      mahd,
      pheDuyet,
      lyDoNv: lyDoNv,
      idNv: idNv,
    );
  }

  // Lấy đơn sắp hết hạn
  Future<List<Map<String, dynamic>>> getDonSapHetHan() async {
    return await _repository.getDonSapHetHan();
  }

  // Lấy đơn chờ trả hàng
  Future<List<Map<String, dynamic>>> getDonChoTraHang() async {
    return await _repository.getDonChoTraHang();
  }

  // Kiểm tra trả hàng
  Future<Map<String, dynamic>> kiemTraTraHang(String mahd) async {
    return await _repository.kiemTraTraHang(mahd);
  }

  Future<bool> ganNhanVien(String mahd, int idNv) async {
    return await _repository.ganNhanVien(mahd, idNv);
  }

  Future<bool> dangXuLy(String mahd) async {
    return await _repository.dangXuLy(mahd);
  }

  Future<bool> thuHoiHang(String mahd, String lyDoNv, int idNv) async {
    return await _repository.thuHoiHang(mahd, lyDoNv, idNv);
  }
}
