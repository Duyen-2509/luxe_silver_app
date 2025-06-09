import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/views/cartItem.dart';
import 'package:luxe_silver_app/views/product_card.dart';
import 'package:luxe_silver_app/views/product_detail.dart';
import 'package:luxe_silver_app/views/profileScreen.dart';
import '../controllers/product_data.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      // Chuyển sang màn hình giỏ hàng
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(userData: widget.userData),
        ),
      );
    }
    // else if (index == 2) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => OrderScreen()),
    //   );
    // }
    else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: widget.userData),
        ),
      );
    } else if (index == 0) {
      // Nếu không phải là trang đầu thì pop về trang đầu
      if (Navigator.of(context).canPop()) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      setState(() {
        _selectedIndex = index;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildSubMenuItem('Dây chuyền'),
                _buildSubMenuItem('Nhẫn'),
                _buildSubMenuItem('Lắc tay'),
                _buildSubMenuItem('Bông tai'),
                _buildSubMenuItem('Lắc chân'),
                _buildSubMenuItem('Mặt dây'),
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
                _buildSubMenuItem('Dây chuyền'),
                _buildSubMenuItem('Nhẫn'),
                _buildSubMenuItem('Lắc tay'),
                _buildSubMenuItem('Bông tai'),
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
                _buildSubMenuItem('Nhẫn đôi'),
                _buildSubMenuItem('Dây chuyền đôi'),
              ],
            ),
            const Divider(height: 1),
            _buildMenuItem('Bộ sưu tập'),
            const Divider(height: 1),
            _buildMenuItem('Đặt riêng'),
            const Divider(height: 1),
            _buildMenuItem('Voucher'),
            const Divider(height: 1),
            _buildMenuItem('Thống kê'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: ProductData.sanPhamList.length,
          itemBuilder: (context, index) {
            final sanPham = ProductData.sanPhamList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductDetailScreen(
                          userData: widget.userData,
                          productId: sanPham.idSp.toString(),
                        ),
                  ),
                );
              },
              child: ProductCard(sanPham: sanPham),
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
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
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

  Widget _buildMenuItem(String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
        // Xử lý khi bấm vào menu
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSubMenuItem(String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      onTap: () {
        // Xử lý khi bấm vào mục con
        Navigator.pop(context);
      },
    );
  }
}
