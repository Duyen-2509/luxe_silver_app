import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/giohang_controller.dart';
import 'package:luxe_silver_app/controllers/voucher_controller.dart';
import 'package:luxe_silver_app/models/giohang_model.dart';
import 'package:luxe_silver_app/models/sanPham_model.dart';
import 'package:luxe_silver_app/repository/tienship_repository.dart';
import 'package:luxe_silver_app/views/dia_chi_nhanhang.dart';
import 'package:luxe_silver_app/views/don_hang.dart';
import 'package:luxe_silver_app/views/gio_hang.dart';
import 'package:luxe_silver_app/views/stripe_payment_screen.dart';
import 'package:luxe_silver_app/views/voucher_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:luxe_silver_app/controllers/hoadon_controller.dart';

class CheckoutScreen extends StatefulWidget {
  final SanPham? product;
  final int? quantity;
  final String? selectedSize;
  final double cartTotal;
  final List<CartItem> selectedItems;
  final Map<String, dynamic> userData;

  const CheckoutScreen({
    Key? key,
    required this.cartTotal,
    required this.userData,
    this.product,
    this.quantity,
    required this.selectedItems,

    this.selectedSize,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartController cartController = CartController();
  double? _shippingFee;
  bool _loadingShippingFee = true;
  Map<String, dynamic>? selectedVoucher;
  double voucherDiscount = 0.0;
  String? shippingName;
  String? shippingAddress;
  String? shippingPhone;
  String paymentMethod = 'cod';
  int usedPoints = 0;
  double pointDiscount = 0.0;
  String formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} vnđ';
  }

  @override
  void initState() {
    super.initState();
    _loadShippingInfo();
    _fetchShippingFee();
  }

