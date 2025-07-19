import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/voucher_controller.dart';
import 'package:luxe_silver_app/views/voucher_add.dart';
import 'package:luxe_silver_app/views/voucher_cart.dart';
import 'package:luxe_silver_app/views/voucher_edit.dart';
import 'package:intl/intl.dart';

class VoucherScreen extends StatefulWidget {
  final double cartTotal; //tổng giá trị giỏ hàng
  final Map<String, dynamic> userData; //thông tin người dùng
  final Map<String, dynamic>? selectedVoucher; //voucher đã chọn (nếu có)
  final bool isAdmin;

  const VoucherScreen({
    super.key,
    required this.cartTotal,
    required this.userData,
    this.selectedVoucher,
    this.isAdmin = false,
  });

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final voucherController = VoucherController();
  // load danh sách voucher từ server
  late Future<List<Map<String, dynamic>>> _voucherFuture;

  //voucher hiện tại được chọn
  Map<String, dynamic>? selectedVoucher;

  bool get isAdmin => widget.userData['role'] == 'admin';

  @override
  void initState() {
    super.initState();
    // khởi tạo việc load voucher khi màn hình được tạo
    _voucherFuture = voucherController.fetchVouchers();
    //gán voucher đã chọn từ tham số truyền vào
    selectedVoucher = widget.selectedVoucher;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    final minOrder =
        selectedVoucher != null ? selectedVoucher!['giatri_min'] ?? 0 : 0;
    final minOrderStr = formatter.format(minOrder);

    return Scaffold(
      appBar: AppBar(
        title: Text('Voucher'),
        backgroundColor: AppColors.appBarBackground,
      ),

      // Nội dung chính - danh sách voucher
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _voucherFuture,
        builder: (context, snapshot) {
          // Hiển thị loading khi đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Hiển thị thông báo khi không có voucher nào
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có voucher nào'));
          }
          final now = DateTime.now();
          final vouchers =
              snapshot.data!
                  .where(
                    (v) =>
                        isAdmin ||
                        ((v['trangthai'] == 1 || v['trangthai'] == null) &&
                            (v['soluong'] ?? 0) > 0 &&
                            (v['ngayketthuc'] == null ||
                                DateTime.tryParse(
                                      v['ngayketthuc'].toString(),
                                    )?.isAfter(now) ==
                                    true)),
                  )
                  .toList();
          if (selectedVoucher != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Đã chọn: ${selectedVoucher!['ten'] ?? 'Voucher'}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Đơn tối thiểu: $minOrderStr VNĐ',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedVoucher = null;
                      });
                    },
                    child: const Icon(Icons.close, color: Colors.green),
                  ),
                ],
              ),
            );

          // Hiển thị danh sách voucher
          return Column(
            children: [
              if (selectedVoucher != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Đã chọn: ${selectedVoucher!['ten'] ?? 'Voucher'}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Đơn tối thiểu: $minOrderStr VNĐ',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedVoucher = null;
                          });
                        },
                        child: const Icon(Icons.close, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(8),
                  itemCount: vouchers.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final voucher = vouchers[index];
                    final minOrder =
                        voucher['giatri_min'] ??
                        0; //ggiá trị đơn hàng tối thiểu
                    final isAdmin =
                        widget.userData['role'] == 'admin'; // Kiểm tra admin

                    // Voucher được kích hoạt nếu là admin hoặc đạt giá trị tối thiểu
                    final isEnabled = isAdmin || widget.cartTotal >= minOrder;

                    return IgnorePointer(
                      ignoring:
                          !isEnabled, // Vô hiệu hóa tương tác nếu không đủ điều kiện
                      child: Opacity(
                        opacity:
                            isEnabled
                                ? 1.0
                                : 0.4, // Làm mờ voucher không đủ điều kiện
                        child: Builder(
                          builder: (context) {
                            //////// in thử ra giá trị để kiểm tra
                            print(
                              'Voucher ID: ${voucher['id']}, Selected ID: ${selectedVoucher?['id']}',
                            );
                            final isSelected =
                                selectedVoucher != null &&
                                voucher['id'] != null &&
                                voucher['id'].toString() ==
                                    selectedVoucher!['id'].toString();

                            print(
                              'Voucher ${voucher['ten']} - isSelected: $isSelected',
                            );

                            return VoucherCard(
                              voucher: voucher,
                              onTap: (tappedVoucher) {
                                if (isAdmin) {
                                  //admin, chuyển sang trang chỉnh sửa voucher
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => VoucherEditScreen(
                                            voucher: {
                                              'id':
                                                  voucher['id'] ??
                                                  voucher['id_voucher'],
                                              ...voucher,
                                            },
                                          ),
                                    ),
                                  ).then((_) {
                                    //  reload lại danh sách voucher
                                    setState(() {
                                      _voucherFuture =
                                          voucherController.fetchVouchers();
                                    });
                                  });
                                } else if (isEnabled) {
                                  // Người dùng thường: chọn voucher
                                  setState(() {
                                    final isCurrentlySelected =
                                        selectedVoucher != null &&
                                        voucher['id'] != null &&
                                        voucher['id'].toString() ==
                                            selectedVoucher!['id'].toString();
                                    if (isCurrentlySelected) {
                                      selectedVoucher = null;
                                    } else {
                                      selectedVoucher =
                                          Map<String, dynamic>.from(voucher);
                                    }
                                  });
                                }
                              },
                              trailing: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isEnabled ? Colors.green : Colors.grey,
                                    width: 2,
                                  ),
                                  color:
                                      isSelected
                                          ? Colors.green
                                          : Colors.transparent,
                                ),
                                child:
                                    isSelected
                                        ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                        : null,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      // Nút áp dụng voucher ở cuối màn hình
      bottomNavigationBar:
          isAdmin
              ? null
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedVoucher);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    selectedVoucher != null
                        ? 'Áp dụng voucher'
                        : 'Không dùng voucher',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
      // Nút thêm voucher (chỉ hiển thị cho admin)
      floatingActionButton:
          widget.userData['role'] == 'admin'
              ? FloatingActionButton(
                backgroundColor: AppColors.appBarBackground,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddVoucherScreen()),
                  ).then((_) {
                    //reload lại danh sách
                    setState(() {
                      _voucherFuture = voucherController.fetchVouchers();
                    });
                  });
                },
                child: Icon(Icons.add, size: 32),
              )
              : null, // Không hiển thị nếu không phải admin
    );
  }
}
