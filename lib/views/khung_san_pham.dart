import 'package:flutter/material.dart';
import '../models/sanPham_model.dart';

class ProductCard extends StatelessWidget {
  final SanPham sanPham;

  const ProductCard({Key? key, required this.sanPham}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('ID: ${sanPham.idSp}, details: ${sanPham.details}');
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
          // Hình ảnh sản phẩm
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
              child:
                  sanPham.imageUrl != null
                      ? Image.network(
                        sanPham.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 10),
          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sanPham.tensp,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                // hiển thị giới tính
                if (sanPham.gioitinh != null && sanPham.gioitinh!.isNotEmpty)
                  Text(
                    'Giới tính: ${sanPham.gioitinh}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                const SizedBox(height: 5),
                // hiển thị giá
                Text(
                  sanPham.gia != null
                      ? '${sanPham.gia!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ'
                      : 'Liên hệ',
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
