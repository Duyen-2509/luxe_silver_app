import '../repository/thongbao_repository.dart';

class ThongBaoController {
  final ThongBaoRepository _repo = ThongBaoRepository();

  Future<Map<String, List<dynamic>>> getThongBaoKhach(int idKh) {
    return _repo.fetchThongBaoKhach(idKh);
  }

  Future<Map<String, List<dynamic>>> getThongBaoNhanVien(int idNv) {
    return _repo.fetchThongBaoNhanVien(idNv);
  }

  Future<bool> danhDauDaDoc(int idTb) {
    return _repo.danhDauDaDoc(idTb);
  }
}