  // thanh toán ví
  Future<void> _saveOrder(Map<String, dynamic> hoadonData) async {
    try {
      final hoaDonController = HoaDonController();
      final result = await hoaDonController.addHoaDon(hoadonData);

      if (result != null && result['mahd'] != null) {
        // Nếu có voucher, gọi API giảm số lượng voucher
        if (selectedVoucher != null) {
          final voucherController = VoucherController();
          await voucherController.useVoucher(selectedVoucher!['id_voucher']);
        }
        // XÓA GIỎ HÀNG SAU KHI THANH TOÁN
        cartController.clearCart();
        // 4. Chuyển sang trang Đơn hàng
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DonHangScreen(userData: widget.userData),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tạo hóa đơn thất bại!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tạo hóa đơn: $e')));
    }
  }

  Future<void> _fetchShippingFee() async {
    try {
      final repo = TienShipRepository();
      final list = await repo.getTienShip();
      if (!mounted) return;
      if (list.isNotEmpty) {
        setState(() {
          _shippingFee = (list.first['gia'] as num).toDouble();
          _loadingShippingFee = false;
        });
      } else {
        setState(() {
          _shippingFee = 0;
          _loadingShippingFee = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _shippingFee = 0;
        _loadingShippingFee = false;
      });
    }
  }

  Future<void> _loadShippingInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId =
        widget.userData['id']?.toString() ??
        widget.userData['sodienthoai'] ??
        '';
    if (!mounted) return;
    setState(() {
      shippingName = prefs.getString('shippingName_$userId');
      shippingAddress = prefs.getString('shippingAddress_$userId');
      final phone = prefs.getString('shippingPhone_$userId');
      shippingPhone =
          (phone == null || phone.isEmpty)
              ? widget.userData['sodienthoai']?.toString() ?? ''
              : phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingShippingFee) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final shippingFee = _shippingFee ?? 0.0;
    final totalVoucher = voucherDiscount;
    final bool isBuyNow = widget.product != null;
    final items =
        isBuyNow
            ? [
              {
                'sanPham': widget.product!,
                'soLuong': widget.quantity ?? 1,
                'selectedSize': widget.selectedSize,
                'giaDonVi':
                    widget.product!.details != null &&
                            widget.product!.details!.isNotEmpty
                        ? widget.product!.details!.first.gia
                        : 0,
              },
            ]
            : widget.selectedItems;

    final totalProduct =
        isBuyNow
            ? ((items[0] as Map<String, dynamic>)['giaDonVi'] as int) *
                ((items[0] as Map<String, dynamic>)['soLuong'] as int)
            : cartController.totalPrice;

    final totalPayment =
        totalProduct + shippingFee - totalVoucher - pointDiscount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Địa chỉ nhận hàng
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // Hiển thị tên người nhận: ưu tiên tên mới, nếu chưa có thì lấy tên user
                                  'Người nhận: ${shippingName ?? widget.userData['ten']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  // Hiển thị tên người nhận: ưu tiên tên mới, nếu chưa có thì lấy tên user
                                  'SĐT: ${shippingPhone ?? widget.userData['sdt'] ?? ""}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  // Hiển thị địa chỉ nhận hàng: ưu tiên địa chỉ mới, nếu chưa có thì lấy địa chỉ user
                                  'Địa chỉ: ${shippingAddress ?? widget.userData['diachi']}',
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DiaChiNhanHangScreen(
                                        currentName:
                                            shippingName ??
                                            widget.userData['ten'],
                                        currentAddress: ' ',
                                        currentPhone:
                                            shippingPhone ??
                                            widget.userData['sdt'] ??
                                            '',
                                      ),
                                ),
                              );
                              if (result != null &&
                                  result is Map<String, String>) {
                                if (!mounted) return;
                                setState(() {
                                  shippingName = result['name'];
                                  shippingAddress = result['address'];
                                  shippingPhone = result['phone'];
                                });
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final userId =
                                    widget.userData['id']?.toString() ??
                                    widget.userData['email'] ??
                                    '';
                                await prefs.setString(
                                  'shippingName_$userId',
                                  shippingName!,
                                );
                                await prefs.setString(
                                  'shippingAddress_$userId',
                                  shippingAddress!,
                                );
                                await prefs.setString(
                                  'shippingPhone_$userId',
                                  shippingPhone ?? '',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Danh sách sản phẩm
                    ...items.map((item) {
                      final sanPham =
                          isBuyNow
                              ? (item as Map<String, dynamic>)['sanPham']
                                  as SanPham
                              : (item as CartItem).sanPham;
                      final soLuong =
                          isBuyNow
                              ? (item as Map<String, dynamic>)['soLuong'] as int
                              : (item as CartItem).soLuong;
                      final selectedSize =
                          isBuyNow
                              ? (item as Map<String, dynamic>)['selectedSize']
                              : (item as CartItem).selectedSize;
                      final giaDonVi =
                          isBuyNow
                              ? (item as Map<String, dynamic>)['giaDonVi']
                                  as int
                              : (item as CartItem).giaDonVi;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildProductItem(
                          sanPham.tensp,
                          selectedSize == null
                              ? ''
                              : 'Size: ${selectedSize == '0' ? 'Freesize' : selectedSize}',
                          soLuong,
                          formatPrice(giaDonVi.toDouble()),
                          sanPham.imageUrl ??
                              (sanPham.images != null &&
                                      sanPham.images!.isNotEmpty
                                  ? sanPham.images!.first
                                  : ''),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Phương thức thanh toán
                    InkWell(
                      onTap: () async {
                        final selected = await showDialog<String>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: AppColors.alertDialog,
                                title: Text(
                                  'Chọn phương thức thanh toán',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.money,
                                        color: Colors.green,
                                      ),
                                      title: Text(
                                        'Thanh toán khi nhận hàng',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      onTap:
                                          () => Navigator.pop(context, 'cod'),
                                    ),
                                    SizedBox(height: 12),
                                    ListTile(
                                      leading: Icon(
                                        Icons.qr_code,
                                        color: Colors.blue,
                                      ),
                                      title: Text(
                                        'Thanh toán qua Stripe',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      onTap:
                                          () =>
                                              Navigator.pop(context, 'stripe'),
                                    ),
                                  ],
                                ),
                              ),
                        );
                        if (selected != null && selected != paymentMethod) {
                          setState(() {
                            paymentMethod = selected;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Phương thức thanh toán',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    paymentMethod == 'cod'
                                        ? 'Thanh toán khi nhận hàng'
                                        : 'Thanh toán qua Stripe',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Voucher section
                    InkWell(
                      onTap: () async {
                        final voucher = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VoucherScreen(
                                  cartTotal: widget.cartTotal,
                                  userData: widget.userData,
                                  selectedVoucher: selectedVoucher,
                                ),
                          ),
                        );

                        // Luôn cập nhật lại selectedVoucher và voucherDiscount, kể cả khi voucher == null
                        setState(() {
                          selectedVoucher = voucher;
                          if (voucher != null) {
                            final double value =
                                double.tryParse(
                                  voucher['sotiengiam'].toString(),
                                ) ??
                                0.0;
                            if (value > 0 && value < 1) {
                              voucherDiscount = widget.cartTotal * value;
                            } else {
                              voucherDiscount = value;
                            }
                          } else {
                            voucherDiscount = 0.0;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_offer, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedVoucher != null
                                    ? 'Đã áp dụng voucher: ${selectedVoucher!['ten']}'
                                    : 'Chọn voucher',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nhập điểm sử dụng
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  'Sử dụng điểm (tối đa: ${widget.userData['diem'] ?? 0})',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                usedPoints = int.tryParse(value) ?? 0;
                                final maxPoints = widget.userData['diem'] ?? 0;
                                if (usedPoints > maxPoints)
                                  usedPoints = maxPoints;
                                if (usedPoints < 0) usedPoints = 0;
                                pointDiscount = usedPoints * 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '= ${pointDiscount.toStringAsFixed(0)}đ',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Chi tiết thanh toán
                    const Text(
                      'Chi tiết thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildSummaryRow(
                      'Tổng tiền hàng',
                      formatPrice(totalProduct.toDouble()),
                    ),
                    _buildSummaryRow(
                      'Tổng phí vận chuyển',
                      formatPrice(shippingFee),
                    ),
                    _buildSummaryRow(
                      'Tổng voucher',
                      '-${formatPrice(totalVoucher)}',
                    ),
                    if (usedPoints > 0)
                      _buildSummaryRow(
                        'Sử dụng điểm',
                        '-${formatPrice(pointDiscount)} ',
                      ),

                    const Divider(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formatPrice(totalPayment),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Nút thanh toán
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Lấy userId và các thông tin cần thiết
                    final userId = widget.userData['id']?.toString() ?? '';
                    final tenNguoiNhan = shippingName ?? widget.userData['ten'];
                    final diaChi = shippingAddress ?? widget.userData['diachi'];
                    final soDienThoai =
                        shippingPhone ?? widget.userData['sdt'] ?? '';
                    final diaChiFull = '$tenNguoiNhan - $soDienThoai - $diaChi';
                    final phuongThuc =
                        paymentMethod == 'cod'
                            ? 'Thanh toán khi nhận hàng'
                            : 'Thanh toán qua Stripe';
                    final List chitiet =
                        (widget.product != null)
                            ? [
                              {
                                'id_sp': widget.product!.idSp,
                                'id_ctsp':
                                    widget.product!.details != null &&
                                            widget.product!.details!.isNotEmpty
                                        ? widget.product!.details!.first.idCtsp
                                        : null,
                                'soluong': widget.quantity ?? 1,
                                'gia':
                                    widget.product!.details != null &&
                                            widget.product!.details!.isNotEmpty
                                        ? widget.product!.details!.first.gia
                                        : 0,
                              },
                            ]
                            : cartController.cartItems
                                .map(
                                  (item) => {
                                    'id_sp': item.sanPham.idSp,
                                    'id_ctsp':
                                        item.sanPham.details != null &&
                                                item.sanPham.details!.isNotEmpty
                                            ? item.sanPham.details!.first.idCtsp
                                            : null,
                                    'soluong': item.soLuong,
                                    'gia': item.giaDonVi,
                                  },
                                )
                                .toList();

                    // Kiểm tra địa chỉ
                    if (diaChi == null || diaChi.trim().isEmpty) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: AppColors.alertDialog,
                              title: const Text(
                                'Thiếu địa chỉ nhận hàng',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              content: const Text(
                                'Vui lòng nhập địa chỉ nhận hàng trước khi thanh toán.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Đóng'),
                                ),
                              ],
                            ),
                      );
                      return;
                    }
                    // Kiểm tra số điện thoại
                    if (soDienThoai.trim().isEmpty) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: AppColors.alertDialog,
                              title: const Text(
                                'Thiếu số điện thoại',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              content: const Text(
                                'Vui lòng nhập số điện thoại nhận hàng trước khi thanh toán.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Đóng'),
                                ),
                              ],
                            ),
                      );
                      return;
                    }

                    // Chuẩn bị dữ liệu gửi lên API
                    final hoadonData = {
                      'id_kh': int.tryParse(userId) ?? 0,
                      'tong_gia_sp': totalProduct.round(),
                      'tonggia': totalPayment.round(),
                      'tien_ship': 30000,
                      'id_voucher':
                          selectedVoucher != null
                              ? selectedVoucher!['id_voucher']
                              : null,
                      'diachi': diaChiFull,
                      'phuongthuc_thanhtoan': phuongThuc,
                      'chitiet': chitiet,
                    };
                    if (usedPoints > 0) {
                      hoadonData['used_points'] = usedPoints;
                    }
                    if (hoadonData['id_voucher'] == null) {
                      hoadonData.remove('id_voucher');
                    }

                    // --- PHÂN NHÁNH THANH TOÁN ---
                    if (paymentMethod == 'stripe') {
                      // Nếu chọn Stripe, chuyển sang màn hình nhập thẻ
                      final stripeResult = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => StripePaymentScreen(
                                amount: totalPayment.round(),
                              ),
                        ),
                      );
                      if (stripeResult == true) {
                        // Nếu thanh toán Stripe thành công, lưu hóa đơn như COD
                        await _saveOrder(hoadonData);
                      }
                    } else {
                      // Nếu chọn COD, lưu hóa đơn luôn
                      await _saveOrder(hoadonData);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Thanh toán',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(
    String name,
    String size,
    int quantity,
    String price,
    String imageUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  size,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Số lượng: $quantity',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> clearShippingInfo(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shippingName_$userId');
    await prefs.remove('shippingAddress_$userId');
  }
}
