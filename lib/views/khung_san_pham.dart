import 'package:flutter/material.dart';
import '../models/sanPham_model.dart';

class ProductCard extends StatelessWidget {
  final SanPham sanPham;

  const ProductCard({Key? key, required this.sanPham}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('ID: ${sanPham.idSp}, details: ${sanPham.details}');
    // Tính tổng số lượng tồn kho
    final int tongSoLuong =
        sanPham.details?.fold<int>(0, (sum, d) => sum + d.soluongKho) ?? 0;
    final bool isOutOfStock = tongSoLuong == 0;

    // Lấy kích thước màn hình
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Tính toán kích thước responsive
    final double horizontalPadding =
        screenWidth > 600 ? 24 : 16; // Padding lớn hơn cho tablet
    final double cardSpacing =
        screenWidth > 600 ? 20 : 16; // Spacing lớn hơn cho tablet
    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - cardSpacing) / 2;

    // Tính toán chiều cao hình ảnh dựa trên tỷ lệ màn hình
    final double imageHeight =
        screenWidth < 350
            ? cardWidth *
                0.6 // Màn hình nhỏ
            : screenWidth < 400
            ? cardWidth *
                0.65 // Màn hình trung bình
            : cardWidth * 0.7; // Màn hình lớn

    // Font size responsive
    final double titleFontSize =
        screenWidth < 350
            ? 12
            : screenWidth < 400
            ? 13
            : 14;
    final double subtitleFontSize =
        screenWidth < 350
            ? 10
            : screenWidth < 400
            ? 11
            : 12;
    final double priceFontSize =
        screenWidth < 350
            ? 12
            : screenWidth < 400
            ? 13
            : 14;

    // Padding responsive
    final double cardPadding =
        screenWidth < 350
            ? 8
            : screenWidth < 400
            ? 10
            : 12;
    final double verticalSpacing =
        screenWidth < 350
            ? 3
            : screenWidth < 400
            ? 4
            : 5;

    return Opacity(
      opacity: isOutOfStock ? 0.3 : 1.0,
      child: Container(
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
          children: [
            // Hình ảnh sản phẩm - Responsive
            Expanded(
              flex: screenWidth < 350 ? 3 : 4, // Tỷ lệ hình ảnh linh hoạt
              child: Container(
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
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: Icon(
                                  Icons.image,
                                  size: screenWidth < 350 ? 30 : 40,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                          : Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.image,
                              size: screenWidth < 350 ? 30 : 40,
                              color: Colors.grey[400],
                            ),
                          ),
                ),
              ),
            ),

            // Thông tin sản phẩm - Responsive
            Expanded(
              flex: screenWidth < 350 ? 2 : 3, // Tỷ lệ thông tin linh hoạt
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tên sản phẩm
                    Expanded(
                      child: Text(
                        sanPham.tensp,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines:
                            screenWidth < 350
                                ? 1
                                : 2, // Ít dòng hơn cho màn hình nhỏ
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: verticalSpacing),
                    // Giới tính (chỉ hiển thị trên màn hình đủ lớn)
                    if ((sanPham.gioitinh != null &&
                            sanPham.gioitinh!.isNotEmpty) &&
                        screenWidth >= 350)
                      Padding(
                        padding: EdgeInsets.only(bottom: verticalSpacing),
                        child: Text(
                          'Giới tính: ${sanPham.gioitinh}',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.blueGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Giá sản phẩm
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sanPham.gia != null
                                ? '${sanPham.gia!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ'
                                : 'Liên hệ',
                            style: TextStyle(
                              fontSize: priceFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[400],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOutOfStock)
                          Text(
                            '(Hết hàng)',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: priceFontSize,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
