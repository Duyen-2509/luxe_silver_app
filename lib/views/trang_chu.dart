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
import 'package:luxe_silver_app/views/thong_bao.dart';
import 'package:luxe_silver_app/views/voucher_screen.dart';
import '../models/sanPham_model.dart';
import '../repository/produt_data_repository.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:luxe_silver_app/views/ql_don_hang.dart';
import 'package:luxe_silver_app/views/ql_nhan_vien.dart';
import 'package:luxe_silver_app/views/don_hang.dart';
import 'package:luxe_silver_app/views/thong_ke.dart';
import 'package:luxe_silver_app/views/dat_rieng.dart' as datrieng;
import 'package:luxe_silver_app/repository/tienship_repository.dart';
import 'package:intl/intl.dart';
import 'package:luxe_silver_app/controllers/thongbao_controller.dart';
import 'package:luxe_silver_app/views/tim_kiem.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final _thongBaoController = ThongBaoController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = 0;
  late List<SanPham> _allProducts = [];
  List<SanPham> _filteredProducts = [];
  final controller = ContactInfoController();
  bool _isRefreshing = false;
  int _soThongBaoChuaDoc = 0;
  double _shippingFee = 0;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Thay đổi: dùng getter để luôn lấy dữ liệu mới
  Future<List<SanPham>> get _futureProducts =>
      ProductDataRepository(ApiService()).fetchProducts();

  // tiền ship
  String formatCurrency(num amount) {
    return NumberFormat("#,##0", "vi_VN").format(amount);
  }

  Future<void> _fetchSoThongBaoChuaDoc() async {
    try {
      Map<String, List<dynamic>> data;
      if (widget.userData['role'] == 'nhan_vien' ||
          widget.userData['role'] == 'admin') {
        data = await _thongBaoController.getThongBaoNhanVien(
          widget.userData['id_nv'],
        );
      } else {
        data = await _thongBaoController.getThongBaoKhach(
          widget.userData['id'],
        );
      }
      int count = 0;
      for (var tb in [...?data['don_hang'], ...?data['binh_luan']]) {
        if ((tb['da_doc'] ?? 0) == 0) count++;
      }
      setState(() {
        _soThongBaoChuaDoc = count;
      });
    } catch (e) {
      setState(() {
        _soThongBaoChuaDoc = 0;
      });
    }
  }

  Future<void> _showEditShippingFeeDialog() async {
    final controller = TextEditingController(
      text: _shippingFee.toStringAsFixed(0),
    );
    final result = await showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.alertDialog,
            title: const Text('Chỉnh sửa phí vận chuyển'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nhập phí vận chuyển mới',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  if (value != null && value >= 0) {
                    Navigator.pop(context, value);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
    if (result != null && result >= 0) {
      final repo = TienShipRepository();
      final success = await repo.updateTienShip(1, result);
      if (success) {
        await _fetchShippingFee();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật phí vận chuyển thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật phí vận chuyển thất bại!')),
        );
      }
    }
  }

  // refresh data
  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // delay  để có hiệu ứng refresh
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {});
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _onMicPressed() async {
    final text = await listenForSearchText(context);
    if (text != null && text.isNotEmpty) {
      setState(() {
        _searchController.text = text;
        _onSearchChanged(text);
      });
    }
  }

  // ẩn bàn phím
  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  //  xử lý tìm kiếm
  void _onSearchChanged(String value) {
    setState(() {
      _filteredProducts = ProductSearchHelper.searchProductsByName(
        _allProducts.where((sp) => (sp.trangthai ?? 1) == 1).toList(),
        keyword: value,
      );
    });
  }

  // ử lý khi submit search
  void _onSearchSubmitted(String value) {
    _dismissKeyboard();
    if (value.trim().isNotEmpty) {
      ///////in ra coi
      print('Search submitted: $value');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Ẩn bàn phím khi chuyển tab
    _dismissKeyboard();

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

  Future<void> _fetchShippingFee() async {
    try {
      final repo = TienShipRepository();
      final list = await repo.getTienShip();
      if (list.isNotEmpty) {
        setState(() {
          _shippingFee = (list.first['gia'] as num).toDouble();
        });
      }
    } catch (e) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _fetchShippingFee();
    _fetchSoThongBaoChuaDoc();
  }

  @override
  Widget build(BuildContext context) {
    final double cartTotal = 0.0;
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _dismissKeyboard(); // Ẩn bàn phím
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic, color: Colors.grey),
                  onPressed: _onMicPressed,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
            ),
          ),
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    _dismissKeyboard();
                    if (widget.userData['role'] == 'nhan_vien' ||
                        widget.userData['role'] == 'admin') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ThongBaoScreen(
                                idNhanVien: widget.userData['id_nv'],
                                isNhanVien: true,
                                userData: widget.userData,
                              ),
                        ),
                      );
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ThongBaoScreen(
                                idKhach: widget.userData['id'],
                                isNhanVien: false,
                                userData: widget.userData,
                              ),
                        ),
                      );
                    }
                    _fetchSoThongBaoChuaDoc();
                  },
                ),
                if (_soThongBaoChuaDoc > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _soThongBaoChuaDoc > 99 ? '99+' : '$_soThongBaoChuaDoc',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: GestureDetector(
            onTap: _dismissKeyboard,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 40),
                ExpansionTile(
                  title: const Text(
                    'Trang sức nữ',
                    style: TextStyle(fontSize: 18),
                  ),
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
                    _buildSubMenuItem(
                      'Vòng tay đôi',
                      loai: 2,
                      gioiTinh: 'Unisex',
                    ),
                  ],
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Bộ sưu tập',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () async {
                    _dismissKeyboard();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductFilterScreen(
                              products:
                                  _allProducts
                                      .where(
                                        (sp) =>
                                            (sp.trangthai ?? 1) == 1 &&
                                            (sp.details?.any(
                                                  (d) => d.soluongKho > 0,
                                                ) ??
                                                false),
                                      )
                                      .toList(),
                              loai: 3,
                              gioiTinh: '',
                              nhom: 'Bộ',
                              userData: widget.userData,
                            ),
                      ),
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  'Đặt riêng - Liên hệ',
                  onTap: () {
                    _dismissKeyboard();
                    datrieng.ContactDialog.show(
                      context,
                      controller,
                      1,
                      isAdmin: widget.userData['role'] == 'admin',
                    );
                  },
                ),
                const Divider(height: 1),
                if (widget.userData['role'] == 'admin')
                  ListTile(
                    title: const Text(
                      'Sản phẩm ẩn',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () async {
                      _dismissKeyboard();
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductFilterScreen(
                                products:
                                    _allProducts, // Truyền toàn bộ sản phẩm
                                loai: 0,
                                gioiTinh: '',
                                nhom: 'Sản phẩm ẩn',
                                userData: widget.userData,
                              ),
                        ),
                      );
                      if (result == true) {
                        setState(() {});
                      }
                    },
                  ),
                const Divider(height: 1),
                if (widget.userData['role'] == 'admin') ...[
                  _buildMenuItem(
                    'Voucher',
                    onTap: () {
                      _dismissKeyboard();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => VoucherScreen(
                                cartTotal: cartTotal,
                                userData: widget.userData,
                              ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    'Tiền ship: ${formatCurrency(_shippingFee)} vnđ',
                    onTap: _showEditShippingFeeDialog,
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    'Thống kê',
                    onTap: () {
                      _dismissKeyboard();
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
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.bottomNavSelected,
          backgroundColor: Colors.white,
          displacement: 40,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
              vertical: 16,
            ),
            child: FutureBuilder<List<SanPham>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isRefreshing) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${snapshot.error}',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                final products = snapshot.data ?? [];
                _allProducts = products;
                // Lọc sản phẩm
                final visibleProducts =
                    products.where((sp) => (sp.trangthai ?? 1) == 1).toList();
                final productsToShow =
                    _searchController.text.isNotEmpty
                        ? _filteredProducts
                        : visibleProducts;
                if (visibleProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có sản phẩm nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kéo xuống để làm mới',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Tính toán số cột dựa trên kích thước màn hình
                    final screenWidth = constraints.maxWidth;
                    int crossAxisCount;
                    double childAspectRatio;
                    double crossAxisSpacing;
                    double mainAxisSpacing;

                    if (screenWidth < 350) {
                      // Màn hình rất nhỏ (iPhone SE, android nhỏ)
                      crossAxisCount = 2;
                      childAspectRatio = 0.65;
                      crossAxisSpacing = 8;
                      mainAxisSpacing = 8;
                    } else if (screenWidth < 400) {
                      // Màn hình nhỏ
                      crossAxisCount = 2;
                      childAspectRatio = 0.7;
                      crossAxisSpacing = 12;
                      mainAxisSpacing = 12;
                    } else if (screenWidth < 600) {
                      // Màn hình trung bình
                      crossAxisCount = 2;
                      childAspectRatio = 0.75;
                      crossAxisSpacing = 16;
                      mainAxisSpacing = 16;
                    } else if (screenWidth < 900) {
                      // Tablet nhỏ
                      crossAxisCount = 3;
                      childAspectRatio = 0.8;
                      crossAxisSpacing = 20;
                      mainAxisSpacing = 20;
                    } else {
                      // Tablet lớn
                      crossAxisCount = 4;
                      childAspectRatio = 0.85;
                      crossAxisSpacing = 24;
                      mainAxisSpacing = 24;
                    }

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                      ),
                      itemCount: productsToShow.length,
                      itemBuilder: (context, index) {
                        final sanPham = productsToShow[index];
                        final int tongSoLuong =
                            sanPham.details?.fold<int>(
                              0,
                              (sum, d) => sum + d.soluongKho,
                            ) ??
                            0;
                        final bool isOutOfStock = tongSoLuong == 0;
                        final role = widget.userData['role'];
                        return IgnorePointer(
                          ignoring: (role == 'khach_hang' && isOutOfStock),
                          child: GestureDetector(
                            onTap: () async {
                              if (role == 'khach_hang' && isOutOfStock) return;
                              _dismissKeyboard();
                              HapticFeedback.lightImpact();
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
                              setState(() {});
                            },
                            child: ProductCard(sanPham: sanPham),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        floatingActionButton:
            widget.userData['role'] == 'admin'
                ? FloatingActionButton(
                  onPressed: () async {
                    _dismissKeyboard();
                    // Chờ khi AddProductScreen đóng lại
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(),
                      ),
                    );
                    //  setState để rebuild và lấy dữ liệu mới
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
        _dismissKeyboard();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductFilterScreen(
                  products:
                      _allProducts
                          .where((sp) => (sp.trangthai ?? 1) == 1)
                          .toList(),
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
