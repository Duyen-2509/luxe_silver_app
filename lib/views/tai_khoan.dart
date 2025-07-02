import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/constant/dieukien%20.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luxe_silver_app/controllers/user_controller.dart';
import 'package:luxe_silver_app/repository/user_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import '../services/vietnam_location_api.dart';
import '../constant/image.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Các biến lưu thông tin cá nhân
  late String name;
  late String sdt;
  late String email;
  late String dc;
  late DateTime ngaysinh;
  late String gioitinh;
  late String role;
  late int diem;

  // Hàm lấy id khách hàng an toàn
  int? get currentUserId {
    if (role == 'khach_hang') {
      final idKhRaw = widget.userData['id_kh'] ?? widget.userData['id'];
      return idKhRaw is int ? idKhRaw : int.tryParse(idKhRaw?.toString() ?? '');
    } else if (role == 'nhan_vien' || role == 'admin') {
      final idNvRaw = widget.userData['id_nv'] ?? widget.userData['id'];
      return idNvRaw is int ? idNvRaw : int.tryParse(idNvRaw?.toString() ?? '');
    }
    return null;
  }

  // Hàm cập nhật profile lên server
  Future<void> updateProfileOnServer(
    Map<String, dynamic> data,
    String successMsg,
    String failMsg,
  ) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy ID người dùng!')),
      );
      return;
    }
    final apiService = ApiService();
    final userRepository = UserRepository(apiService);
    final userController = UserController(userRepository);

    bool success = false;
    if (role == 'khach_hang') {
      success = await userController.updateProfile(
        idKh: currentUserId!,
        ten: data['ten'],
        sodienthoai: data['sodienthoai'],
        email: data['email'],
        diachi: data['diachi'],
        ngaysinh: data['ngaysinh'],
        gioitinh: data['gioitinh'],
        password: data['password'],
      );
    } else if (role == 'nhan_vien' || role == 'admin') {
      final result = await userRepository.updateStaff(
        idNv: currentUserId!,
        ten: data['ten'],
        sodienthoai: data['sodienthoai'],
        password: data['password'],
        diachi: data['diachi'],
        ngaysinh: data['ngaysinh'],
        gioitinh: data['gioitinh'],
      );
      success = result['success'] == true || result['status'] == true;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMsg)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failMsg)));
    }
  }

  Future<void> reloadUserData() async {
    final apiService = ApiService();
    final userRepository = UserRepository(apiService);
    final userController = UserController(userRepository);

    Map<String, dynamic>? user;
    if (role == 'khach_hang') {
      user = await userController.getUserById(currentUserId!);
    } else if (role == 'nhan_vien' || role == 'admin') {
      user = await userController.getStaffById(currentUserId!);
    }

    if (user != null) {
      setState(() {
        final currentUser = user!;

        name = currentUser['ten'] ?? '';
        sdt = currentUser['sodienthoai'] ?? '';
        dc = currentUser['diachi'] ?? '';
        ngaysinh =
            DateTime.tryParse(currentUser['ngaysinh'] ?? '') ??
            DateTime(2000, 1, 1);
        gioitinh = currentUser['gioitinh'] ?? '';

        if (role == 'khach_hang') {
          email = currentUser['email'] ?? '';
          diem =
              currentUser['diem'] != null
                  ? (currentUser['diem'] is int
                      ? currentUser['diem']
                      : (currentUser['diem'] is double
                          ? (currentUser['diem'] as double).toInt()
                          : int.tryParse(currentUser['diem'].toString()) ?? 0))
                  : 0;
        } else {
          email = '';
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print(
      'Thông tin truyền vào ProfileScreen%%%%%%%%%%%%%%: ${widget.userData}',
    ); // In ra dữ liệu
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
      diem = rawDiem.toInt();
    } else if (rawDiem is int) {
      diem = rawDiem;
    } else if (rawDiem is String) {
      diem = int.tryParse(rawDiem) ?? 0;
    } else {
      diem = 0;
    }
    // // Sửa tại đây: chỉ reload nếu là khách hàng
    if (role == 'khach_hang') {
      reloadUserData();
    }
    if (currentUserId != null) {
      reloadUserData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (role == 'khach_hang') {
      reloadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Cá Nhân'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: reloadUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Ảnh đại diện
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        FirebaseAuth.instance.currentUser?.photoURL != null
                            ? NetworkImage(
                              FirebaseAuth.instance.currentUser!.photoURL!,
                            )
                            : const AssetImage(AppImages.avatar)
                                as ImageProvider,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 10),
                if (role.trim().toLowerCase() == 'admin')
                  Text(
                    'Admin',
                    style: const TextStyle(fontSize: 16, color: Colors.pink),
                  )
                else if (role.trim().toLowerCase() == 'nhan_vien')
                  Text(
                    'Nhân viên',
                    style: const TextStyle(fontSize: 16, color: Colors.pink),
                  )
                else
                  Text(
                    '$diem điểm',
                    style: const TextStyle(fontSize: 16, color: Colors.pink),
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
                      showNameDialog(context, name, (newName) async {
                        setState(() {
                          name = newName;
                        });
                        await updateProfileOnServer(
                          {'ten': newName},
                          'Cập nhật tên thành công!',
                          'Cập nhật tên thất bại!',
                        );
                        await reloadUserData();
                      });
                    },
                  ),
                ),
                const Divider(),

                // Số điện thoại
                if (role.trim().toLowerCase() != 'admin') ...[
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Số điện thoại'),
                    subtitle: Text(sdt),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showPhoneDialog(context, sdt, (newPhone) async {
                          setState(() {
                            sdt = newPhone;
                          });
                          await updateProfileOnServer(
                            {'sodienthoai': newPhone},
                            'Cập nhật số điện thoại thành công!',
                            'Cập nhật số điện thoại thất bại!',
                          );
                          await reloadUserData();
                        });
                      },
                    ),
                  ),
                  const Divider(),
                ],

                // Email
                if ((role.trim().toLowerCase() != 'admin') &&
                    (role.trim().toLowerCase() != 'nhan_vien')) ...[
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(email),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showEmailDialog(context, email, (newEmail) async {
                          setState(() {
                            email = newEmail;
                          });
                          await updateProfileOnServer(
                            {'email': newEmail},
                            'Cập nhật email thành công!',
                            'Cập nhật email thất bại!',
                          );
                          await reloadUserData();
                        });
                      },
                    ),
                  ),
                  const Divider(),
                ],

                // Địa chỉ
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Địa chỉ'),
                  subtitle: Text(dc),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showAddressDialog(context, dc, (newAddress) async {
                        setState(() {
                          dc = newAddress;
                        });
                        await updateProfileOnServer(
                          {'diachi': newAddress},
                          'Cập nhật địa chỉ thành công!',
                          'Cập nhật địa chỉ thất bại!',
                        );
                        await reloadUserData();
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
                      await updateProfileOnServer(
                        {
                          'ngaysinh':
                              '${ngaysinh.year}-${ngaysinh.month.toString().padLeft(2, '0')}-${ngaysinh.day.toString().padLeft(2, '0')}',
                        },
                        'Cập nhật ngày sinh thành công!',
                        'Cập nhật ngày sinh thất bại!',
                      );
                      await reloadUserData();
                    },
                  ),
                ),
                const Divider(),

                // Giới tính
                ListTile(
                  leading: const Icon(Icons.wc),
                  title: const Text('Giới tính'),
                  subtitle: Text(gioitinh),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showGenderDialog(context, gioitinh, (newGender) async {
                        setState(() {
                          gioitinh = newGender;
                        });
                        await updateProfileOnServer(
                          {'gioitinh': newGender},
                          'Cập nhật giới tính thành công!',
                          'Cập nhật giới tính thất bại!',
                        );
                        await reloadUserData();
                      });
                    },
                  ),
                ),
                const Divider(),

                // Đổi mật khẩu
                if (role != 'admin')
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Đổi mật khẩu'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        showChangePasswordDialog(
                          context: context,
                          idKh: currentUserId,
                        );
                        await reloadUserData();
                      },
                    ),
                  ),

                const SizedBox(height: 20),
                // Nút đăng xuất
                ElevatedButton(
                  onPressed: () async {
                    await signOutAll();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
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
      ),
    );
  }
}

