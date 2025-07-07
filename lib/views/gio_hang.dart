import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/giohang_controller.dart';
import 'package:luxe_silver_app/views/don_hang.dart';
import '../models/sanPham_model.dart';
import '../models/giohang_model.dart';
import 'package:luxe_silver_app/views/thanh_toan.dart';
import 'package:luxe_silver_app/views/chi_tiet_sp.dart';
import 'package:luxe_silver_app/views/tai_khoan.dart';
import 'package:luxe_silver_app/views/voucher_screen.dart';

// Controller quản lý giỏ hàng (singleton)

class CartScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CartScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = CartController();
  late List<bool> _selectedItems;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.generate(
      cartController.cartItems.length,
      (_) => false,
    );
  }

  String _getDonVi(CartItem item) {
    if (item.sanPham.details == null) return '';
    final detail = item.sanPham.details!.firstWhere(
      (d) => d.kichthuoc.toString() == item.selectedSize,
      orElse: () => item.sanPham.details!.first,
    );
    return detail.kichthuoc == 0 ? '' : detail.donvi;
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} vnđ';
  }

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      // Đang ở giỏ hàng, không làm gì
    } else if (index == 2) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonHangScreen(userData: widget.userData),
        ),
      );
    } else if (index == 3) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: widget.userData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                cartController.cartItems.isEmpty
                    ? _buildEmptyCart()
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartController.cartItems.length,
                      itemBuilder: (context, index) {
                        // Luôn đồng bộ lại _selectedItems với số lượng sản phẩm trong giỏ
                        if (_selectedItems.length !=
                            cartController.cartItems.length) {
                          _selectedItems = List.generate(
                            cartController.cartItems.length,
                            (i) =>
                                i < _selectedItems.length
                                    ? _selectedItems[i]
                                    : false,
                          );
                        }
                        final item = cartController.cartItems[index];
                        return _buildCartItem(item, index);
                      },
                    ),
          ),
          if (cartController.cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (value) {
                          setState(() {
                            _selectAll = value ?? false;
                            for (int i = 0; i < _selectedItems.length; i++) {
                              _selectedItems[i] = _selectAll;
                            }
                          });
                        },
                      ),
                      const Text('Chọn tất cả'),
                    ],
                  ),
                  if (cartController.cartItems.isNotEmpty)
                    _buildBottomSection(),
                ],
              ),
            ),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.bottomNavBackground,
          selectedItemColor: AppColors.bottomNavSelected,
          unselectedItemColor: AppColors.bottomNavUnselected,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Giỏ hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng của bạn đang trống',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng để tiếp tục',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProductDetailScreen(
                        userData: widget.userData,
                        productId: item.sanPham.idSp,
                      ),
                ),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    item.sanPham.imageUrl != null
                        ? Image.network(
                          item.sanPham.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                        : (item.sanPham.images != null &&
                                item.sanPham.images!.isNotEmpty
                            ? Image.network(
                              item.sanPham.images!.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              color: Colors.grey[100],
                              width: 60,
                              height: 60,
                              child: Icon(Icons.image, color: Colors.grey[400]),
                            )),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Chi tiết sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.sanPham.tensp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                if (item.selectedSize != null)
                  Text(
                    'Size: ${item.selectedSize == '0' ? 'Freesize' : '${item.selectedSize} ${_getDonVi(item)}'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Số lượng: '),
                    Text(
                      '${item.soLuong}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Nút giảm
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed:
                            item.soLuong > 1
                                ? () {
                                  setState(() {
                                    cartController.updateQuantity(
                                      index,
                                      item.soLuong - 1,
                                    );
                                  });
                                }
                                : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Nút tăng
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                        // Kiểm tra số lượng tối đa
                        onPressed: () {
                          final detail =
                              item.sanPham.details != null &&
                                      item.sanPham.details!.isNotEmpty
                                  ? (item.selectedSize != null
                                      ? item.sanPham.details!.firstWhere(
                                        (d) => d.kichthuoc == item.selectedSize,
                                        orElse:
                                            () => item.sanPham.details!.first,
                                      )
                                      : item.sanPham.details!.first)
                                  : null;
                          final maxQty = detail?.soluongKho ?? 1;
                          if (item.soLuong < maxQty) {
                            setState(() {
                              cartController.updateQuantity(
                                index,
                                item.soLuong + 1,
                              );
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    backgroundColor: AppColors.alertDialog,
                                    title: const Text(
                                      'Thông báo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    content: const Text(
                                      'Vượt quá số lượng kho!',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  ),
                            );
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatPrice(item.giaDonVi.toDouble()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Nút xóa
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    cartController.removeFromCart(index);
                  });
                },
              ),
              Checkbox(
                value: _selectedItems[index],
                onChanged: (value) {
                  setState(() {
                    _selectedItems[index] = value ?? false;
                    // Nếu bỏ chọn bất kỳ sản phẩm nào, bỏ chọn "chọn tất cả"
                    if (!_selectedItems[index]) {
                      _selectAll = false;
                    } else if (_selectedItems.every((e) => e)) {
                      _selectAll = true;
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final selectedCartItems = [
      for (int i = 0; i < cartController.cartItems.length; i++)
        if (_selectedItems[i]) cartController.cartItems[i],
    ];
    final totalPrice = selectedCartItems.fold(
      0.0,
      (sum, item) => sum + item.tongGia,
    );

    final bool hasVoucher = false;
    final double voucherDiscount = 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatPrice(totalPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed:
                    selectedCartItems.isEmpty
                        ? null
                        : () {
                          // Kiểm tra từng sản phẩm được chọn
                          for (final item in selectedCartItems) {
                            final detail =
                                item.sanPham.details != null &&
                                        item.sanPham.details!.isNotEmpty
                                    ? (item.selectedSize != null
                                        ? item.sanPham.details!.firstWhere(
                                          (d) =>
                                              d.kichthuoc == item.selectedSize,
                                          orElse:
                                              () => item.sanPham.details!.first,
                                        )
                                        : item.sanPham.details!.first)
                                    : null;
                            final maxQty = detail?.soluongKho ?? 1;
                            if (item.soLuong > maxQty) {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      backgroundColor: AppColors.alertDialog,
                                      title: const Text(
                                        'Thông báo',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      content: Text(
                                        'Sản phẩm "${item.sanPham.tensp}" vượt quá số lượng kho!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: const Text('Đóng'),
                                        ),
                                      ],
                                    ),
                              );
                              return; // Dừng lại, không cho thanh toán
                            }
                          }
                          // Nếu hợp lệ, cho thanh toán các sản phẩm đã chọn
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CheckoutScreen(
                                    cartTotal: totalPrice,
                                    userData: widget.userData,
                                    selectedItems: selectedCartItems,
                                  ),
                            ),
                          );
                        },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
