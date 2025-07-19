import 'sanPham_model.dart';

class CartItem {
  final SanPham sanPham;
  int soLuong;
  final String? selectedSize;

  CartItem({required this.sanPham, this.soLuong = 1, this.selectedSize});

  Map<String, dynamic> toJson() => {
    'sanPham': sanPham.toJson(),
    'soLuong': soLuong,
    'selectedSize': selectedSize,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    sanPham: SanPham.fromJson(json['sanPham']),
    soLuong: json['soLuong'] ?? 1,
    selectedSize: json['selectedSize'],
  );

  double get tongGia {
    if (sanPham.details == null || sanPham.details!.isEmpty) return 0.0;
    final detail =
        selectedSize != null
            ? sanPham.details!.firstWhere(
              (d) => d.kichthuoc == selectedSize,
              orElse: () => sanPham.details!.first,
            )
            : sanPham.details!.first;
    return detail.gia * soLuong.toDouble();
  }

  int get giaDonVi {
    if (sanPham.details == null || sanPham.details!.isEmpty) return 0;
    final detail =
        selectedSize != null
            ? sanPham.details!.firstWhere(
              (d) => d.kichthuoc == selectedSize,
              orElse: () => sanPham.details!.first,
            )
            : sanPham.details!.first;
    return detail.gia;
  }
}
