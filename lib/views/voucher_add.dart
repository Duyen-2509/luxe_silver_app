import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/voucher_controller.dart';

class AddVoucherScreen extends StatefulWidget {
  @override
  State<AddVoucherScreen> createState() => _AddVoucherScreenState();
}

class _AddVoucherScreenState extends State<AddVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  dynamic _selectedType;
  DateTimeRange? _selectedRange;
  final voucherController = VoucherController();
  List<Map<String, dynamic>> voucherTypes = [];

  final _minOrderController = TextEditingController();
  final _discountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVoucherTypes();
  }

  @override
  void dispose() {
    _minOrderController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadVoucherTypes() async {
    final types = await voucherController.fetchVoucherTypesRaw();
    setState(() {
      voucherTypes = types;
      _selectedType =
          voucherTypes.isNotEmpty
              ? voucherTypes[0]['id_loai_voucher'].toString()
              : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    String timeLabel = 'Chọn khoản thời gian';
    if (_selectedRange != null) {
      timeLabel =
          '${_selectedRange!.start.day}/${_selectedRange!.start.month}/${_selectedRange!.start.year} - '
          '${_selectedRange!.end.day}/${_selectedRange!.end.month}/${_selectedRange!.end.year}';
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Voucher'),
        leading: BackButton(),
        backgroundColor: AppColors.appBarBackground,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text('Đơn tối thiểu'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _minOrderController,
                decoration: const InputDecoration(
                  hintText: 'Nhập số tiền',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),
              const SizedBox(height: 16),
              const Text('Số tiền giảm'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  hintText: 'Nhập số tiền',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),
              const SizedBox(height: 16),
              const Text('Số lượng'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  hintText: 'Nhập số lượng',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),
              const SizedBox(height: 16),
              const Text('Nội dung'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Nhập nội dung',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                maxLines: 2,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Loại khuyến mãi'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      items:
                          voucherTypes
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e['id_loai_voucher'].toString(),
                                  child: Text(e['ten'].toString()),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Chọn khoản thời gian'),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: now,
                    lastDate: DateTime(now.year + 5),
                    initialDateRange: _selectedRange,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedRange = picked;
                    });
                  }
                },
                child: Text(timeLabel),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _selectedRange != null) {
                      final voucherData = {
                        'id_loai_voucher': int.parse(_selectedType),
                        'ten': _contentController.text,
                        'giatri_min': int.parse(_minOrderController.text),
                        'sotiengiam':
                            double.tryParse(_discountController.text) ?? 0.0,
                        'soluong': int.parse(_quantityController.text),
                        'ngaybatdau': _selectedRange!.start.toIso8601String(),
                        'ngayketthuc': _selectedRange!.end.toIso8601String(),
                        'trangthai': 1,
                      };
                      final success = await voucherController.createVoucher(
                        voucherData,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Thêm voucher thành công!')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lưu voucher thất bại')),
                        );
                      }
                    } else if (_selectedRange == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng chọn khoảng thời gian'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Lưu', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
