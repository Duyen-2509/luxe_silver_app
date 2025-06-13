import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/constant/dieukien%20.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/vietnam_location_api.dart';

import '../constant/image.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  late String sdt;
  late String email;
  late String dc;
  late DateTime ngaysinh;
  late String gioitinh;
  late String role;
  late double diem;
  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu từ userData
    name = widget.userData['ten'] ?? '';
    sdt = widget.userData['sodienthoai'] ?? '';
    email = widget.userData['email'] ?? '';
    dc = widget.userData['diachi'] ?? '';
    ngaysinh =
        DateTime.tryParse(widget.userData['ngaysinh'] ?? '') ??
        DateTime(2000, 1, 1);
    gioitinh = widget.userData['gioitinh'] ?? '';
    role = widget.userData['role'] ?? '';
    final rawDiem = widget.userData['diem'];
    if (rawDiem is int) {
      diem = rawDiem.toDouble();
    } else if (rawDiem is double) {
      diem = rawDiem;
    } else if (rawDiem is String) {
      diem = double.tryParse(rawDiem) ?? 0;
    } else {
      diem = 0;
    } // Ép kiểu an toàn
    //print('userData: ${widget.userData}');
  }

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
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      FirebaseAuth.instance.currentUser?.photoURL != null
                          ? NetworkImage(
                            FirebaseAuth.instance.currentUser!.photoURL!,
                          )
                          : const AssetImage(AppImages.avatar) as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 10),
              if (role == 'khach_hang')
                Text(
                  '${diem.toStringAsFixed(3)} điểm',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 20),
              // Họ tên
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Họ Tên'),
                subtitle: Text('$name'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showNameDialog(context, name, (newName) {
                      setState(() {
                        name = newName;
                      });
                    });
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
                    showPhoneDialog(context, sdt, (newPhone) {
                      setState(() {
                        sdt = newPhone;
                      });
                    });
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
                    showEmailDialog(context, email, (newEmail) {
                      setState(() {
                        email = newEmail;
                      });
                    });
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
                    showAddressDialog(context, dc, (newAddress) {
                      setState(() {
                        dc = newAddress;
                      });
                    });
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
                    await showEditBirthdayDialog(context);
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
                    showGenderDialog(context, gioitinh);
                  },
                ),
              ),
              const Divider(),
              //Đổi mật khẩu
              if (role != 'admin')
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Đổi mật khẩu'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showChangePasswordDialog(context);
                    },
                  ),
                ),

              const SizedBox(height: 20),
              //nút đăng xuất
              ElevatedButton(
                onPressed: () async {
                  await signOutAll(); // <-- Đăng xuất khỏi Google và Firebase
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
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

Future<void> signOutAll() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
}

// tên
void showNameDialog(
  BuildContext context,
  String currentName,
  void Function(String) onNameChanged,
) {
  String newName = currentName;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Họ tên'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Nhập họ tên mới'),
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
              onNameChanged(newName); // Gọi callback để cập nhật tên
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
    },
  );
}

//số điện thoại
void showPhoneDialog(
  BuildContext context,
  String sdt,
  void Function(String) onPhoneChanged,
) {
  String newPhone = sdt;
  String? errorText;
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Số điện thoại'),
            content: TextField(
              decoration: InputDecoration(
                labelText: 'Nhập số điện thoại mới',
                counterText: '',
                errorText: errorText,
              ),
              controller: TextEditingController(text: newPhone),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  if (!PasswordValidator.phoneValidator(newPhone)) {
                    setStateDialog(() {
                      errorText = 'Số điện thoại không hợp lệ';
                    });
                    return;
                  }
                  onPhoneChanged(newPhone);
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
}

//email
void showEmailDialog(
  BuildContext context,
  String email,
  void Function(String) onEmailChanged,
) {
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
              controller: TextEditingController(text: newEmail),
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
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(newEmail)) {
                    setStateDialog(() {
                      errorText = 'Email không hợp lệ';
                    });
                    return;
                  }
                  onEmailChanged(
                    newEmail,
                  ); // Gọi callback để cập nhật email ở widget cha
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
}

