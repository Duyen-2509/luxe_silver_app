import 'package:flutter/material.dart';
import '../models/sanPham_model.dart';
import 'khung_san_pham.dart';
import 'chi_tiet_sp.dart';

class ProductFilterScreen extends StatefulWidget {
  final List<SanPham> products;
  final int loai; // 1: lẻ, 2: đôi, 3: bộ
  final String gioiTinh; // 'nam', 'nu', 'unisex'
  final String nhom; // ví dụ: 'Dây chuyền', 'Nhẫn', ...
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

class _ProductFilterScreenState extends State<ProductFilterScreen> {
  @override
  Widget build(BuildContext context) {
    final nhomLower = widget.nhom.toLowerCase();

    // Nếu là "Sản phẩm ẩn" thì không lọc lại, dùng luôn danh sách truyền vào
    final filtered =
        (nhomLower == 'sản phẩm ẩn')
            ? widget.products
            : widget.products.where((sp) {
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
                      : sp.gioitinh.toLowerCase() ==
                          widget.gioiTinh.toLowerCase();
              return matchLoai && matchNhom && matchGioiTinh;
            }).toList();
    for (final sp in widget.products) {
      print(
        'idLoai: ${sp.idLoai}, gioitinh: ${sp.gioitinh}, tenpk: ${sp.tenpk}, tenloai: ${sp.tenloai}',
      );
    }
    print(
      'Lọc với loai=${widget.loai}, gioiTinh=${widget.gioiTinh}, nhom=${widget.nhom}',
    );
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
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final sp = filtered[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductDetailScreen(
                                productId: sp.idSp,
                                userData: widget.userData,
                              ),
                        ),
                      );
                    },
                    child: ProductCard(sanPham: sp),
                  );
                },
              ),
    );
  }
}
