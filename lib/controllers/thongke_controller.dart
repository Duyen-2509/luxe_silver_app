import '../repository/thongke_repository.dart';

class ThongKeController {
  final ThongKeRepository _repo = ThongKeRepository();

  Future<Map<String, dynamic>> fetchThongKe({
    required String kieu,
    String? ngay,

    int? thang,
    int? nam,
  }) {
    return _repo.fetchThongKe(kieu: kieu, ngay: ngay, thang: thang, nam: nam);
  }
}
