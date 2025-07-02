import 'package:flutter/material.dart';
import 'package:luxe_silver_app/controllers/comment_controller.dart';
import 'package:luxe_silver_app/controllers/hoadon_controller.dart';
import 'package:luxe_silver_app/repository/comment_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import 'package:luxe_silver_app/views/danh_gia.dart';
import 'package:luxe_silver_app/views/sua_danhgia.dart';

/// Screen hiển thị chi tiết đơn hàng của khách hàng
/// Bao gồm thông tin đơn hàng, danh sách sản phẩm, và các chức năng đánh giá
class ChiTietDonHangScreen extends StatefulWidget {
  /// Mã hóa đơn
  final String mahd;

  /// Thông tin user đăng nhập
  final Map<String, dynamic> userData;

  const ChiTietDonHangScreen({
    super.key,
    required this.mahd,
    required this.userData,
  });

  @override
  State<ChiTietDonHangScreen> createState() => _ChiTietDonHangScreenState();
}

class _ChiTietDonHangScreenState extends State<ChiTietDonHangScreen> {
  /// Future để load chi tiết hóa đơn
  late Future<List<Map<String, dynamic>>> futureChiTiet;

  /// Thông tin tổng quan của hóa đơn
  Map<String, dynamic>? hoaDonInfo;

  /// Controller để xử lý comment
  late CommentController commentController;

  /// Controller để xử lý hóa đơn
  late HoaDonController hoaDonController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  /// Khởi tạo các controller
  void _initializeControllers() {
    commentController = CommentController(CommentRepository(ApiService()));
    hoaDonController = HoaDonController();
  }

  /// Load dữ liệu ban đầu
  void _loadData() {
    futureChiTiet = hoaDonController.fetchChiTietHoaDon(widget.mahd);
    _fetchHoaDonInfo();
  }

