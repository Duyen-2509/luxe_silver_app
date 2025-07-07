import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import '../controllers/comment_controller.dart';
import '../repository/comment_repository.dart';
import '../services/api_service.dart';
import '../constant/image.dart';

/// Widget hiển thị phần bình luận và đánh giá sản phẩm
///
/// Logic hoạt động:
/// 1. Khách hàng bình luận: id_nv = null, traloi_kh = null
/// 2. Nhân viên trả lời: cập nhật id_nv và traloi_kh vào record hiện tại
/// 3. Hiển thị trả lời: chỉ hiện khi id_nv != null và traloi_kh != null
/// 4. Xóa trả lời: set id_nv = null, traloi_kh = null, ten_nhan_vien = null
/// 5. Bất kỳ nhân viên nào cũng có thể xóa/sửa trả lời (không phân biệt ai đã trả lời)
class CommentSection extends StatefulWidget {
  final int productId;
  final Map<String, dynamic> userData;

  const CommentSection({
    Key? key,
    required this.productId,
    required this.userData,
  }) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final CommentController _commentController = CommentController(
    CommentRepository(ApiService()),
  );
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo comment controller
  }

  /// Xây dựng widget hiển thị sao đánh giá
  /// [star] - số sao từ 1-5
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

  /// Xây dựng widget hiển thị thời gian
  /// [dateTime] - chuỗi thời gian từ database
  Widget _buildTimeInfo(String? dateTime) {
    if (dateTime == null) return const SizedBox.shrink();

    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      String timeText;
      if (difference.inDays > 0) {
        timeText = '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        timeText = '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        timeText = '${difference.inMinutes} phút trước';
      } else {
        timeText = 'Vừa xong';
      }

      return Text(
        timeText,
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  /// Nhân viên trả lời bình luận
  /// Logic: Cập nhật id_nv, traloi_kh, ten_nhan_vien vào record hiện tại
  /// [comment] - dữ liệu bình luận cần trả lời
  Future<void> _replyToComment(
    BuildContext context,
    Map<String, dynamic> comment,
  ) async {
    final reply = await _showReplyModal(context, 'Trả lời bình luận', '');

    if (reply != null && reply.trim().isNotEmpty) {
      setState(() => _isLoading = true);

      try {
        // Gọi API trả lời bình luận
        final result = await _commentController.replyComment(comment['id_bl'], {
          'id_nv': widget.userData['id_nv'],
          'traloi_kh': reply.trim(),
          'id_sp': widget.productId, // Sử dụng productId từ widget
        });

        if (result != null) {
          // Refresh UI sau khi trả lời thành công
          setState(() {});
          _showSuccessMessage('Đã trả lời bình luận thành công');
        }
      } catch (e) {
        _showErrorMessage('Lỗi khi trả lời: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Nhân viên sửa trả lời đã có
  /// Logic: Cập nhật lại nội dung traloi_kh
  /// [comment] - dữ liệu bình luận cần sửa trả lời
  Future<void> _editReply(
    BuildContext context,
    Map<String, dynamic> comment,
  ) async {
    final currentReply = comment['traloi_kh']?.toString() ?? '';
    final newReply = await _showReplyModal(
      context,
      'Sửa trả lời',
      currentReply,
    );

    if (newReply != null &&
        newReply.trim().isNotEmpty &&
        newReply.trim() != currentReply) {
      setState(() => _isLoading = true);

      try {
        // Gọi lại API trả lời với nội dung mới (API sẽ cập nhật thay vì tạo mới)
        final result = await _commentController.replyComment(comment['id_bl'], {
          'id_nv': widget.userData['id_nv'],
          'traloi_kh': newReply.trim(),
          'id_sp': widget.productId,
        });

        if (result != null) {
          setState(() {});
          _showSuccessMessage('Đã cập nhật trả lời thành công');
        }
      } catch (e) {
        _showErrorMessage('Lỗi khi cập nhật: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Nhân viên xóa trả lời
  /// Logic: Set id_nv = null, traloi_kh = null, ten_nhan_vien = null
  /// Bất kỳ nhân viên nào cũng có thể xóa (không phân biệt ai đã trả lời)
  /// [comment] - dữ liệu bình luận cần xóa trả lời
  Future<void> _deleteReply(
    BuildContext context,
    Map<String, dynamic> comment,
  ) async {
    final confirm = await _showConfirmDialog(
      context,
      'Xóa trả lời',
      'Bạn chắc chắn muốn xóa trả lời này không?',
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        // Gọi API xóa trả lời - truyền id_ctbl và id_nv hiện tại
        final result = await _commentController.deleteReply(
          comment['id_ctbl'], // ID của chi tiết bình luận
          widget
              .userData['id_nv'], // ID nhân viên hiện tại (không nhất thiết phải là người đã trả lời)
        );

        if (result != null) {
          setState(() {});
          _showSuccessMessage('Đã xóa trả lời thành công');
        }
      } catch (e) {
        _showErrorMessage('Lỗi khi xóa: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Hiển thị dialog nhập trả lời
  /// [title] - tiêu đề dialog
  /// [initialText] - text ban đầu (dùng cho edit)
  Future<String?> _showReplyModal(
    BuildContext context,
    String title,
    String initialText,
  ) async {
    final controller = TextEditingController(text: initialText);

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung trả lời',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.pop(context, controller.text.trim()),
                      child: Text(initialText.isEmpty ? 'Gửi' : 'Lưu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hiển thị dialog xác nhận
  /// [title] - tiêu đề dialog
  /// [content] - nội dung dialog
  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.alertDialog,
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  /// Hiển thị thông báo thành công
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  /// Hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  /// Kiểm tra quyền truy cập
  /// Trả về true nếu user là nhân viên hoặc admin
  bool _isStaffUser() {
    final String? role = widget.userData['role']?.toString().toLowerCase();
    return role == 'nhan_vien' || role == 'admin';
  }

  /// Kiểm tra xem có trả lời hay không
  /// Logic: Kiểm tra id_nv != null và traloi_kh != null và không rỗng
  /// [comment] - dữ liệu bình luận cần kiểm tra
  bool _hasReply(Map<String, dynamic> comment) {
    final idNv = comment['id_nv'];
    final reply = comment['traloi_kh']?.toString().trim();

    return idNv != null && reply != null && reply.isNotEmpty;
  }

  /// Lấy tên nhân viên đã trả lời
  /// [comment] - dữ liệu bình luận
  String _getReplyStaffName(Map<String, dynamic> comment) {
    return comment['ten_nhan_vien']?.toString() ?? 'Nhân viên';
  }

  /// Lấy ID nhân viên đã trả lời
  /// [comment] - dữ liệu bình luận
  String _getReplyStaffId(Map<String, dynamic> comment) {
    return comment['id_nv']?.toString() ?? '';
  }

  /// Xây dựng widget hiển thị một bình luận
  /// [comment] - dữ liệu bình luận
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final hasReply = _hasReply(comment);
    final isStaff = _isStaffUser();
    final replyStaffName = _getReplyStaffName(comment);
    final replyStaffId = _getReplyStaffId(comment);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar khách hàng
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(AppImages.avatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin khách hàng và đánh giá
                _buildCustomerInfo(comment),
                const SizedBox(height: 6),

                // Nội dung bình luận của khách hàng
                _buildCommentContent(comment),
                const SizedBox(height: 4),

                // Thời gian bình luận
                _buildTimeInfo(comment['ct_created_at']),

                // Hiển thị trả lời của nhân viên (nếu có)
                if (hasReply) ...[
                  const SizedBox(height: 8),
                  _buildReplySection(
                    comment,
                    isStaff,
                    replyStaffName,
                    replyStaffId,
                  ),
                ],

                // Nút trả lời (chỉ hiển thị cho staff và khi chưa có trả lời)
                if (isStaff && !hasReply) ...[
                  const SizedBox(height: 8),
                  _buildReplyButton(comment),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng thông tin khách hàng và đánh giá
  /// [comment] - dữ liệu bình luận
  Widget _buildCustomerInfo(Map<String, dynamic> comment) {
    final customerName = comment['ten_khach_hang']?.toString() ?? 'Khách hàng';
    final rating =
        comment['sosao'] is int
            ? comment['sosao']
            : int.tryParse(comment['sosao'].toString()) ?? 5;

    return Row(
      children: [
        Text(
          customerName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(width: 8),
        _buildStars(rating),
        const SizedBox(width: 4),
        Text(
          '($rating/5)',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Xây dựng nội dung bình luận
  /// [comment] - dữ liệu bình luận
  Widget _buildCommentContent(Map<String, dynamic> comment) {
    final content = comment['noidung']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
    );
  }

  /// Xây dựng phần trả lời của nhân viên
  /// Logic: Chỉ hiển thị khi id_nv != null và traloi_kh != null
  /// [comment] - dữ liệu bình luận
  /// [isStaff] - có phải nhân viên không
  /// [replyStaffName] - tên nhân viên đã trả lời
  /// [replyStaffId] - ID nhân viên đã trả lời
  Widget _buildReplySection(
    Map<String, dynamic> comment,
    bool isStaff,
    String replyStaffName,
    String replyStaffId,
  ) {
    final replyContent = comment['traloi_kh']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nội dung trả lời
          Container(
            width: double.infinity,
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
                    Icon(Icons.reply, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Trả lời từ cửa hàng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  replyContent,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Thông tin nhân viên và các nút chức năng
          Row(
            children: [
              // Hiển thị thông tin nhân viên (chỉ cho staff)
              if (isStaff) ...[
                Icon(Icons.person, size: 14, color: Colors.teal[600]),
                const SizedBox(width: 4),
                Text(
                  'ID: $replyStaffId - $replyStaffName',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal[600],
                  ),
                ),
              ] else ...[
                // Hiển thị tên cửa hàng cho khách hàng
                Text(
                  'LuxeSilver',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal[600],
                  ),
                ),
              ],

              const Spacer(),

              // Các nút chức năng (chỉ cho staff)
              // Bất kỳ nhân viên nào cũng có thể sửa/xóa trả lời
              if (isStaff) ...[
                TextButton(
                  onPressed:
                      _isLoading ? null : () => _editReply(context, comment),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Sửa', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed:
                      _isLoading ? null : () => _deleteReply(context, comment),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Xóa',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Xây dựng nút trả lời
  /// [comment] - dữ liệu bình luận
  Widget _buildReplyButton(Map<String, dynamic> comment) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _isLoading ? null : () => _replyToComment(context, comment),
        icon: const Icon(Icons.reply, size: 16),
        label: const Text('Trả lời', style: TextStyle(fontSize: 13)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _commentController.fetchComments(widget.productId),
      builder: (context, snapshot) {
        // Hiển thị loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Xử lý lỗi
        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 24),
                const SizedBox(height: 8),
                Text(
                  'Lỗi khi tải bình luận: ${snapshot.error}',
                  style: TextStyle(color: Colors.red[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final comments = snapshot.data ?? [];

        // Hiển thị khi không có bình luận
        if (comments.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Chưa có đánh giá nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy là người đầu tiên đánh giá sản phẩm này!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Hiển thị danh sách bình luận
        return Container(
          margin: const EdgeInsets.only(top: 16),
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
              // Tiêu đề phần bình luận
              Row(
                children: [
                  Icon(Icons.rate_review, size: 20, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Đánh giá sản phẩm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[600],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${comments.length} đánh giá',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Danh sách bình luận
              ...comments.map((comment) => _buildCommentItem(comment)),

              // Hiển thị loading khi đang xử lý
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
