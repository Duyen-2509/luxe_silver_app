import 'package:flutter/material.dart';
import '../models/sanPham_model.dart';

class ProductCard extends StatelessWidget {
  final SanPham sanPham;

  const ProductCard({Key? key, required this.sanPham}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int tongSoLuong =
        sanPham.details?.fold<int>(0, (sum, d) => sum + d.soluongKho) ?? 0;
    final bool isOutOfStock = tongSoLuong == 0;

    final double cardWidth = MediaQuery.of(context).size.width / 2 - 10;
    final double imageHeight = cardWidth * 0.75;

    return Opacity(
      opacity: isOutOfStock ? 0.3 : 1.0,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hình ảnh
            Container(
              height: imageHeight,
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
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        )
                        : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),

            // Thông tin sản phẩm
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sanPham.tensp,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (!isOutOfStock)
                    Text(
                      sanPham.gia != null
                          ? '${sanPham.gia!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ'
                          : 'Liên hệ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Text(
                      'Hết hàng',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
