class validator {
  // Mật khẩu phải ít nhất 8 ký tự và có ít nhất 1 ký tự đặc biệt
  static bool isValid(String password) {
    final specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    return password.length >= 8 && specialCharRegex.hasMatch(password);
  }

  // Số điện thoại phải bắt đầu bằng 0 hoặc +84 và theo sau là 9 số
  static bool phoneValidator(String phone) {
    final regex = RegExp(r'^(0\d{9}|\+84\d{9})$');
    return regex.hasMatch(phone);
  }

  // Kiểm tra số nguyên không âm
  static String? notNegativeInt(String? value) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống';
    }
    final n = int.tryParse(value);
    if (n == null || n < 0) {
      return 'Chỉ nhập số nguyên không âm';
    }
    return null;
  }

  // Kiểm tra email hợp lệ
  static bool emailValidator(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
