import 'package:flutter/material.dart';
import '../models/sanPham_model.dart';
import 'khung_san_pham.dart';
import 'chi_tiet_sp.dart';

class ProductFilterScreen extends StatefulWidget {
  final List<SanPham> products;
  final int loai;
  final String gioiTinh;
  final String nhom;
  final Map<String, dynamic> userData;

  const ProductFilterScreen({
    Key? key,
    required this.products,
    required this.loai,
    required this.gioiTinh,
    required this.nhom,
    required this.userData,
  }) : super(key: key);

  @override
  State<ProductFilterScreen> createState() => _ProductFilterScreenState();
}

class _ProductFilterScreenState extends State<ProductFilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.nhom.toLowerCase() == 'sản phẩm ẩn' ? 2 : 1,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nhomLower = widget.nhom.toLowerCase();

    // Chỉ chia tab nếu là "Sản phẩm ẩn"
    if (nhomLower == 'sản phẩm ẩn') {
      final hiddenProducts =
          widget.products
              .where((sp) => (sp.trangthai == 0) && sp.soluongKho > 0)
              .toList();
      final outOfStockProducts =
          widget.products.where((sp) => sp.soluongKho == 0).toList();

      return Scaffold(
        appBar: AppBar(
          title: const Text('Sản phẩm ẩn'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Bị ẩn'), Tab(text: 'Hết hàng')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductGrid(hiddenProducts),
            _buildProductGrid(outOfStockProducts),
          ],
        ),
      );
    }

    // Các nhóm khác giữ nguyên
    final filtered =
        widget.products.where((sp) {
          final matchLoai = sp.idLoai == widget.loai;
          final tenpkLower = sp.tenpk?.toLowerCase() ?? '';
          final tenloaiLower = sp.tenloai.toLowerCase();
          final nhomTokens = nhomLower.split(' ');
          final matchNhom = nhomTokens.any(
            (token) =>
                tenpkLower.contains(token) || tenloaiLower.contains(token),
          );
          final matchGioiTinh =
              (widget.loai == 2 || widget.loai == 3)
                  ? true
                  : sp.gioitinh.toLowerCase() == widget.gioiTinh.toLowerCase();
          return matchLoai && matchNhom && matchGioiTinh;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.nhom} ${widget.gioiTinh == "Nữ"
              ? "- Nữ"
              : widget.gioiTinh == "Nam"
              ? "- Nam"
              : " "}',
        ),
      ),
      body:
          filtered.isEmpty
              ? const Center(child: Text('Không có sản phẩm phù hợp'))
              : _buildProductGrid(filtered),
    );
  }

  Widget _buildProductGrid(List<SanPham> products) {
    if (products.isEmpty) {
      return const Center(child: Text('Không có sản phẩm phù hợp'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final sp = products[index];
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductDetailScreen(
                      productId: sp.idSp,
                      userData: widget.userData,
                    ),
              ),
            );
            if (result == true) {
              Navigator.pop(context, true);
            }
          },
          child: ProductCard(sanPham: sp),
        );
      },
    );
  }
}
