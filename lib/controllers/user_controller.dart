import '../repository/user_repository.dart';

class UserController {
  final UserRepository userRepository;
  UserController(this.userRepository);

  Future<bool> updateProfile({
    required int idKh,
    String? ten,
    String? sodienthoai,
    String? email,
    String? diachi,
    String? ngaysinh,
    String? gioitinh,
    String? password,
  }) async {
    final data = <String, dynamic>{
      'id_kh': idKh,
      if (ten != null) 'ten': ten,
      if (sodienthoai != null) 'sodienthoai': sodienthoai,
      if (email != null) 'email': email,
      if (diachi != null) 'diachi': diachi,
      if (ngaysinh != null) 'ngaysinh': ngaysinh,
      if (gioitinh != null) 'gioitinh': gioitinh,
      if (password != null) 'password': password,
    };
    return await userRepository.updateProfile(data);
  }

  Future<String?> changePassword({
    required int idKh,
    required String oldPassword,
    required String newPassword,
  }) async {
    return await userRepository.changePassword(
      idKh: idKh,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<Map<String, dynamic>?> getUserById(int idKh) async {
    return await userRepository.getUserById(idKh);
  }

  Future<String?> changePasswordByPhone({
    required String phone,
    required String newPassword,
  }) async {
    return await userRepository.changePasswordByPhone(
      phone: phone,
      newPassword: newPassword,
    );
  }

  Future<Map<String, dynamic>> addStaff({
    required String ten,
    required String sodienthoai,
    required String email,
    required String password,
    String? diachi,
    String? ngaysinh,
    String? gioitinh,
  }) async {
    return await userRepository.addStaff(
      ten: ten,
      sodienthoai: sodienthoai,
      email: email,
      password: password,
      diachi: diachi,
      ngaysinh: ngaysinh,
      gioitinh: gioitinh,
    );
  }

  Future<Map<String, dynamic>> updateStaff({
    required int idNv,
    String? ten,
    String? sodienthoai,
    String? email,
    String? password,
    String? diachi,
    String? ngaysinh,
    String? gioitinh,
  }) async {
    return await userRepository.updateStaff(
      idNv: idNv,
      ten: ten,
      sodienthoai: sodienthoai,
      email: email,
      password: password,
      diachi: diachi,
      ngaysinh: ngaysinh,
      gioitinh: gioitinh,
    );
  }

  Future<Map<String, dynamic>?> getStaffById(int idNv) async {
    return await userRepository.getStaffById(idNv);
  }

  Future<List<Map<String, dynamic>>> getAllStaff() async {
    return await userRepository.getAllStaff();
  }

  Future<Map<String, dynamic>> hideStaff(int idNv) async {
    return await userRepository.hideStaff(idNv);
  }

  Future<Map<String, dynamic>> unhideStaff(int idNv) async {
    return await userRepository.unhideStaff(idNv);
  }
}
