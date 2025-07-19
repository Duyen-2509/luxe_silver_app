import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/contact_info_controller.dart';
import 'package:luxe_silver_app/models/sanPham_model.dart';
import 'package:luxe_silver_app/repository/produt_data_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import 'package:luxe_silver_app/views/dat_rieng.dart' as datrieng;
import 'package:luxe_silver_app/views/khung_san_pham.dart';
import 'package:luxe_silver_app/views/tim_kiem.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({Key? key}) : super(key: key);

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = 0;
  late List<SanPham> _allProducts = [];
  List<SanPham> _filteredProducts = [];
  bool _isRefreshing = false;
  Future<List<SanPham>> get _futureProducts =>
      ProductDataRepository(ApiService()).fetchProducts();
  final controller = ContactInfoController();
  void _goToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {});
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _filteredProducts = ProductSearchHelper.searchProductsByName(
        _allProducts.where((sp) => (sp.trangthai ?? 1) == 1).toList(),
        keyword: value,
      );
    });
  }

  void _onSearchSubmitted(String value) {
    _dismissKeyboard();
    if (value.trim().isNotEmpty) {
      print('Search submitted: $value');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
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
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _dismissKeyboard();
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
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _dismissKeyboard();
                            setState(() {
                              _filteredProducts = [];
                            });
                          },
                        )
                        : null,
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
                  onPressed: _goToLogin,
                ),
              ],
            ),
          ],
        ),
        drawer: Drawer(
          child: GestureDetector(
            onTap: _dismissKeyboard,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 40),

                _buildMenuItem(
                  'Đặt riêng - Liên hệ',
                  onTap: () {
                    _dismissKeyboard();
                    datrieng.ContactDialog.show(
                      context,
                      controller,
                      1,
                      isAdmin: 'role' == 'khach_hang',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.bottomNavSelected,
          backgroundColor: Colors.white,
          displacement: 40,
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
              final visibleProducts =
                  products.where((sp) => (sp.trangthai ?? 1) == 1).toList();
              final productsToShow =
                  _searchController.text.isNotEmpty
                      ? _filteredProducts
                      : visibleProducts;
              if (productsToShow.isEmpty) {
                return const Center(child: Text('Không có sản phẩm nào'));
              }
              return GridView.builder(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 80,
                  left: 4,
                  right: 4,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: productsToShow.length,
                itemBuilder: (context, index) {
                  final sanPham = productsToShow[index];
                  return ProductCard(sanPham: sanPham);
                },
              );
            },
          ),
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
            onTap: (index) {
              if (index != 0) _goToLogin();
            },
            items: [
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
      onTap: () {},
    );
  }
}
