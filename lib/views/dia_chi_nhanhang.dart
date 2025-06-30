import 'package:flutter/material.dart';
import '../services/vietnam_location_api.dart';

class DiaChiNhanHangScreen extends StatefulWidget {
  final String currentName;
  final String currentAddress;
  final String currentPhone;

  const DiaChiNhanHangScreen({
    Key? key,
    required this.currentName,
    required this.currentAddress,
    required this.currentPhone,
  }) : super(key: key);

  @override
  State<DiaChiNhanHangScreen> createState() => _DiaChiNhanHangScreenState();
}

class _DiaChiNhanHangScreenState extends State<DiaChiNhanHangScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> wards = [];

  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedWard;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _addressController = TextEditingController(text: widget.currentAddress);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _loadCities();
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

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String getFullAddress() {
    String address = _addressController.text.trim();
    if (selectedWard != null) address += ', ${selectedWard!['name']}';
    if (selectedDistrict != null) address += ', ${selectedDistrict!['name']}';
    if (selectedCity != null) address += ', ${selectedCity!['name']}';
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ nhận hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người nhận',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ (số nhà, đường...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Dropdown chọn tỉnh/thành
              DropdownButton<Map<String, dynamic>>(
                value: selectedCity,
                isExpanded: true,
                hint: const Text('Chọn tỉnh/thành'),
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
                  _loadDistricts(value!['code']);
                },
              ),
              const SizedBox(height: 10),
              // Dropdown chọn quận/huyện
              DropdownButton<Map<String, dynamic>>(
                value: selectedDistrict,
                isExpanded: true,
                hint: const Text('Chọn quận/huyện'),
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
                  _loadWards(value!['code']);
                },
              ),
              const SizedBox(height: 10),
              // Dropdown chọn phường/xã
              DropdownButton<Map<String, dynamic>>(
                value: selectedWard,
                isExpanded: true,
                hint: const Text('Chọn phường/xã'),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Trả về dữ liệu mới cho màn trước
                    Navigator.pop(context, {
                      'name': _nameController.text.trim(),
                      'phone': _phoneController.text.trim(),
                      'address': getFullAddress(),
                    });
                  },
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
