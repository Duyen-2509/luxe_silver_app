import 'package:flutter/material.dart';
import 'package:luxe_silver_app/controllers/product_controller.dart';
import 'package:luxe_silver_app/repository/product_repository.dart';
import 'package:luxe_silver_app/views/gio_hang.dart';
import 'package:luxe_silver_app/views/sua_sp.dart';
import 'package:luxe_silver_app/views/thanh_toan.dart';
import '../models/sanPham_model.dart';
import '../repository/produt_data_repository.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final Map<String, dynamic> userData;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
    required this.userData,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final controller = ProductController(ProductRepository(ApiService()));
  int quantity = 1;
  late Future<SanPham> _futureProduct;
  String? selectedSize;
  int _currentImageIndex = 0;
  // Biến để kiểm soát việc hiển thị bình luận
  bool showComments = false;
  // 2 bình luận mẫu
  final List<Map<String, dynamic>> comments = [
    {
      'user': 'nguyenvana',
      'rating': 5,
      'content': 'Sản phẩm rất đẹp, chất lượng tốt, giao hàng nhanh!',
    },
    {
      'user': 'lethib',
      'rating': 4,
      'content': 'Đóng gói cẩn thận, sản phẩm như mô tả, sẽ ủng hộ tiếp.',
    },
    {
      'user': 'nguyenvana',
      'rating': 5,
      'content': 'Sản phẩm rất đẹp, chất lượng tốt, giao hàng nhanh!',
    },
    {
      'user': 'lethib',
      'rating': 4,
      'content': 'Đóng gói cẩn thận, sản phẩm như mô tả, sẽ ủng hộ tiếp.',
    },
    {
      'user': 'nguyenvana',
      'rating': 5,
      'content': 'Sản phẩm rất đẹp, chất lượng tốt, giao hàng nhanh!',
    },
    {
      'user': 'lethib',
      'rating': 4,
      'content': 'Đóng gói cẩn thận, sản phẩm như mô tả, sẽ ủng hộ tiếp.',
    },
  ];

  Widget _buildStars(int star) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < star ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _futureProduct = ProductDataRepository(
      ApiService(),
    ).fetchProductDetail(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final String? role = widget.userData['role']?.toString().toLowerCase();

    print('ROLE: $role');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết sản phẩm',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<SanPham>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final sanPham = snapshot.data;
          if (sanPham == null) {
            return const Center(child: Text('Không tìm thấy sản phẩm'));
          }
          final bool isFreesize =
              sanPham.details != null &&
              sanPham.details!.length == 1 &&
              sanPham.details!.first.kichthuoc == '0' &&
              sanPham.details!.first.donvi.trim().toLowerCase() == 'freesize';

          print('donvi: "${sanPham.details?.first.donvi}"');
          print('donvi code units: ${sanPham.details?.first.donvi.codeUnits}');
          print('donvi length: ${sanPham.details?.first.donvi.length}');
          print('isFreesize: $isFreesize');

          // Khởi tạo selectedSize nếu chưa có
          if (sanPham.details != null &&
              sanPham.details!.isNotEmpty &&
              selectedSize == null) {
            selectedSize = sanPham.details!.first.kichthuoc.toString();
          }

          SanPhamDetail? selectedDetail = sanPham.details?.firstWhere(
            (d) => d.kichthuoc.toString() == selectedSize,
            orElse: () => sanPham.details!.first,
          );

          // Kiểm tra có phải là freesize không

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hình ảnh sản phẩm
                      Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[100],
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            sanPham.images != null && sanPham.images!.isNotEmpty
                                ? PageView.builder(
                                  itemCount: sanPham.images!.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Image.network(
                                      sanPham.images![index],
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey[100],
                                          child: Icon(
                                            Icons.image,
                                            size: 100,
                                            color: Colors.grey[400],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                                : Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Colors.grey[400],
                                  ),
                                ),
                            // Chỉ số ảnh
                            if (sanPham.images != null &&
                                sanPham.images!.length > 1)
                              Positioned(
                                bottom: 12,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex + 1}/${sanPham.images!.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sanPham.tensp,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            // Thêm phần này để hiển thị số sao và xổ bình luận
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showComments = true;
                                });
                              },
                              child: Row(
                                children: [
                                  _buildStars(
                                    5,
                                  ), // ví dụ 5 sao, có thể lấy từ dữ liệu sản phẩm nếu có
                                  const SizedBox(width: 4),
                                  Text(
                                    '(3 lượt đánh giá)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (showComments)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bình luận',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...comments.map(
                                      (c) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              child: Text(
                                                c['user'][0].toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        c['user'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      _buildStars(c['rating']),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    c['content'],
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            showComments = false;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          size: 18,
                                        ),
                                        label: const Text('Quay lại'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            // Size
                            const Text(
                              'Size',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 8),
                            if (isFreesize)
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    5,
                                  ), // độ cong góc
                                ),
                                color: Colors.grey[200], // màu nền xám nhạt
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  child: Text(
                                    'Freesize',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500], // màu chữ
                                    ),
                                  ),
                                ),
                              )
                            else if (sanPham.details != null &&
                                sanPham.details!.length > 1)
                              DropdownButton<String>(
                                value: selectedSize,
                                items:
                                    sanPham.details!
                                        .map(
                                          (d) => DropdownMenuItem(
                                            value: d.kichthuoc.toString(),
                                            child: Text(
                                              d.kichthuoc == 0
                                                  ? 'Freesize'
                                                  : '${d.kichthuoc} ${d.donvi}',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedSize = value;
                                  });
                                },
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'Kho: ${sanPham.soluongKho}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đã bán: ${sanPham.details != null && sanPham.details!.isNotEmpty ? sanPham.details!.first.soluongDaban : 0}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Số lượng
                            if (role != 'admin' && role != 'nhan_vien') ...[
                              const Text(
                                'Số lượng',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (quantity > 1) {
                                              setState(() {
                                                quantity--;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            quantity.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              quantity++;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: const Icon(
                                              Icons.add,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    selectedDetail != null
                                        ? '${selectedDetail.gia.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ'
                                        : '0 đ',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            // Mô tả
                            const Text(
                              'Mô tả',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sanPham.mota ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    if (role == 'nhan_vien') {
                      // Ẩn hoàn toàn với nhân viên
                      return const SizedBox.shrink();
                    }
                    // if (role == 'admin') {
                    //   // Admin: nút Sửa và Ẩn (chưa làm gì)
                    //   return Row(
                    //     children: [
                    //       Expanded(
                    //         child: OutlinedButton(
                    //           onPressed: () {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder:
                    //                     (context) =>
                    //                         EditProductScreen(sanPham: sanPham),
                    //               ),
                    //             );
                    //           },
                    //           style: OutlinedButton.styleFrom(
                    //             side: const BorderSide(color: Colors.grey),
                    //             padding: const EdgeInsets.symmetric(
                    //               vertical: 12,
                    //             ),
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(8),
                    //             ),
                    //           ),
                    //           child: const Text(
                    //             'Sửa',
                    //             style: TextStyle(
                    //               color: Colors.black,
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(width: 12),
                    //       Expanded(
                    //         child: ElevatedButton(
                    //           onPressed: () async {
                    //             final result = await controller.hideProduct(
                    //               sanPham.idSp,
                    //             );
                    //             if (result) {
                    //               ScaffoldMessenger.of(context).showSnackBar(
                    //                 const SnackBar(
                    //                   content: Text('Đã ẩn sản phẩm'),
                    //                 ),
                    //               );
                    //               setState(() {
                    //                 sanPham.trangthai =
                    //                     0; // nếu có thuộc tính này
                    //               });
                    //             }
                    //           },
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor: Colors.black,
                    //             padding: const EdgeInsets.symmetric(
                    //               vertical: 12,
                    //             ),
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(8),
                    //             ),
                    //           ),
                    //           child: const Text(
                    //             'Ẩn',
                    //             style: TextStyle(
                    //               color: Colors.white,
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   );
                    // }
                    // // Khách hàng: hiện đầy đủ 2 nút
                    // return Row(
                    //   children: [
                    //     Expanded(
                    //       child: OutlinedButton(
                    //         onPressed: () {
                    //           _addToCart(sanPham);
                    //         },
                    //         style: OutlinedButton.styleFrom(
                    //           side: const BorderSide(color: Colors.grey),
                    //           padding: const EdgeInsets.symmetric(vertical: 12),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //         ),
                    //         child: const Text(
                    //           'Thêm giỏ hàng',
                    //           style: TextStyle(
                    //             color: Colors.black,
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     Expanded(
                    //       child: ElevatedButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder:
                    //                   (context) => CheckoutScreen(
                    //                     product: sanPham,
                    //                     quantity: quantity,
                    //                     selectedSize: selectedSize,
                    //                     cartTotal:
                    //                         ((selectedDetail?.gia ?? 0) *
                    //                                 quantity)
                    //                             .toDouble(),
                    //                     userData: widget.userData,
                    //                   ),
                    //             ),
                    //           );
                    //         },
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: Colors.black,
                    //           padding: const EdgeInsets.symmetric(vertical: 12),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //         ),
                    //         child: const Text(
                    //           'Mua ngay',
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // );
                    final bool isHidden = (sanPham.trangthai ?? 1) == 0;
                    final bool isOutOfStock = sanPham.soluongKho == 0;

                    // Nếu là admin: luôn cho sửa và ẩn, kể cả khi sản phẩm đã bị ẩn hoặc hết hàng
                    if (role == 'admin') {
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            EditProductScreen(sanPham: sanPham),
                                  ),
                                );
                                // Nếu result == true (đã lưu thành công), reload lại dữ liệu
                                if (result == true) {
                                  setState(() {
                                    _futureProduct = ProductDataRepository(
                                      ApiService(),
                                    ).fetchProductDetail(widget.productId);
                                  });
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Sửa',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await controller.hideProduct(
                                  sanPham.idSp,
                                );
                                if (result != null &&
                                    result.contains('thành công')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã ẩn sản phẩm'),
                                    ),
                                  );
                                  setState(() {
                                    sanPham.trangthai = 0;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Ẩn',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Nếu là khách hàng: ẩn nút mua khi sản phẩm đã ẩn hoặc hết hàng
                    if (isHidden || isOutOfStock) {
                      return Center(
                        child: Text(
                          isHidden ? 'SẢN PHẨM ĐÃ ẨN' : 'HẾT HÀNG',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      );
                    }

                    // Khách hàng: hiện đầy đủ 2 nút khi còn hàng và chưa bị ẩn
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _addToCart(sanPham);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Thêm giỏ hàng',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CheckoutScreen(
                                        product: sanPham,
                                        quantity: quantity,
                                        selectedSize: selectedSize,
                                        cartTotal:
                                            ((selectedDetail?.gia ?? 0) *
                                                    quantity)
                                                .toDouble(),
                                        userData: widget.userData,
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Mua ngay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addToCart(SanPham sanPham) {
    final cartController = CartController();
    cartController.addToCart(sanPham, size: selectedSize, quantity: quantity);

    // Chuyển sang trang giỏ hàng luôn
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(userData: widget.userData),
      ),
    );
  }
}
