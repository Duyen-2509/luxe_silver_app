class PasswordValidator {
  // Mật khẩu phải ít nhất 8 ký tự và có ít nhất 1 ký tự đặc biệt
  static bool isValid(String password) {
    final specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    return password.length >= 8 && specialCharRegex.hasMatch(password);
  }
}
