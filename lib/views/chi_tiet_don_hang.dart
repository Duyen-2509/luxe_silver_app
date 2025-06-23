import 'package:flutter/material.dart';
import 'package:luxe_silver_app/controllers/hoadon_controller.dart';

class ChiTietDonHangScreen extends StatefulWidget {
  final String mahd;
  const ChiTietDonHangScreen({super.key, required this.mahd});

  @override
  State<ChiTietDonHangScreen> createState() => _ChiTietDonHangScreenState();
}

class _ChiTietDonHangScreenState extends State<ChiTietDonHangScreen> {
  late Future<List<Map<String, dynamic>>> futureChiTiet;
  Map<String, dynamic>? hoaDonInfo;

  @override
  void initState() {
    super.initState();
    futureChiTiet = HoaDonController().fetchChiTietHoaDon(widget.mahd);
    _fetchHoaDonInfo();
  }

  Future<void> _fetchHoaDonInfo() async {
    // Lấy danh sách hóa đơn, tìm hóa đơn theo mã
    final list = await HoaDonController().fetchHoaDonList();
    setState(() {
      hoaDonInfo = list.firstWhere(
        (e) => e['mahd'] == widget.mahd,
        orElse: () => {},
      );
    });
  }

  String formatPrice(dynamic price) {
    if (price == null) return '';
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} vnđ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
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
                // Địa chỉ nhận hàng
                // Thông tin mã hóa đơn, trạng thái, phương thức thanh toán
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã đơn: ${hoaDonInfo?['mahd'] ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Trạng thái: ${hoaDonInfo?['ten_trangthai'] ?? ''}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'Địa chỉ nhận: ${hoaDonInfo?['diachi'] ?? ''}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Phương thức thanh toán: ${hoaDonInfo?['phuongthuc_thanhtoan'] ?? ''}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Danh sách sản phẩm
                ...chitiet.map(
                  (ct) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hình ảnh sản phẩm (nếu backend trả về)
                          if (ct['image_url'] != null &&
                              ct['image_url'].toString().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                ct['image_url'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                              ),
                            )
                          else
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.image, color: Colors.grey[400]),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ct['tensp'] ?? 'Sản phẩm',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (ct['size'] != null)
                                  Text(
                                    'Size: ${ct['size']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Số lượng: ${ct['soluong']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formatPrice(ct['gia']),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Chi tiết thanh toán
                const Text(
                  'Chi tiết thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Tổng tiền hàng',
                  formatPrice(hoaDonInfo?['tong_gia_sp']),
                ),
                _buildSummaryRow(
                  'Tổng phí vận chuyển',
                  formatPrice(hoaDonInfo?['tien_ship']),
                ),
                _buildSummaryRow(
                  'Voucher',
                  hoaDonInfo?['id_voucher'] != null
                      ? '-${formatPrice((hoaDonInfo?['tong_gia_sp'] ?? 0) + (hoaDonInfo?['tien_ship'] ?? 0) - (hoaDonInfo?['tonggia'] ?? 0))}'
                      : '-0 vnđ',
                ),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      formatPrice(hoaDonInfo?['tonggia']),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                if (hoaDonInfo?['id_ttdh'] == 3) // 3 = Đang giao
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final ok = await HoaDonController()
                                .updateTrangThaiHoaDon(widget.mahd, 6);
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã gửi yêu cầu trả hàng'),
                                ),
                              );
                              setState(() {
                                hoaDonInfo?['id_ttdh'] = 6;
                                hoaDonInfo?['ten_trangthai'] = 'Trả hàng';
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Trả hàng',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final ok = await HoaDonController()
                                .updateTrangThaiHoaDon(widget.mahd, 4);
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xác nhận nhận hàng'),
                                ),
                              );
                              setState(() {
                                hoaDonInfo?['id_ttdh'] = 4;
                                hoaDonInfo?['ten_trangthai'] = 'Đã nhận';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Đã nhận',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
