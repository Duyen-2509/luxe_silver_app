import '../repository/voucher_repository.dart';

class VoucherController {
  final VoucherRepository _repository = VoucherRepository();

  // Lấy danh sách voucher
  Future<List<Map<String, dynamic>>> fetchVouchers() async {
    return await _repository.getVouchers();
  }

  // Lấy danh sách loại voucher
  Future<List<Map<String, dynamic>>> fetchVoucherTypesRaw() async {
    return await _repository.getVoucherTypesRaw();
  }

  // Thêm voucher mới
  Future<bool> createVoucher(Map<String, dynamic> voucherData) async {
    return await _repository.addVoucher(voucherData);
  }

  // Cập nhật voucher
  Future<bool> editVoucher(int id, Map<String, dynamic> voucherData) async {
    return await _repository.updateVoucher(id, voucherData);
  }

  // ẩn
  Future<bool> hideVoucher(int id) async {
    return await _repository.hideVoucher(id);
  }

  //giảm
  Future<bool> useVoucher(int id) async {
    return await _repository.useVoucher(id);
  }

  // Mở lại voucher
  Future<bool> showVoucher(int id) async {
    return await _repository.showVoucher(id);
  }
}
