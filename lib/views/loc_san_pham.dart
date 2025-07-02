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
          widget.products.where((sp) => sp.trangthai == 0).toList();

      return Scaffold(
        appBar: AppBar(title: const Text('Sản phẩm ẩn')),
        body: _buildProductGrid(hiddenProducts),
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
        final int tongSoLuong =
            sp.details?.fold<int>(0, (sum, d) => sum + d.soluongKho) ?? 0;
        final bool isOutOfStock = tongSoLuong == 0;
        final role = widget.userData['role'];

        return IgnorePointer(
          ignoring: (role == 'khach_hang' && isOutOfStock),
          child: GestureDetector(
            onTap: () async {
              if (role == 'khach_hang' && isOutOfStock) return;
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
          ),
        );
      },
    );
  }
}
