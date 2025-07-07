import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/user_controller.dart';
import 'package:luxe_silver_app/repository/user_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import 'package:luxe_silver_app/services/vietnam_location_api.dart';
import 'package:luxe_silver_app/constant/dieukien .dart';

class ThemNhanVienScreen extends StatefulWidget {
  const ThemNhanVienScreen({super.key});

  @override
  State<ThemNhanVienScreen> createState() => _ThemNhanVienScreenState();
}

class _ThemNhanVienScreenState extends State<ThemNhanVienScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _sdtController = TextEditingController();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  String? gioiTinh = 'Nữ';
  DateTime? selectedDate;
  final _ngaySinhController = TextEditingController();

  bool _obscurePassword = true;

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
    _loadCities();
  }

  @override
  void dispose() {
    _ngaySinhController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    final data = await fetchCities();
    setState(() {
      cities = data;
    });
  }

  Future<void> _loadDistricts(int cityId) async {
    setState(() {
      districts = [];
      wards = [];
      selectedDistrict = null;
      selectedWard = null;
    });
    final data = await fetchDistricts(cityId);
    setState(() {
      districts = data;
    });
  }

  Future<void> _loadWards(int districtId) async {
    setState(() {
      wards = [];
      selectedWard = null;
    });
    final data = await fetchWards(districtId);
    setState(() {
      wards = data;
    });
  }

  String get fullAddress {
    if (selectedCity == null ||
        selectedDistrict == null ||
        selectedWard == null)
      return '';
    return [
      houseNumber,
      selectedWard?['name'],
      selectedDistrict?['name'],
      selectedCity?['name'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm nhân viên'),
        backgroundColor: AppColors.appBarBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tenController,
                decoration: const InputDecoration(labelText: 'Họ & tên'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sdtController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!validator.phoneValidator(value.trim())) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              // const SizedBox(height: 12),
              // TextFormField(
              //   controller: _emailController,
              //   decoration: const InputDecoration(labelText: 'Email'),
              //   keyboardType: TextInputType.emailAddress,
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Vui lòng nhập email';
              //     }
              //     if (!validator.emailValidator(value.trim())) {
              //       return 'Email không hợp lệ';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 12),
              // Địa chỉ
              const Text(
                'Địa chỉ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedCity,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
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
                    selectedDistrict = null;
                    selectedWard = null;
                  });
                  if (value != null) _loadDistricts(value['code']);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedDistrict,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Quận/Huyện'),
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
                    selectedWard = null;
                  });
                  if (value != null) _loadWards(value['code']);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedWard,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Phường/Xã'),
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
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Số nhà, ấp, đường, khác',
                ),
                onChanged: (value) {
                  setState(() {
                    houseNumber = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(fullAddress, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              const Text(
                'Giới tính',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Nữ',
                    groupValue: gioiTinh,
                    onChanged: (value) {
                      setState(() {
                        gioiTinh = value;
                      });
                    },
                  ),
                  const Text('Nữ'),
                  Radio<String>(
                    value: 'Nam',
                    groupValue: gioiTinh,
                    onChanged: (value) {
                      setState(() {
                        gioiTinh = value;
                      });
                    },
                  ),
                  const Text('Nam'),
                ],
              ),
              const SizedBox(height: 12),
              // Ngày sinh
              const Text(
                'Ngày sinh',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ngaySinhController,
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
                  ),
                  const SizedBox(width: 10),
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
                        setState(() {
                          selectedDate = date;
                          _ngaySinhController.text =
                              '${date.day}/${date.month}/${date.year}';
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _matKhauController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (!validator.isValid(value.trim())) {
                    return 'Mật khẩu phải từ 8 ký tự và có ký tự đặc biệt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final userController = UserController(
                        UserRepository(ApiService()),
                      );
                      final result = await userController.addStaff(
                        ten: _tenController.text.trim(),
                        sodienthoai: _sdtController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _matKhauController.text.trim(),
                        diachi: fullAddress.isEmpty ? null : fullAddress,
                        gioitinh: gioiTinh,
                        ngaysinh:
                            selectedDate != null
                                ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                : DateTime.now().toIso8601String().substring(
                                  0,
                                  10,
                                ),
                      );
                      if (result['id'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thêm nhân viên thành công'),
                          ),
                        );
                        Navigator.pop(context, true); // Trả về true để reload
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Thêm thất bại'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Thêm nhân viên',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
