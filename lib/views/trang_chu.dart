import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/contact_info_controller.dart';
import 'package:luxe_silver_app/repository/contact_info_repository.dart';
import 'package:luxe_silver_app/views/them_san_pham.dart';
import 'package:luxe_silver_app/views/gio_hang.dart';
import 'package:luxe_silver_app/views/khung_san_pham.dart';
import 'package:luxe_silver_app/views/chi_tiet_sp.dart';
import 'package:luxe_silver_app/views/loc_san_pham.dart';
import 'package:luxe_silver_app/views/tai_khoan.dart';
import 'package:luxe_silver_app/views/voucher_screen.dart';
import '../models/sanPham_model.dart';
import '../repository/produt_data_repository.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:luxe_silver_app/views/ql_don_hang.dart';
import 'package:luxe_silver_app/views/ql_nhan_vien.dart';
import 'package:luxe_silver_app/views/don_hang.dart';
import 'package:luxe_silver_app/views/gio_hang.dart';
import 'package:luxe_silver_app/views/thong_ke.dart';
import 'package:luxe_silver_app/views/dat_rieng.dart' as datrieng;

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Thay đổi: dùng getter để luôn lấy dữ liệu mới
  Future<List<SanPham>> get _futureProducts =>
      ProductDataRepository(ApiService()).fetchProducts();
  int _selectedIndex = 0;
  late List<SanPham> _allProducts = [];
  final controller = ContactInfoController();

  void _onItemTapped(int index) {
    final role = widget.userData['role'];
    if (role == 'admin') {
      if (index == 0) {
        // Trang chủ
        if (Navigator.of(context).canPop()) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
        setState(() {
          _selectedIndex = index;
        });
      } else if (index == 1) {
        // QL đơn hàng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QLDonHangScreen(userData: widget.userData),
          ),
        );
      } else if (index == 2) {
        // QL nhân viên
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QLNhanVienScreen(userData: widget.userData),
          ),
        );
      } else if (index == 3) {
        // Tài khoản
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userData: widget.userData),
          ),
        );
      }
    } else if (role == 'nhan_vien') {
      if (index == 0) {
        // Trang chủ
        if (Navigator.of(context).canPop()) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
        setState(() {
          _selectedIndex = index;
        });
      } else if (index == 1) {
        // QL đơn hàng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QLDonHangScreen(userData: widget.userData),
          ),
        );
      } else if (index == 2) {
        // Tài khoản
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userData: widget.userData),
          ),
        );
      }
    } else {
      // Khách hàng
      if (index == 0) {
        // Trang chủ
        if (Navigator.of(context).canPop()) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
        setState(() {
          _selectedIndex = index;
        });
      } else if (index == 1) {
        // Giỏ hàng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartScreen(userData: widget.userData),
          ),
        );
      } else if (index == 2) {
        // Đơn hàng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonHangScreen(userData: widget.userData),
          ),
        );
      } else if (index == 3) {
        // Tài khoản
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userData: widget.userData),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cartTotal = 0.0;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 40),
            ExpansionTile(
              title: const Text('Trang sức nữ', style: TextStyle(fontSize: 18)),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
              children: [
                _buildSubMenuItem('Dây chuyền', loai: 1, gioiTinh: 'Nữ'),
                _buildSubMenuItem('Nhẫn', loai: 1, gioiTinh: 'Nữ'),
                _buildSubMenuItem('Lắc tay', loai: 1, gioiTinh: 'Nữ'),
                _buildSubMenuItem('Bông tai', loai: 1, gioiTinh: 'Nữ'),
                _buildSubMenuItem('Lắc chân', loai: 1, gioiTinh: 'Nữ'),
                _buildSubMenuItem('Mặt dây', loai: 1, gioiTinh: 'Nữ'),
              ],
            ),
            const Divider(height: 1),
            ExpansionTile(
              title: const Text(
                'Trang sức nam',
                style: TextStyle(fontSize: 18),
              ),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
              children: [
                _buildSubMenuItem('Dây chuyền', loai: 1, gioiTinh: 'Nam'),
                _buildSubMenuItem('Nhẫn', loai: 1, gioiTinh: 'Nam'),
                _buildSubMenuItem('Lắc tay', loai: 1, gioiTinh: 'Nam'),
                _buildSubMenuItem('Bông tai', loai: 1, gioiTinh: 'Nam'),
                _buildSubMenuItem('Mặt dây', loai: 1, gioiTinh: 'Nam'),
              ],
            ),
            const Divider(height: 1),
            ExpansionTile(
              title: const Text(
                'Trang sức đôi',
                style: TextStyle(fontSize: 18),
              ),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
              children: [
                _buildSubMenuItem('Nhẫn đôi', loai: 2, gioiTinh: 'Unisex'),
                _buildSubMenuItem(
                  'Dây chuyền đôi',
                  loai: 2,
                  gioiTinh: 'Unisex',
                ),
                _buildSubMenuItem('Vòng tay đôi', loai: 2, gioiTinh: 'Unisex'),
              ],
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Bộ sưu tập', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductFilterScreen(
                          products: _allProducts,
                          loai: 3,
                          gioiTinh: 'Unisex',
                          nhom: 'Bộ',
                          userData: widget.userData,
                        ),
                  ),
                );
              },
            ),
            const Divider(height: 1),

            _buildMenuItem(
              'Đặt riêng - Liên hệ',
              onTap:
                  () => datrieng.ContactDialog.show(
                    context,
                    controller,
                    1,
                    isAdmin: widget.userData['role'] == 'admin',
                  ),
            ),
            const Divider(height: 1),
            if (widget.userData['role'] == 'admin')
              ListTile(
                title: const Text(
                  'Sản phẩm ẩn',
                  style: TextStyle(fontSize: 18),
                ),

                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductFilterScreen(
                            products:
                                _allProducts
                                    .where(
                                      (sp) =>
                                          (sp.trangthai == 0) ||
                                          (sp.soluongKho == 0),
                                    )
                                    .toList(),
                            loai: 0, // hoặc truyền 0 để không lọc theo loại
                            gioiTinh: '',
                            nhom: 'Sản phẩm ẩn',
                            userData: widget.userData,
                          ),
                    ),
                  );
                },
              ),
            const Divider(height: 1),
            if (widget.userData['role'] == 'admin') ...[
              _buildMenuItem(
                'Voucher',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VoucherScreen(
                            cartTotal: cartTotal,
                            userData: widget.userData, // Truyền userData vào
                          ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _buildMenuItem(
                'Thống kê',
                onTap: () {
                  Navigator.pop(context); // Đóng Drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThongKeScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
            ],
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<SanPham>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }
            final products = snapshot.data ?? [];
            _allProducts = products;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final sanPham = products[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductDetailScreen(
                              userData: widget.userData,
                              productId: sanPham.idSp,
                            ),
                      ),
                    );
                    setState(() {}); // reload khi quay về
                  },
                  child: ProductCard(sanPham: sanPham),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton:
          widget.userData['role'] == 'admin'
              ? FloatingActionButton(
                onPressed: () async {
                  // Chờ khi AddProductScreen đóng lại
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen()),
                  );
                  // Khi quay lại, gọi setState để rebuild và lấy dữ liệu mới
                  setState(() {});
                },
                backgroundColor: AppColors.background,
                child: const Icon(Icons.add, size: 32),
              )
              : null,
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
          items:
              widget.userData['role'] == 'admin'
                  ? [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Trang chủ',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.assignment),
                      label: 'QL đơn hàng',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.group),
                      label: 'QL nhân viên',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      label: 'Tài khoản',
                    ),
                  ]
                  : widget.userData['role'] == 'nhan_vien'
                  ? [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Trang chủ',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.assignment),
                      label: 'QL đơn hàng',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      label: 'Tài khoản',
                    ),
                  ]
                  : [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Trang chủ',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart_outlined),
                      label: 'Giỏ hàng',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long_outlined),
                      label: 'Đơn hàng',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      label: 'Tài khoản',
                    ),
                  ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: onTap,
    );
  }

  Widget _buildSubMenuItem(
    String title, {
    required int loai,
    required String gioiTinh,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductFilterScreen(
                  products: _allProducts,
                  loai: loai,
                  gioiTinh: gioiTinh,
                  nhom: title,
                  userData: widget.userData,
                ),
          ),
        );
      },
    );
  }
}
