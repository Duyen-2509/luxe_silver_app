import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_silver_app/controllers/voucher_controller.dart';

class VoucherEditScreen extends StatefulWidget {
  final Map<String, dynamic> voucher;
  const VoucherEditScreen({super.key, required this.voucher});

  @override
  State<VoucherEditScreen> createState() => _VoucherEditScreenState();
}

class _VoucherEditScreenState extends State<VoucherEditScreen> {
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
    // Gán dữ liệu cũ vào các controller
    _minOrderController.text = widget.voucher['giatri_min']?.toString() ?? '';
    _discountController.text = widget.voucher['sotiengiam']?.toString() ?? '';
    _quantityController.text = widget.voucher['soluong']?.toString() ?? '';
    _contentController.text = widget.voucher['ten']?.toString() ?? '';
    // Gán loại voucher cũ
    _selectedType = widget.voucher['id_loai_voucher']?.toString();
    // Gán khoảng thời gian cũ
    final start = widget.voucher['ngaybatdau'];
    final end = widget.voucher['ngayketthuc'];
    if (start != null && end != null) {
      _selectedRange = DateTimeRange(
        start: DateTime.parse(start),
        end: DateTime.parse(end),
      );
    }
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
      // Nếu loại cũ có trong danh sách thì chọn, không thì chọn loại đầu tiên
      final oldType = widget.voucher['id_loai_voucher']?.toString();
      if (voucherTypes.any((e) => e['id_loai_voucher'].toString() == oldType)) {
        _selectedType = oldType;
      } else if (voucherTypes.isNotEmpty) {
        _selectedType = voucherTypes[0]['id_loai_voucher'].toString();
      }
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
        title: const Text('Chỉnh sửa Voucher'),
        leading: BackButton(),
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
                    firstDate: DateTime(now.year - 5),
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
                      final data = {
                        'id_loai_voucher': int.parse(_selectedType),
                        'ten': _contentController.text,
                        'giatri_min': int.parse(_minOrderController.text),
                        'sotiengiam':
                            double.tryParse(_discountController.text) ?? 0.0,
                        'soluong': int.parse(_quantityController.text),
                        'ngaybatdau': _selectedRange!.start.toIso8601String(),
                        'ngayketthuc': _selectedRange!.end.toIso8601String(),
                        'trangthai': widget.voucher['trangthai'] ?? 1,
                      };

                      final id =
                          widget.voucher['id'] ?? widget.voucher['id_voucher'];
                      if (id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không tìm thấy ID voucher!'),
                          ),
                        );
                        return;
                      }
                      final success = await voucherController.editVoucher(
                        id is int ? id : int.tryParse(id.toString()) ?? 0,
                        data,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật voucher thành công!'),
                          ),
                        );
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cập nhật thất bại!')),
                        );
                      }
                    } else if (_selectedRange == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
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
                  child: const Text(
                    'Lưu thay đổi',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 12),
              (widget.voucher['trangthai'] == 0)
                  ? ElevatedButton.icon(
                    icon: Icon(Icons.visibility, color: Colors.white),
                    label: Text('Hiện voucher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Xác nhận'),
                              content: const Text(
                                'Bạn có chắc muốn hiện voucher này?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Hiện'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        final id =
                            widget.voucher['id'] ??
                            widget.voucher['id_voucher'];
                        final ok = await voucherController.showVoucher(
                          id is int ? id : int.tryParse(id.toString()) ?? 0,
                        );
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã hiện voucher')),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hiện voucher thất bại!'),
                            ),
                          );
                        }
                      }
                    },
                  )
                  : ElevatedButton.icon(
                    icon: Icon(Icons.visibility_off, color: Colors.white),
                    label: Text('Ẩn voucher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Xác nhận'),
                              content: const Text(
                                'Bạn có chắc muốn ẩn voucher này?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Ẩn'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        final id =
                            widget.voucher['id'] ??
                            widget.voucher['id_voucher'];
                        final ok = await voucherController.hideVoucher(
                          id is int ? id : int.tryParse(id.toString()) ?? 0,
                        );
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã ẩn voucher')),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ẩn voucher thất bại!'),
                            ),
                          );
                        }
                      }
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
