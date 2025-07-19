import '../repository/tienship_repository.dart';

class TienShipController {
  final TienShipRepository _repository = TienShipRepository();

  Future<List<Map<String, dynamic>>> fetchTienShip() async {
    return await _repository.getTienShip();
  }

  Future<bool> updateTienShip(int id, num gia) async {
    return await _repository.updateTienShip(id, gia);
  }
}