// Đăng xuất Google & Firebase
Future<void> signOutAll() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
}

// Dialog đổi tên
void showNameDialog(
  BuildContext context,
  String currentName,
  void Function(String) onNameChanged,
) {
  final controller = TextEditingController(text: currentName);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Họ tên'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nhập họ tên mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              onNameChanged(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
    },
  );
}

// Dialog đổi số điện thoại
void showPhoneDialog(
  BuildContext context,
  String sdt,
  void Function(String) onPhoneChanged,
) {
  final controller = TextEditingController(text: sdt);
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
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  if (!validator.phoneValidator(controller.text)) {
                    setStateDialog(() {
                      errorText = 'Số điện thoại không hợp lệ';
                    });
                    return;
                  }
                  onPhoneChanged(controller.text);
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

// Dialog đổi email
void showEmailDialog(
  BuildContext context,
  String email,
  void Function(String) onEmailChanged,
) {
  final controller = TextEditingController(text: email);
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
              controller: controller,
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  if (!validator.emailValidator(controller.text)) {
                    setStateDialog(() {
                      errorText = 'Email không hợp lệ';
                    });
                  }
                  onEmailChanged(controller.text);
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
void showChangePasswordDialog({
  required BuildContext context,
  required int? idKh,
}) {
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
                onPressed: () async {
                  // 1. Kiểm tra xác nhận mật khẩu trước
                  if (newPassword != confirmPassword) {
                    setStateDialog(() {
                      errorText = 'Xác nhận mật khẩu không khớp';
                    });
                    return;
                  }
                  // 2. Kiểm tra điều kiện mật khẩu mới
                  if (!validator.isValid(newPassword)) {
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

                  // --- Gọi API đổi mật khẩu ---
                  final apiService = ApiService();
                  final userRepository = UserRepository(apiService);
                  final userController = UserController(userRepository);

                  if (idKh == null || idKh == 0) {
                    setStateDialog(() {
                      errorText = 'Không tìm thấy ID khách hàng!';
                    });
                    return;
                  }
                  final message = await userController.changePassword(
                    idKh: idKh,
                    oldPassword: oldPassword,
                    newPassword: newPassword,
                  );
                  if (message == 'Đổi mật khẩu thành công') {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đổi mật khẩu thành công!')),
                    );
                  } else {
                    setStateDialog(() {
                      errorText = message ?? 'Đổi mật khẩu thất bại!';
                    });
                  }
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
// Dialog đổi giới tính (trả về giá trị mới qua callback)
void showGenderDialog(
  BuildContext context,
  String currentGender,
  void Function(String) onGenderChanged,
) {
  // Nếu currentGender không phải "Nam" hoặc "Nữ", mặc định là "Nữ"
  String selectedGender =
      (currentGender == "Nam" || currentGender == "Nữ") ? currentGender : "Nữ";
  showDialog(
    context: context,
    builder: (context) {
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
                  onGenderChanged(selectedGender);
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

// Dialog đổi ngày sinh (extension cho _ProfileScreenState)
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
