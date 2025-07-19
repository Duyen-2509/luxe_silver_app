import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/user_controller.dart';
import 'package:luxe_silver_app/repository/user_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import 'package:luxe_silver_app/services/vietnam_location_api.dart';
import 'package:luxe_silver_app/constant/dieukien .dart';

class SuaNhanVienScreen extends StatefulWidget {
  final Map<String, dynamic> nhanVien;
  const SuaNhanVienScreen({super.key, required this.nhanVien});

  @override
  State<SuaNhanVienScreen> createState() => _SuaNhanVienScreenState();
}

class _SuaNhanVienScreenState extends State<SuaNhanVienScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenController;
  late TextEditingController _sdtController;
  late TextEditingController _matKhauController;
  String? gioiTinh;
  DateTime? selectedDate;
  late TextEditingController _ngaySinhController;

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
    final nv = widget.nhanVien;
    _tenController = TextEditingController(text: nv['ten'] ?? '');
    _sdtController = TextEditingController(text: nv['sodienthoai'] ?? '');
    _matKhauController = TextEditingController();
    gioiTinh = nv['gioitinh'] ?? 'Nữ';
    _ngaySinhController = TextEditingController(
      text:
          nv['ngaysinh'] != null && nv['ngaysinh'].toString().isNotEmpty
              ? _formatDateForDisplay(nv['ngaysinh'])
              : '',
    );
    // Parse địa chỉ
    if (nv['diachi'] != null && nv['diachi'].toString().isNotEmpty) {
      final parts = nv['diachi'].split(',');
      houseNumber = parts.isNotEmpty ? parts[0].trim() : '';
    }
    _loadCities().then((_) {
      _initAddressDropdown(nv['diachi']);
    });
    if (nv['ngaysinh'] != null && nv['ngaysinh'].toString().isNotEmpty) {
      try {
        selectedDate = DateTime.parse(nv['ngaysinh']);
      } catch (_) {}
    }
  }

  String _formatDateForDisplay(String date) {
    try {
      final d = DateTime.parse(date);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _initAddressDropdown(String? diachi) async {
    if (diachi == null || diachi.isEmpty) return;
    final parts = diachi.split(',').map((e) => e.trim()).toList();
    if (parts.length < 4) return;
    final wardName = parts[1];
    final districtName = parts[2];
    final cityName = parts[3];

    final city = cities.firstWhere(
      (c) => c['name'] == cityName,
      orElse: () => <String, dynamic>{},
    );
    selectedCity = city.isEmpty ? null : city;
    if (selectedCity != null) {
      await _loadDistricts(selectedCity!['code']);
      final district = districts.firstWhere(
        (d) => d['name'] == districtName,
        orElse: () => <String, dynamic>{},
      );
      selectedDistrict = district.isEmpty ? null : district;
      if (selectedDistrict != null) {
        await _loadWards(selectedDistrict!['code']);
        final ward = wards.firstWhere(
          (w) => w['name'] == wardName,
          orElse: () => <String, dynamic>{},
        );
        selectedWard = ward.isEmpty ? null : ward;
        setState(() {});
      }
    }
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
        title: const Text('Chỉnh sửa nhân viên'),
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
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              // Địa chỉ
              const Text('Địa chỉ'),
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
                initialValue: houseNumber,
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
              const Text('Giới tính'),
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
              const Text('Ngày sinh'),
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
                  labelText: 'Mật khẩu (để trống nếu không đổi)',
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
                  if (value != null &&
                      value.isNotEmpty &&
                      !validator.isValid(value.trim())) {
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
                      final result = await userController.updateStaff(
                        idNv: widget.nhanVien['id_nv'],
                        ten: _tenController.text.trim(),
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
                      if (result['message'] != null &&
                          result['message'].toString().contains('thành công')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật nhân viên thành công'),
                          ),
                        );
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Cập nhật thất bại',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Lưu thay đổi',
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
