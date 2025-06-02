import 'package:flutter/material.dart';
import 'package:luxe_silver_app/controllers/product_data.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final SanPham sanPham;

  const ProductCard({Key? key, required this.sanPham}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm (dùng height cố định)
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                sanPham.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[100],
                    child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                  );
                },
              ),
            ),
          ),
          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sanPham.tenSp,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Builder(
                  builder: (context) {
                    final chiTietList = ProductData.getChiTietByIdSp(
                      sanPham.idSp,
                    );
                    if (chiTietList.isNotEmpty) {
                      final size = chiTietList.first;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Size: ${size.kichThuoc} ${size.donVi}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'FreeSize',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  sanPham.formattedPrice,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
