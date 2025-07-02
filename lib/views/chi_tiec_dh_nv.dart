import 'package:flutter/material.dart';
import 'package:luxe_silver_app/controllers/hoadon_controller.dart';
import 'package:luxe_silver_app/repository/hoadon_repository.dart';

class ChiTietDonHangNVScreen extends StatefulWidget {
  final String mahd;
  final Map<String, dynamic> userData;
  const ChiTietDonHangNVScreen({
    super.key,
    required this.mahd,
    required this.userData,
  });

  @override
  State<ChiTietDonHangNVScreen> createState() => _ChiTietDonHangNVScreenState();
}

class _ChiTietDonHangNVScreenState extends State<ChiTietDonHangNVScreen> {
  late Future<List<Map<String, dynamic>>> futureChiTiet;
  Map<String, dynamic>? hoaDonInfo;
  late HoaDonController hoaDonController;

  @override
  void initState() {
    super.initState();
    hoaDonController = HoaDonController();
    _loadData();
  }

  void _loadData() {
    futureChiTiet = hoaDonController.fetchChiTietHoaDon(widget.mahd);
    _fetchHoaDonInfo();
  }

  Future<void> _fetchHoaDonInfo() async {
    try {
      final list = await hoaDonController.fetchHoaDonList();
      if (mounted) {
        setState(() {
          hoaDonInfo = list.firstWhere(
            (e) => e['mahd'] == widget.mahd,
            orElse: () => {},
          );
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi khi tải thông tin đơn hàng: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    }
  }

  String formatPrice(dynamic price) {
    if (price == null) return '0 vnđ';
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        ) +
        ' vnđ';
  }

  Color _getStatusColor(int? statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.indigo;
      case 4:
        return Colors.green;
      case 5:
        return Colors.red;
      case 6:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng (NV)'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureChiTiet,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              hoaDonInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final chitiet = snapshot.data ?? [];
          if (chitiet.isEmpty) {
            return const Center(child: Text('Không có chi tiết đơn hàng'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfoCard(),
                const SizedBox(height: 20),
                _buildProductList(chitiet),
                const SizedBox(height: 20),
                _buildPaymentSummary(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hoaDonInfo?['id_nv'] != null &&
              hoaDonInfo?['ten_nhanvien'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Nhân viên xử lý: ${hoaDonInfo?['id_nv']} - ${hoaDonInfo?['ten_nhanvien']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.receipt_long, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Mã đơn: ${hoaDonInfo?['mahd'] ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Trạng thái: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(hoaDonInfo?['id_ttdh']),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  hoaDonInfo?['ten_trangthai'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Địa chỉ nhận hàng:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hoaDonInfo?['diachi'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.payment, size: 20, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'Thanh toán: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                hoaDonInfo?['phuongthuc_thanhtoan'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Map<String, dynamic>> chitiet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm đã mua',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...chitiet.map((product) => _buildProductCard(product)),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                product['image_url'] != null &&
                        product['image_url'].toString().isNotEmpty
                    ? Image.network(
                      product['image_url'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                    )
                    : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 12),
          // Thông tin chi tiết sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['tensp'] ?? 'Sản phẩm',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (product['size'] != null)
                  Text(
                    'Size: ${product['size']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Số lượng: ${product['soluong']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  formatPrice(product['gia']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, size: 32, color: Colors.grey[400]),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết thanh toán',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Tổng tiền hàng',
            formatPrice(hoaDonInfo?['tong_gia_sp']),
            Icons.shopping_bag,
          ),
          _buildSummaryRow(
            'Phí vận chuyển',
            formatPrice(hoaDonInfo?['tien_ship']),
            Icons.local_shipping,
          ),
          _buildSummaryRow(
            'Voucher giảm giá',
            hoaDonInfo?['id_voucher'] != null
                ? '-${formatPrice(_calculateVoucherDiscount())}'
                : '-0 vnđ',
            Icons.discount,
            isDiscount: true,
          ),
          if ((hoaDonInfo?['diem_sudung'] ?? 0) > 0)
            _buildSummaryRow(
              'Sử dụng điểm',
              '-${formatPrice(hoaDonInfo?['diem_sudung'])}',
              Icons.star,
              isDiscount: true,
            ),
          const SizedBox(height: 12),
          const Divider(thickness: 1.5),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                formatPrice(hoaDonInfo?['tonggia']),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateVoucherDiscount() {
    final tongGiaSp = hoaDonInfo?['tong_gia_sp'] ?? 0;
    final tienShip = hoaDonInfo?['tien_ship'] ?? 0;
    final tongGia = hoaDonInfo?['tonggia'] ?? 0;
    return (tongGiaSp + tienShip) - tongGia;
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDiscount ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final trangThai = hoaDonInfo?['id_ttdh'];
    if (trangThai == null) return const SizedBox.shrink();

    switch (trangThai) {
      case 1: // Chờ xác nhận
        return _buildConfirmCancelButtons();
      case 2: // Đang xử lý
        return _buildDeliveryButton();
      case 3: // Đang giao
        return _buildCompleteButton();
      case 4: // Đã nhận
        return _buildCompletedOrderInfo();
      case 5: // Đã hủy
        return _buildCancelledOrderInfo();
      case 6: // Trả hàng

        if (hoaDonInfo?['trangthai'] == 3) {
          return _buildApproveRejectReturnButtons();
        }
        return _buildReturnOrderInfo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildConfirmCancelButtons() {
    return Row(
      children: [
        // Hủy đơn (nhân viên)
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final idNvRaw = widget.userData['id_nv'];
              final int? idNv =
                  idNvRaw is int
                      ? idNvRaw
                      : int.tryParse(idNvRaw?.toString() ?? '');
              if (idNv == null) {
                _showSnackBar('Không xác định được mã nhân viên!', Colors.red);
                return;
              }
              String? lyDo = await showDialog<String>(
                context: context,
                builder: (context) {
                  String input = '';
                  return AlertDialog(
                    title: const Text('Lý do hủy đơn'),
                    content: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Nhập lý do hủy đơn',
                      ),
                      onChanged: (value) => input = value,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(input),
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  );
                },
              );
              if (lyDo == null || lyDo.trim().isEmpty) {
                _showSnackBar('Vui lòng nhập lý do hủy đơn!', Colors.red);
                return;
              }
              final ok = await hoaDonController.huyDonNV(
                widget.mahd,
                lyDo,
                idNv,
              );
              if (ok && mounted) {
                _showSnackBar('Đã hủy đơn hàng', Colors.red);
                setState(() {
                  hoaDonInfo?['id_ttdh'] = 5;
                  hoaDonInfo?['ten_trangthai'] = 'Đã hủy';
                  hoaDonInfo?['id_nv'] = idNv;
                  hoaDonInfo?['ten_nhanvien'] = widget.userData['ten'];
                });
                await _fetchHoaDonInfo();
                setState(() {});
              }
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Hủy đơn'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Xác nhận đơn (gán nhân viên xử lý)
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final idNvRaw = widget.userData['id_nv'];
              final int? idNv =
                  idNvRaw is int
                      ? idNvRaw
                      : int.tryParse(idNvRaw?.toString() ?? '');
              final tenNv = widget.userData['ten'];
              if (idNv == null) {
                _showSnackBar('Không xác định được mã nhân viên!', Colors.red);
                return;
              }
              // Gán nhân viên xử lý cho đơn hàng
              final okNv = await hoaDonController.ganNhanVien(
                widget.mahd,
                idNv,
              );
              // Gọi API cập nhật trạng thái sang Đang xử lý
              final okTrangThai = await hoaDonController.dangXuLy(widget.mahd);
              if (okNv && okTrangThai && mounted) {
                _showSnackBar('Đã xác nhận đơn', Colors.green);
                setState(() {
                  hoaDonInfo?['id_ttdh'] = 2;
                  hoaDonInfo?['ten_trangthai'] = 'Đang xử lý';
                  hoaDonInfo?['id_nv'] = idNv;
                  hoaDonInfo?['ten_nhanvien'] = tenNv;
                });
                await _fetchHoaDonInfo();
              } else {
                _showSnackBar('Cập nhật trạng thái thất bại!', Colors.red);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Xác nhận'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final idNvRaw = widget.userData['id_nv'];
          final int? idNv =
              idNvRaw is int
                  ? idNvRaw
                  : int.tryParse(idNvRaw?.toString() ?? '');
          final tenNv = widget.userData['ten'];
          if (idNv == null) {
            _showSnackBar('Không xác định được mã nhân viên!', Colors.red);
            return;
          }
          // Gán nhân viên xử lý cho đơn hàng (nếu chưa có hoặc muốn cập nhật lại)
          final okNv = await hoaDonController.ganNhanVien(widget.mahd, idNv);
          // Chuyển trạng thái sang Đang giao
          final ok = await hoaDonController.daGiaoHang(widget.mahd);
          if (okNv && ok && mounted) {
            _showSnackBar('Đã chuyển sang trạng thái Đang giao', Colors.blue);
            setState(() {
              hoaDonInfo?['id_ttdh'] = 3;
              hoaDonInfo?['ten_trangthai'] = 'Đang giao';
              hoaDonInfo?['id_nv'] = idNv;
              hoaDonInfo?['ten_nhanvien'] = tenNv;
            });
            await _fetchHoaDonInfo();
          } else {
            _showSnackBar('Cập nhật trạng thái thất bại!', Colors.red);
          }
        },
        icon: const Icon(Icons.local_shipping),
        label: const Text('Giao hàng'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    // Kiểm tra trạng thái đơn hàng
    final idTtdh = hoaDonInfo?['id_ttdh'];
    final trangThai = hoaDonInfo?['trangthai'];

    // Nếu đã xác nhận giao tới
    if (idTtdh == 3 && trangThai == 1) {
      return Row(
        children: [
          // Nút Thu hồi
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final idNvRaw = widget.userData['id_nv'];
                final int? idNv =
                    idNvRaw is int
                        ? idNvRaw
                        : int.tryParse(idNvRaw?.toString() ?? '');
                if (idNv == null) {
                  _showSnackBar(
                    'Không xác định được mã nhân viên!',
                    Colors.red,
                  );
                  return;
                }
                String? lyDo = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String input = '';
                    return AlertDialog(
                      title: const Text('Lý do thu hồi hàng trả'),
                      content: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Nhập lý do thu hồi hàng trả',
                        ),
                        onChanged: (value) => input = value,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(input),
                          child: const Text('Xác nhận'),
                        ),
                      ],
                    );
                  },
                );
                if (lyDo == null || lyDo.trim().isEmpty) {
                  _showSnackBar(
                    'Vui lòng nhập lý do thu hồi hàng trả!',
                    Colors.red,
                  );
                  return;
                }
                // Gọi API thu hồi hàng trả
                final ok = await hoaDonController.thuHoiHang(
                  widget.mahd,
                  lyDo,
                  idNv,
                );
                if (ok && mounted) {
                  _showSnackBar(
                    'Đã chuyển sang trạng thái trả hàng',
                    Colors.orange,
                  );
                  setState(() {
                    hoaDonInfo?['id_ttdh'] = 6;
                    hoaDonInfo?['ten_trangthai'] = 'Trả hàng';
                    hoaDonInfo?['id_nv'] = idNv;
                    hoaDonInfo?['ten_nhanvien'] = widget.userData['ten'];
                  });
                  await _fetchHoaDonInfo();
                  setState(() {});
                }
              },
              icon: const Icon(Icons.undo),
              label: const Text('Thu hồi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút Đã giao tới
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final idNvRaw = widget.userData['id_nv'];
                final int? idNv =
                    idNvRaw is int
                        ? idNvRaw
                        : int.tryParse(idNvRaw?.toString() ?? '');
                final tenNv = widget.userData['ten'];
                if (idNv == null) {
                  _showSnackBar(
                    'Không xác định được mã nhân viên!',
                    Colors.red,
                  );
                  return;
                }
                // Gán nhân viên xử lý cho đơn hàng (nếu chưa có hoặc muốn cập nhật lại)
                final okNv = await hoaDonController.ganNhanVien(
                  widget.mahd,
                  idNv,
                );
                // Chuyển chờ xử lý
                final ok = await hoaDonController.daGiaoHang(widget.mahd);
                if (okNv && ok && mounted) {
                  _showSnackBar('Đã xác nhận khách đã nhận hàng', Colors.green);
                  setState(() {
                    hoaDonInfo?['id_ttdh'] = 4;
                    hoaDonInfo?['ten_trangthai'] = 'Đã nhận';
                    hoaDonInfo?['id_nv'] = idNv;
                    hoaDonInfo?['ten_nhanvien'] = tenNv;
                  });
                  await _fetchHoaDonInfo();
                } else {
                  _showSnackBar('Cập nhật trạng thái thất bại!', Colors.red);
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Đã giao tới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Center(
      child: ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_top),
        label: const Text('Đang chờ xử lý nhận hàng'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCompletedOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn hàng đã hoàn thành',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Đơn hàng đã hoàn thành và giao cho khách.',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledOrderInfo() {
    final lyDoKh = hoaDonInfo?['ly_do_kh'];
    final lyDoNv = hoaDonInfo?['ly_do_nv'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel, color: Colors.red[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đơn hàng đã bị hủy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đơn hàng này đã được hủy.',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
                if (lyDoKh != null && lyDoKh.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lý do khách từ chối: $lyDoKh',
                    style: const TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (lyDoNv != null && lyDoNv.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lý do nhân viên từ chối: $lyDoNv',
                    style: const TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnOrderInfo() {
    final lyDoKh = hoaDonInfo?['ly_do_kh'];
    final lyDoNv = hoaDonInfo?['ly_do_nv'];
    final trangThai = hoaDonInfo?['trangthai'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.keyboard_return, color: Colors.orange[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trangThai == 1
                      ? 'Trả hàng thành công'
                      : 'Đang xử lý trả hàng',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                if (trangThai != 1)
                  const Text(
                    'Yêu cầu trả hàng đang được xử lý.',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                if (lyDoKh != null && lyDoKh.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lý do khách trả hàng: $lyDoKh',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (lyDoNv != null && lyDoNv.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'NV: $lyDoNv',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApproveRejectReturnButtons() {
    return Row(
      children: [
        // Nút Không duyệt
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              String? lyDo = await showDialog<String>(
                context: context,
                builder: (context) {
                  String input = '';
                  return AlertDialog(
                    title: const Text('Lý do không duyệt trả hàng'),
                    content: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Nhập lý do không duyệt',
                      ),
                      onChanged: (value) => input = value,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(input),
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  );
                },
              );
              if (lyDo == null || lyDo.trim().isEmpty) {
                _showSnackBar('Vui lòng nhập lý do!', Colors.red);
                return;
              }
              final idNvRaw = widget.userData['id_nv'];
              final int? idNv =
                  idNvRaw is int
                      ? idNvRaw
                      : int.tryParse(idNvRaw?.toString() ?? '');
              if (idNv == null) {
                _showSnackBar('Không xác định được mã nhân viên!', Colors.red);
                return;
              }
              final ok = await hoaDonController.duyetTraHang(
                widget.mahd,
                false,
                lyDoNv: lyDo,
                idNv: idNv,
              );
              if (ok && mounted) {
                _showSnackBar('Đã từ chối yêu cầu trả hàng', Colors.red);
                await _fetchHoaDonInfo();
              }
            },
            icon: const Icon(Icons.cancel),
            label: const Text('Không duyệt'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Nút Duyệt
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final idNvRaw = widget.userData['id_nv'];
              final int? idNv =
                  idNvRaw is int
                      ? idNvRaw
                      : int.tryParse(idNvRaw?.toString() ?? '');
              if (idNv == null) {
                _showSnackBar('Không xác định được mã nhân viên!', Colors.red);
                return;
              }
              final ok = await hoaDonController.duyetTraHang(
                widget.mahd,
                true,
                idNv: idNv,
              );
              if (ok && mounted) {
                _showSnackBar('Đã duyệt trả hàng', Colors.green);
                await _fetchHoaDonInfo();
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Duyệt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
