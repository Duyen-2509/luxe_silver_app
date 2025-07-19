import '../repository/contact_info_repository.dart';

class ContactInfoController {
  final ContactRepository _repository = ContactRepository();

  String phoneNumber = '';
  String phoneZalo = '';

  // Lấy thông tin từ API
  Future<void> loadContactInfo(int id) async {
    final info = await _repository.fetchContactInfo(id);
    phoneNumber = info['phoneNumber'] ?? '';
    phoneZalo = info['phoneZalo'] ?? '';
  }

  // Cập nhật thông tin lên API
  Future<bool> updateContactInfo(int id, String phone, String zalo) async {
    final success = await _repository.updateContactInfo(id, phone, zalo);
    if (success) {
      phoneNumber = phone;
      phoneZalo = zalo;
    }
    return success;
  }
}