  /// Lấy thông tin tổng quan của hóa đơn
  Future<void> _fetchHoaDonInfo() async {
    try {
      final list = await hoaDonController.fetchHoaDonList();
      if (mounted) {
        setState(() {
          hoaDonInfo = list.firstWhere(
            (e) => e['mahd'] == widget.mahd,
            orElse: () => {},
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải thông tin đơn hàng: $e');
    }
  }

  /// Lấy bình luận của khách hàng cho sản phẩm cụ thể trong đơn hàng này
  ///
  /// [idSp] - ID sản phẩm
  /// [mahd] - Mã hóa đơn
  /// [idKh] - ID khách hàng
  ///
  /// Return: Map thông tin bình luận hoặc null nếu chưa có
  Future<Map<String, dynamic>?> fetchMyComment(
    int idSp,
    String mahd,
    int idKh,
  ) async {
    try {
      final comments = await commentController.fetchComments(idSp);

      // Tìm bình luận của khách hàng này cho đơn hàng này
      return comments.cast<Map<String, dynamic>?>().firstWhere(
        (c) => c?['id_kh'] == idKh && c?['mahd'] == mahd,
        orElse: () => null,
      );
    } catch (e) {
      print('Lỗi khi lấy bình luận: $e');
      return null;
    }
  }

  /// Format giá tiền theo định dạng Việt Nam
  ///
  /// [price] - Giá tiền cần format
  /// Return: Chuỗi giá đã format (vd: "1.000.000 vnđ")
  String formatPrice(dynamic price) {
    if (price == null) return '0 vnđ';

    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        ) +
        ' vnđ';
  }

  /// Hiển thị thông báo lỗi
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  /// Hiển thị thông báo thành công
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  /// Xử lý hủy đơn hàng
  Future<void> _handleCancelOrder() async {
    final confirm = await _showConfirmDialog(
      'Xác nhận hủy đơn',
      'Bạn có chắc chắn muốn hủy đơn hàng này?',
    );

    if (confirm == true) {
      try {
        // Hiển thị dialog nhập lý do hủy
        String? lyDo = await showDialog<String>(
          context: context,
          builder: (context) {
            String input = '';
            return AlertDialog(
              title: const Text('Lý do hủy đơn'),
              content: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Nhập lý do hủy đơn',
                ),
                onChanged: (value) => input = value,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(input),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );

        if (lyDo == null || lyDo.trim().isEmpty) {
          _showErrorSnackBar('Vui lòng nhập lý do hủy đơn');
          return;
        }

        final success = await hoaDonController.huyDon(widget.mahd, lyDo);

        if (success && mounted) {
          _showSuccessSnackBar('Đã hủy đơn hàng thành công');
          setState(() {
            hoaDonInfo?['id_ttdh'] = 5;
            hoaDonInfo?['ten_trangthai'] = 'Đã hủy';
          });
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi khi hủy đơn hàng: $e');
      }
    }
  }

  /// Xử lý trả hàng
  Future<void> _handleReturnOrder() async {
    final confirm = await _showConfirmDialog(
      'Xác nhận trả hàng',
      'Bạn có chắc chắn muốn trả lại đơn hàng này?',
    );

    if (confirm == true) {
      try {
        // Hiển thị dialog nhập lý do trả hàng
        String? lyDo = await showDialog<String>(
          context: context,
          builder: (context) {
            String input = '';
            return AlertDialog(
              title: const Text('Lý do trả hàng'),
              content: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Nhập lý do trả hàng',
                ),
                onChanged: (value) => input = value,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(input),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );

        if (lyDo == null || lyDo.trim().isEmpty) {
          _showErrorSnackBar('Vui lòng nhập lý do trả hàng');
          return;
        }

        final success = await hoaDonController.traHang(widget.mahd, lyDo);

        if (success && mounted) {
          _showSuccessSnackBar('Đã gửi yêu cầu trả hàng');
          setState(() {
            hoaDonInfo?['id_ttdh'] = 6;
            hoaDonInfo?['ten_trangthai'] = 'Trả hàng';
          });
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi khi gửi yêu cầu trả hàng: $e');
      }
    }
  }

  /// Xử lý xác nhận đã nhận hàng
  Future<void> _handleConfirmReceived() async {
    final confirm = await _showConfirmDialog(
      'Xác nhận đã nhận hàng',
      'Bạn đã nhận được hàng và hài lòng với sản phẩm?',
    );

    if (confirm == true) {
      try {
        final success = await hoaDonController.daNhanHang(widget.mahd);

        if (success && mounted) {
          _showSuccessSnackBar('Đã xác nhận nhận hàng thành công');
          setState(() {
            hoaDonInfo?['id_ttdh'] = 4;
            hoaDonInfo?['ten_trangthai'] = 'Đã nhận';
          });
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi khi xác nhận nhận hàng: $e');
      }
    }
  }

  /// Xử lý xóa đánh giá
  Future<void> _handleDeleteComment(int idBl) async {
    final confirm = await _showConfirmDialog(
      'Xác nhận xóa',
      'Bạn có chắc chắn muốn xóa đánh giá này?',
    );

    if (confirm == true) {
      try {
        final result = await commentController.deleteComment(
          idBl,
          widget.userData['id'],
        );

        if (result != null && result.contains('Đã xóa') && mounted) {
          _showSuccessSnackBar('Đã xóa đánh giá thành công');
          setState(() {}); // Refresh UI
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi khi xóa đánh giá: $e');
      }
    }
  }

  /// Hiển thị dialog xác nhận
  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
  }

  /// Điều hướng đến màn hình đánh giá
  Future<void> _navigateToReviewScreen(Map<String, dynamic> product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => DanhGiaScreen(
              mahd: hoaDonInfo?['mahd'],
              idSp: product['id_sp'],
              tenSp: product['tensp'],
              userData: widget.userData,
            ),
      ),
    );

    // Refresh lại UI sau khi quay về
    if (mounted) {
      setState(() {});
    }
  }

  /// Điều hướng đến màn hình sửa đánh giá
  Future<void> _navigateToEditReviewScreen(
    Map<String, dynamic> product,
    Map<String, dynamic> comment,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SuaDanhGiaScreen(
              idBl: comment['id_bl'],
              idSp: product['id_sp'],
              tenSp: product['tensp'],
              userData: widget.userData,
              sosao: comment['sosao'],
              noidung: comment['noidung'],
            ),
      ),
    );

    // Refresh lại UI sau khi quay về
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureChiTiet,
        builder: (context, snapshot) {
          // Hiển thị loading khi đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting ||
              hoaDonInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hiển thị lỗi nếu có
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadData();
                      });
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final chitiet = snapshot.data ?? [];

          // Hiển thị thông báo nếu không có dữ liệu
          if (chitiet.isEmpty) {
            return const Center(
              child: Text(
                'Không có chi tiết đơn hàng',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Hiển thị nội dung chính
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadData();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Widget hiển thị thông tin đơn hàng
                  _buildOrderInfoCard(),

                  const SizedBox(height: 20),

                  // Widget hiển thị danh sách sản phẩm
                  _buildProductList(chitiet),

                  const SizedBox(height: 20),

                  // Widget hiển thị chi tiết thanh toán
                  _buildPaymentSummary(),

                  const SizedBox(height: 20),

                  // Widget hiển thị các nút action theo trạng thái
                  _buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget hiển thị thông tin tổng quan đơn hàng
  Widget _buildOrderInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã đơn hàng
          Row(
            children: [
              const Icon(Icons.receipt_long, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Mã đơn: ${hoaDonInfo?['mahd'] ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Trạng thái đơn hàng
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Trạng thái: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(hoaDonInfo?['id_ttdh']),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  hoaDonInfo?['ten_trangthai'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Địa chỉ nhận hàng
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Địa chỉ nhận hàng:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hoaDonInfo?['diachi'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Phương thức thanh toán
          Row(
            children: [
              const Icon(Icons.payment, size: 20, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'Thanh toán: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                hoaDonInfo?['phuongthuc_thanhtoan'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lấy màu theo trạng thái đơn hàng
  Color _getStatusColor(int? statusId) {
    switch (statusId) {
      case 1: // Chờ xác nhận
        return Colors.orange;
      case 2: // Đang xử lý
        return Colors.blue;
      case 3: // Đang giao
        return Colors.indigo;
      case 4: // Đã nhận
        return Colors.green;
      case 5: // Đã hủy
        return Colors.red;
      case 6: // Trả hàng
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  /// Widget hiển thị danh sách sản phẩm
  Widget _buildProductList(List<Map<String, dynamic>> chitiet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm đã mua',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Hiển thị từng sản phẩm
        ...chitiet.map((product) => _buildProductCard(product)),
      ],
    );
  }

  /// Widget hiển thị từng sản phẩm
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin sản phẩm chính
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh sản phẩm
              _buildProductImage(product),

              const SizedBox(width: 12),

              // Thông tin chi tiết sản phẩm
              Expanded(child: _buildProductDetails(product)),
            ],
          ),

          // Nút đánh giá (chỉ hiển thị khi đã nhận hàng)
          if (hoaDonInfo?['id_ttdh'] == 4) ...[
            const SizedBox(height: 16),
            const Divider(),
            _buildReviewSection(product),
          ],
        ],
      ),
    );
  }

  /// Widget hiển thị hình ảnh sản phẩm
  Widget _buildProductImage(Map<String, dynamic> product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child:
          product['image_url'] != null &&
                  product['image_url'].toString().isNotEmpty
              ? Image.network(
                product['image_url'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => _buildPlaceholderImage(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
              : _buildPlaceholderImage(),
    );
  }

  /// Widget placeholder cho hình ảnh
  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, size: 32, color: Colors.grey[400]),
    );
  }

  /// Widget hiển thị chi tiết sản phẩm
  Widget _buildProductDetails(Map<String, dynamic> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên sản phẩm
        Text(
          product['tensp'] ?? 'Sản phẩm',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Size sản phẩm (nếu có)
        if (product['size'] != null) ...[
          Row(
            children: [
              Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Size: ${product['size']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        // Số lượng
        Row(
          children: [
            Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'Số lượng: ${product['soluong']}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Giá sản phẩm
        Text(
          formatPrice(product['gia']),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Widget hiển thị phần đánh giá sản phẩm
  Widget _buildReviewSection(Map<String, dynamic> product) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchMyComment(
        product['id_sp'],
        hoaDonInfo?['mahd'],
        widget.userData['id'],
      ),
      builder: (context, snapshot) {
        // Hiển thị loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final myComment = snapshot.data;

        // Chưa có đánh giá - hiển thị nút đánh giá
        if (myComment == null || myComment.isEmpty) {
          return _buildReviewButton(product);
        }

        // Đã có đánh giá - hiển thị thông tin và các nút action
        return _buildExistingReview(product, myComment);
      },
    );
  }

  /// Widget nút đánh giá (khi chưa có đánh giá)
  Widget _buildReviewButton(Map<String, dynamic> product) {
    return Row(
      children: [
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _navigateToReviewScreen(product),
          icon: const Icon(Icons.rate_review, size: 18),
          label: const Text('Đánh giá'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget hiển thị đánh giá đã có
  Widget _buildExistingReview(
    Map<String, dynamic> product,
    Map<String, dynamic> comment,
  ) {
    final soLanSua = comment['solan_sua'] ?? 0;
    final maxSoLanSua = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị đánh giá hiện tại
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Đánh giá của bạn:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const Spacer(),
                  // Hiển thị số sao
                  ...List.generate(5, (index) {
                    return Icon(
                      index < (comment['sosao'] ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ],
              ),

              if (comment['noidung'] != null &&
                  comment['noidung'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  comment['noidung'],
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),

              Text(
                'Đã sửa: $soLanSua/$maxSoLanSua lần',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Các nút action
        Row(
          children: [
            const Spacer(),

            // Nút sửa (nếu chưa vượt số lần sửa)
            if (soLanSua < maxSoLanSua) ...[
              OutlinedButton.icon(
                onPressed: () => _navigateToEditReviewScreen(product, comment),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Sửa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Nút xóa
            OutlinedButton.icon(
              onPressed: () => _handleDeleteComment(comment['id_bl']),
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Xóa'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget hiển thị chi tiết thanh toán
  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết thanh toán',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Tổng tiền hàng
          _buildSummaryRow(
            'Tổng tiền hàng',
            formatPrice(hoaDonInfo?['tong_gia_sp']),
            Icons.shopping_bag,
          ),

          // Phí vận chuyển
          _buildSummaryRow(
            'Phí vận chuyển',
            formatPrice(hoaDonInfo?['tien_ship']),
            Icons.local_shipping,
          ),

          // Voucher giảm giá
          _buildSummaryRow(
            'Voucher giảm giá',
            hoaDonInfo?['id_voucher'] != null
                ? '-${formatPrice(_calculateVoucherDiscount())}'
                : '-0 vnđ',
            Icons.discount,
            isDiscount: true,
          ),
          if ((hoaDonInfo?['diem_sudung'] ?? 0) > 0)
            _buildSummaryRow(
              'Sử dụng điểm',
              '-${formatPrice(hoaDonInfo?['diem_sudung'])}',
              Icons.star,
              isDiscount: true,
            ),
          const SizedBox(height: 12),
          const Divider(thickness: 1.5),
          const SizedBox(height: 12),

          // Tổng thanh toán
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                formatPrice(hoaDonInfo?['tonggia']),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tính toán số tiền giảm giá từ voucher
  int _calculateVoucherDiscount() {
    final tongGiaSp = hoaDonInfo?['tong_gia_sp'] ?? 0;
    final tienShip = hoaDonInfo?['tien_ship'] ?? 0;
    final tongGia = hoaDonInfo?['tonggia'] ?? 0;

    return (tongGiaSp + tienShip) - tongGia;
  }

  /// Widget hiển thị từng dòng trong bảng tổng kết thanh toán
  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDiscount ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị các nút action theo trạng thái đơn hàng
  Widget _buildActionButtons() {
    final trangThai = hoaDonInfo?['id_ttdh'];

    if (trangThai == null) return const SizedBox.shrink();

    switch (trangThai) {
      case 1: // Chờ xác nhận
      case 2: // Đang xử lý
        return _buildCancelButton();

      case 3: // Đang giao
        return _buildDeliveryButtons();

      case 4: // Đã nhận
        return _buildCompletedOrderInfo();

      case 5: // Đã hủy
        return _buildCancelledOrderInfo();

      case 6: // Trả hàng
        return _buildReturnOrderInfo();

      default:
        return const SizedBox.shrink();
    }
  }

  /// Widget nút hủy đơn hàng
  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleCancelOrder,
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Hủy đơn hàng'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Widget các nút khi đơn hàng đang được giao
  Widget _buildDeliveryButtons() {
    return Row(
      children: [
        // Nút trả hàng
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _handleReturnOrder,
            icon: const Icon(Icons.keyboard_return),
            label: const Text('Trả hàng'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Nút đã nhận hàng
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleConfirmReceived,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Đã nhận hàng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget thông tin đơn hàng đã hoàn thành
  Widget _buildCompletedOrderInfo() {
    final tongGiaSp = hoaDonInfo?['tong_gia_sp'] ?? 0;
    final diemCong = (tongGiaSp * 0.005).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đơn hàng đã hoàn thành',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cảm ơn bạn đã mua hàng! Hãy đánh giá sản phẩm để chia sẻ trải nghiệm.',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn được cộng $diemCong điểm vào tài khoản',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget thông tin đơn hàng đã hủy
  Widget _buildCancelledOrderInfo() {
    final lyDoKh = hoaDonInfo?['ly_do_kh'];
    final lyDoNv = hoaDonInfo?['ly_do_nv'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel, color: Colors.red[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đơn hàng đã bị hủy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đơn hàng này đã được hủy.',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
                if (lyDoKh != null && lyDoKh.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lý do khách từ chối: $lyDoKh',
                    style: const TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (lyDoNv != null && lyDoNv.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lý do nhân viên từ chối: $lyDoNv',
                    style: const TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnOrderInfo() {
    final lyDoKh = hoaDonInfo?['ly_do_kh'];
    final lyDoNv = hoaDonInfo?['ly_do_nv'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.keyboard_return, color: Colors.orange[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (hoaDonInfo?['id_ttdh'] == 6 && hoaDonInfo?['trangthai'] == 1)
                      ? 'Trả hàng thành công'
                      : 'Đang xử lý trả hàng',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                if (!(hoaDonInfo?['id_ttdh'] == 6 &&
                    hoaDonInfo?['trangthai'] == 1))
                  const Text(
                    'Yêu cầu trả hàng của bạn đang được xử lý.',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                if (lyDoKh != null && lyDoKh.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lý do khách trả hàng: $lyDoKh',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (lyDoNv != null && lyDoNv.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'NV: $lyDoNv',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
