class PasswordValidator {
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
}
