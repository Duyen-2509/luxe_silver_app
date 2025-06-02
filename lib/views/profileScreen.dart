import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/constant/dieukien%20.dart';

import '../constant/image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double diem = 18.384;
  String name = 'Nguyễn Văn A';
  String sdt = '0123456789';
  String email = 'nguyenvana@gmail.com';
  String dc = 'tphcm';
  DateTime ngaysinh = DateTime(2000, 1, 1);
  String gioitinh = 'Nữ';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Thông Tin Cá Nhân',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black, // Viền đen
                  ),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(AppImages.avatar),
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 10),
              Text('$diem điểm', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              // Họ tên
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Họ Tên'),
                subtitle: Text('$name'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    String newName = name;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Họ tên'),
                          content: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Nhập họ tên mới',
                            ),
                            controller: TextEditingController(text: newName),
                            onChanged: (value) {
                              newName = value;
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  name = newName; // Cập nhật biến thành viên
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Lưu'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              // Số điện thoại
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Số điện thoại'),
                subtitle: Text(sdt),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    String newPhone = sdt;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Số điện thoại'),
                          content: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Nhập số điện thoại mới',
                              counterText: '', // Ẩn bộ đếm ký tự nếu muốn
                            ),
                            controller: TextEditingController(text: newPhone),
                            keyboardType: TextInputType.phone,
                            maxLength: 10, // Chỉ cho nhập tối đa 10 số
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Chỉ cho nhập số
                            ],
                            onChanged: (value) {
                              newPhone = value;
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  sdt = newPhone;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Lưu'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              // Email
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    String newEmail = email;
                    String? errorText;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setStateDialog) {
                            return AlertDialog(
                              title: const Text('Email'),
                              content: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Nhập email mới',
                                  errorText: errorText,
                                ),
                                controller: TextEditingController(
                                  text: newEmail,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  newEmail = value;
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Kiểm tra định dạng email
                                    final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    );
                                    if (!emailRegex.hasMatch(newEmail)) {
                                      setStateDialog(() {
                                        errorText = 'Email không hợp lệ';
                                      });
                                      return;
                                    }
                                    setState(() {
                                      email = newEmail;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Lưu'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              // Dia chỉ
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Địa chỉ'),
                subtitle: Text('$dc'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Dữ liệu mẫu
                    List<String> cities = ['TP.HCM', 'Hà Nội'];
                    Map<String, List<String>> districts = {
                      'TP.HCM': ['Quận 1', 'Quận 3'],
                      'Hà Nội': ['Hoàn Kiếm', 'Ba Đình'],
                    };
                    Map<String, List<String>> wards = {
                      'Quận 1': ['Phường Bến Nghé', 'Phường Bến Thành'],
                      'Quận 3': ['Phường 6', 'Phường 7'],
                      'Hoàn Kiếm': ['Phường Hàng Bạc', 'Phường Hàng Đào'],
                      'Ba Đình': ['Phường Điện Biên', 'Phường Kim Mã'],
                    };

                    String selectedCity = cities.first;
                    String selectedDistrict = districts[selectedCity]!.first;
                    String selectedWard = wards[selectedDistrict]!.first;
                    String houseNumber = '';

                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setStateDialog) {
                            return AlertDialog(
                              title: const Text('Chỉnh sửa địa chỉ'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Thành phố
                                    DropdownButton<String>(
                                      value: selectedCity,
                                      isExpanded: true,
                                      items:
                                          cities
                                              .map(
                                                (city) => DropdownMenuItem(
                                                  value: city,
                                                  child: Text(city),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          selectedCity = value!;
                                          selectedDistrict =
                                              districts[selectedCity]!.first;
                                          selectedWard =
                                              wards[selectedDistrict]!.first;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    // Quận/huyện
                                    DropdownButton<String>(
                                      value: selectedDistrict,
                                      isExpanded: true,
                                      items:
                                          districts[selectedCity]!
                                              .map(
                                                (district) => DropdownMenuItem(
                                                  value: district,
                                                  child: Text(district),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          selectedDistrict = value!;
                                          selectedWard =
                                              wards[selectedDistrict]!.first;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    // Phường/xã
                                    DropdownButton<String>(
                                      value: selectedWard,
                                      isExpanded: true,
                                      items:
                                          wards[selectedDistrict]!
                                              .map(
                                                (ward) => DropdownMenuItem(
                                                  value: ward,
                                                  child: Text(ward),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          selectedWard = value!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    // Số nhà, ấp
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Số nhà, ấp, khác',
                                      ),
                                      onChanged: (value) {
                                        houseNumber = value;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      dc =
                                          '$houseNumber, $selectedWard, $selectedDistrict, $selectedCity';
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Lưu'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              // Ngày sinh
              ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('Ngày sinh'),
                subtitle: Text(
                  '${ngaysinh.day}/${ngaysinh.month}/${ngaysinh.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    DateTime? selectedDate = ngaysinh;

                    await showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController
                        controller = TextEditingController(
                          text:
                              '${ngaysinh.day}/${ngaysinh.month}/${ngaysinh.year}',
                        );

                        return AlertDialog(
                          title: const Text('Chỉnh sửa ngày sinh'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: controller,
                                readOnly: true,
                                keyboardType: TextInputType.datetime,
                                decoration: const InputDecoration(
                                  labelText: 'Nhập ngày (dd/mm/yyyy)',
                                ),
                                onChanged: (value) {
                                  try {
                                    final parts = value.split('/');
                                    if (parts.length == 3) {
                                      final day = int.parse(parts[0]);
                                      final month = int.parse(parts[1]);
                                      final year = int.parse(parts[2]);
                                      selectedDate = DateTime(year, month, day);
                                    }
                                  } catch (_) {}
                                },
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Chọn từ lịch'),
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    selectedDate = date;
                                    controller.text =
                                        '${date.day}/${date.month}/${date.year}';
                                  }
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Cập nhật giá trị ngày sinh ở đây
                                // Ví dụ: setState(() => ngaysinh = selectedDate);
                                Navigator.pop(context, selectedDate);
                              },
                              child: const Text('Lưu'),
                            ),
                          ],
                        );
                      },
                    ).then((value) {
                      if (value != null && value is DateTime) {
                        setState(() {
                          ngaysinh = value;
                        });
                      }
                    });
                  },
                ),
              ),
              const Divider(),
              //Giới tính
              ListTile(
                leading: const Icon(Icons.wc),
                title: const Text('Giới tính'),
                subtitle: Text(gioitinh),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String selectedGender = gioitinh;
                        return StatefulBuilder(
                          builder: (context, setStateDialog) {
                            return AlertDialog(
                              title: const Text('Chọn giới tính'),
                              content: DropdownButton<String>(
                                value: selectedGender,
                                isExpanded: true,
                                items:
                                    ['Nam', 'Nữ']
                                        .map(
                                          (gender) => DropdownMenuItem(
                                            value: gender,
                                            child: Text(gender),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setStateDialog(() {
                                    selectedGender = value!;
                                  });
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      gioitinh = selectedGender;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Lưu'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              //Đổi mật khẩu
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Đổi mật khẩu'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    String oldPassword = '';
                    String newPassword = '';
                    String confirmPassword = '';
                    String? errorText;

                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setStateDialog) {
                            return AlertDialog(
                              title: const Text('Đổi mật khẩu'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Mật khẩu cũ',
                                    ),
                                    onChanged: (value) => oldPassword = value,
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Mật khẩu mới',
                                    ),
                                    onChanged: (value) => newPassword = value,
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Xác nhận mật khẩu mới',
                                    ),
                                    onChanged:
                                        (value) => confirmPassword = value,
                                  ),
                                  if (errorText != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        errorText!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Kiểm tra hợp lệ
                                    if (newPassword != confirmPassword) {
                                      setStateDialog(() {
                                        errorText = 'Mật khẩu mới không khớp';
                                      });
                                      return;
                                    }
                                    if (!PasswordValidator.isValid(
                                      newPassword,
                                    )) {
                                      setStateDialog(() {
                                        errorText =
                                            'Mật khẩu mới phải ít nhất 8 ký tự và có ký tự đặc biệt';
                                      });
                                      return;
                                    }
                                    if (oldPassword.isEmpty ||
                                        newPassword.isEmpty) {
                                      setStateDialog(() {
                                        errorText =
                                            'Vui lòng nhập đầy đủ thông tin';
                                      });
                                      return;
                                    }
                                    // TODO: Kiểm tra mật khẩu cũ đúng chưa (nếu có backend)
                                    // Đổi mật khẩu thành công
                                    Navigator.pop(context);
                                    // Hiển thị thông báo hoặc xử lý tiếp
                                  },
                                  child: const Text('Lưu'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              const SizedBox(height: 20),
              //nút đăng xuất
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                  backgroundColor: AppColors.buttonBackground,
                ),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: AppColors.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
