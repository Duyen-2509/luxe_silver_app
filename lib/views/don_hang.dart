import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/hoadon_controller.dart';
import 'package:luxe_silver_app/views/gio_hang.dart';
import 'package:luxe_silver_app/views/tai_khoan.dart';
import 'chi_tiet_don_hang.dart';
import 'package:intl/intl.dart';

class DonHangScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DonHangScreen({super.key, required this.userData});

  @override
  State<DonHangScreen> createState() => _DonHangScreenState();
}

class _DonHangScreenState extends State<DonHangScreen> {
  int selectedTab = 0;
  final List<String> tabs = [
    'Chờ xác nhận',
    'Đang xử lý',
    'Đang giao',
    'Đã nhận',
    'Đã huỷ',
    'Trả hàng',
  ];
  String formatCurrency(num amount) {
    return NumberFormat("#,##0", "vi_VN").format(amount);
  }

  Future<List<Map<String, dynamic>>>? futureHoaDon;
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
      // Chuyển về trang chủ
    } else if (index == 1) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(userData: widget.userData),
        ),
      );
    } else if (index == 2) {
      // Đang ở trang Đơn hàng, không làm gì cả
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
  void initState() {
    super.initState();
    futureHoaDon = HoaDonController().fetchHoaDonList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        backgroundColor: AppColors.appBarBackground,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.grey[200],
            child: Row(
              children: List.generate(tabs.length, (index) {
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTab = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                selectedTab == index
                                    ? Colors.black
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        tabs[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight:
                              selectedTab == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              selectedTab == index
                                  ? Colors.black
                                  : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Danh sách hóa đơn
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureHoaDon,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                final hoadons = snapshot.data ?? [];
                // Lọc theo tài khoản đăng nhập
                final userId = widget.userData['id'];
                final hoadonsByUser =
                    hoadons.where((hd) => hd['id_kh'] == userId).toList();
                // Lọc theo trạng thái tab
                final filtered =
                    hoadonsByUser.where((hd) {
                      switch (selectedTab) {
                        case 0:
                          return hd['id_ttdh'] == 1; // Chờ xác nhận
                        case 1:
                          return hd['id_ttdh'] == 2; // Đang xử lý
                        case 2:
                          return hd['id_ttdh'] == 3; // Đang giao
                        case 3:
                          return hd['id_ttdh'] == 4; // Đã nhận
                        case 4:
                          return hd['id_ttdh'] == 5; // Đã huỷ
                        case 5:
                          return hd['id_ttdh'] == 6; // Trả hàng
                        default:
                          return true;
                      }
                    }).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('Không có đơn hàng nào'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      futureHoaDon = HoaDonController().fetchHoaDonList();
                    });
                    await futureHoaDon;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final hd = filtered[index];
                      return Card(
                        color: AppColors.background,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/logo.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            'Đơn hàng: ${hd['mahd'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng tiền: ${formatCurrency(hd['tonggia'])} vnđ',
                              ),
                              Text('Trạng thái: ${hd['ten_trangthai'] ?? ''}'),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: () async {
                            // Chờ khi trang chi tiết đóng lại
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ChiTietDonHangScreen(
                                      mahd: hd['mahd'],
                                      userData: widget.userData,
                                    ),
                              ),
                            );
                            // Làm mới lại danh sách hóa đơn
                            setState(() {
                              futureHoaDon =
                                  HoaDonController().fetchHoaDonList();
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              },
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
}
