import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/image.dart';
import 'package:luxe_silver_app/controllers/comment_controller.dart';
import 'package:luxe_silver_app/controllers/giohang_controller.dart';
import 'package:luxe_silver_app/controllers/product_controller.dart';
import 'package:luxe_silver_app/models/giohang_model.dart';
import 'package:luxe_silver_app/repository/comment_repository.dart';
import 'package:luxe_silver_app/repository/product_repository.dart';
import 'package:luxe_silver_app/views/gio_hang.dart';
import 'package:luxe_silver_app/views/sua_sp.dart';
import 'package:luxe_silver_app/views/thanh_toan.dart';
import '../models/sanPham_model.dart';
import '../repository/produt_data_repository.dart';
import '../services/api_service.dart';
import 'package:luxe_silver_app/views/khung_bl.dart';

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
                            //hiển thị số sao và xổ bình luận
                            const SizedBox(height: 8),
                            FutureBuilder<Map<String, dynamic>>(
                              future: CommentController(
                                CommentRepository(ApiService()),
                              ).fetchStatistic(sanPham.idSp),
                              builder: (context, snapshot) {
                                final trungBinh =
                                    snapshot.data?['trung_binh'] ?? 5.0;
                                final soLuot = snapshot.data?['so_luot'] ?? 0;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => Scaffold(
                                              appBar: AppBar(
                                                title: const Text('Bình luận'),
                                              ),
                                              body: CommentSection(
                                                productId: sanPham.idSp,
                                                userData: widget.userData,
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      _buildStars((trungBinh as num).round()),
                                      const SizedBox(width: 4),
                                      Text(
                                        '($soLuot lượt đánh giá)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                              'Kho: ${selectedDetail?.soluongKho ?? 0}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đã bán: ${selectedDetail?.soluongDaban ?? 0}',
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
                                          // ...existing code...
                                          onTap: () {
                                            if (quantity <
                                                (selectedDetail?.soluongKho ??
                                                    0)) {
                                              setState(() {
                                                quantity++;
                                              });
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: const Text(
                                                        'Thông báo',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      content: const Text(
                                                        'Vượt quá số lượng kho!',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(),
                                                          child: const Text(
                                                            'Đóng',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            }
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

                    final bool isHidden = (sanPham.trangthai ?? 1) == 0;
                    final bool isOutOfStock =
                        (selectedDetail?.soluongKho ?? 0) == 0;

                    // Nếu là admin: luôn cho sửa và ẩn, kể cả khi sản phẩm đã bị ẩn hoặc hết hàng
                    // ...trong Builder của bottom buttons...
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
                                String? result;
                                if (!isHidden) {
                                  // Đang hiện, cho phép ẩn
                                  result = await controller.hideProduct(
                                    sanPham.idSp,
                                  );
                                  if (result != null &&
                                      result.contains('thành công')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã ẩn sản phẩm'),
                                      ),
                                    );
                                    // Load lại chi tiết sản phẩm để cập nhật trạng thái
                                    setState(() {
                                      _futureProduct = ProductDataRepository(
                                        ApiService(),
                                      ).fetchProductDetail(widget.productId);
                                    });
                                  }
                                } else {
                                  // Đang ẩn, cho phép hiện lại
                                  result = await controller.showProduct(
                                    sanPham.idSp,
                                  );
                                  if (result != null &&
                                      result.contains('thành công')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã hiện sản phẩm'),
                                      ),
                                    );
                                    Navigator.pop(context, true);
                                    setState(() {
                                      _futureProduct = ProductDataRepository(
                                        ApiService(),
                                      ).fetchProductDetail(widget.productId);
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    !isHidden ? Colors.black : Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                !isHidden ? 'Ẩn' : 'Hiện sản phẩm',
                                style: const TextStyle(
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
                                        selectedItems: [
                                          CartItem(
                                            sanPham: sanPham,
                                            soLuong: quantity,
                                            selectedSize: selectedSize,
                                          ),
                                        ],
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
  }

  Future<void> _replyToComment(
    BuildContext context,
    Map<String, dynamic> comment,
  ) async {
    final reply = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Trả lời bình luận'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bình luận của ${comment['ten_khach_hang'] ?? 'Khách hàng'}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '"${comment['noidung'] ?? ''}"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nội dung trả lời',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
    if (reply != null && reply.trim().isNotEmpty) {
      try {
        await CommentController(
          CommentRepository(ApiService()),
        ).replyComment(comment['id_bl'], {
          'id_nv': widget.userData['id_nv'],
          'traloi_kh': reply.trim(),
          'id_sp': comment['id_sp'],
        });
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã trả lời bình luận')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi trả lời: $e')));
        }
      }
    }
  }

  Future<void> _editReply(
    BuildContext context,
    Map<String, dynamic> comment,
  ) async {
    final newReply = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: comment['traloi_kh']);
        return AlertDialog(
          title: const Text('Sửa trả lời'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bình luận gốc:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '"${comment['noidung'] ?? ''}"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nội dung trả lời',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    if (newReply != null && newReply.trim().isNotEmpty) {
      try {
        await CommentController(
          CommentRepository(ApiService()),
        ).replyComment(comment['id_bl'], {
          'id_nv': widget.userData['id_nv'],
          'traloi_kh': newReply.trim(),
          'id_sp': comment['id_sp'],
        });
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã cập nhật trả lời')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
        }
      }
    }
  }

  Future<void> _deleteReply(
    BuildContext context,
    Map<String, dynamic> comment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa trả lời'),
            content: const Text('Bạn chắc chắn muốn xóa trả lời này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      try {
        await CommentController(
          CommentRepository(ApiService()),
        ).deleteReply(comment['id_ctbl'], widget.userData['id_nv']);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã xóa trả lời')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
        }
      }
    }
  }
}