// đổi mật khẩu
void showChangePasswordDialog(BuildContext context) {
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
                  decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
                  onChanged: (value) => oldPassword = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  onChanged: (value) => newPassword = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                  ),
                  onChanged: (value) => confirmPassword = value,
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red),
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
                  if (!PasswordValidator.isValid(newPassword)) {
                    setStateDialog(() {
                      errorText =
                          'Mật khẩu mới phải ít nhất 8 ký tự và có ký tự đặc biệt';
                    });
                    return;
                  }
                  if (oldPassword.isEmpty || newPassword.isEmpty) {
                    setStateDialog(() {
                      errorText = 'Vui lòng nhập đầy đủ thông tin';
                    });
                    return;
                  }
                  // TODO: Kiểm tra mật khẩu cũ đúng chưa (nếu có backend)
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
}

//Giới tính
void showGenderDialog(BuildContext context, String currentGender) {
  showDialog(
    context: context,
    builder: (context) {
      String selectedGender = currentGender; // Use the parameter
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
                onPressed: () {
                  Navigator.of(context).pop(selectedGender);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

// Địa chỉ
void showAddressDialog(
  BuildContext context,
  String currentAddress,
  void Function(String) onAddressChanged,
) {
  showDialog(
    context: context,
    builder:
        (context) => _AddressDialog(
          currentAddress: currentAddress,
          onAddressChanged: onAddressChanged,
        ),
  );
}

class _AddressDialog extends StatefulWidget {
  final String currentAddress;
  final void Function(String) onAddressChanged;
  const _AddressDialog({
    required this.currentAddress,
    required this.onAddressChanged,
  });

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> wards = [];
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedWard;
  String houseNumber = '';

  @override
  void initState() {
    super.initState();
    fetchCities().then((data) {
      setState(() {
        cities = data;
        if (cities.isNotEmpty) {
          selectedCity = cities.first;
          _loadDistricts(selectedCity!['code']);
        }
      });
    });
  }

  void _loadDistricts(int cityId) async {
    final data = await fetchDistricts(cityId);
    setState(() {
      districts = data;
      selectedDistrict = districts.isNotEmpty ? districts.first : null;
      wards = [];
      selectedWard = null;
      if (selectedDistrict != null) _loadWards(selectedDistrict!['code']);
    });
  }

  void _loadWards(int districtId) async {
    final data = await fetchWards(districtId);
    setState(() {
      wards = data;
      selectedWard = wards.isNotEmpty ? wards.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa địa chỉ'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<Map<String, dynamic>>(
              value: selectedCity,
              isExpanded: true,
              items:
                  cities
                      .map(
                        (city) => DropdownMenuItem(
                          value: city,
                          child: Text(city['name']),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                  _loadDistricts(value!['code']);
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<Map<String, dynamic>>(
              value: selectedDistrict,
              isExpanded: true,
              items:
                  districts
                      .map(
                        (district) => DropdownMenuItem(
                          value: district,
                          child: Text(district['name']),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                  _loadWards(value!['code']);
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<Map<String, dynamic>>(
              value: selectedWard,
              isExpanded: true,
              items:
                  wards
                      .map(
                        (ward) => DropdownMenuItem(
                          value: ward,
                          child: Text(ward['name']),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedWard = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Số nhà, ấp, đường, khác',
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
            widget.onAddressChanged(
              '$houseNumber, ${selectedWard?['name'] ?? ''}, ${selectedDistrict?['name'] ?? ''}, ${selectedCity?['name'] ?? ''}',
            );
            Navigator.pop(context);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
// Ngày sinh

// Đưa đoạn code này vào trong _ProfileScreenState như một phương thức:

extension _ProfileScreenStateBirthdayDialog on _ProfileScreenState {
  Future<void> showEditBirthdayDialog(BuildContext context) async {
    DateTime? selectedDate = ngaysinh;
    TextEditingController controller = TextEditingController(
      text: '${ngaysinh.day}/${ngaysinh.month}/${ngaysinh.year}',
    );

    await showDialog(
      context: context,
      builder: (context) {
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
                    initialDate: selectedDate ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    selectedDate = date;
                    controller.text = '${date.day}/${date.month}/${date.year}';
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
  }
}
