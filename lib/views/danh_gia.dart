import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/views/chi_tiet_sp.dart';
import '../controllers/comment_controller.dart';
import '../repository/comment_repository.dart';
import '../services/api_service.dart';

class DanhGiaScreen extends StatefulWidget {
  final String mahd;
  final int idSp;
  final String tenSp;
  final Map<String, dynamic> userData;

  const DanhGiaScreen({
    super.key,
    required this.mahd,
    required this.idSp,
    required this.tenSp,
    required this.userData,
  });

  @override
  State<DanhGiaScreen> createState() => _DanhGiaScreenState();
}

class _DanhGiaScreenState extends State<DanhGiaScreen> {
  int rating = 5;
  final TextEditingController commentCtrl = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá sản phẩm'),
        backgroundColor: AppColors.appBarBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tenSp,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text('Chọn số sao:'),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Bình luận:'),
            TextField(
              controller: commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập bình luận của bạn...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          setState(() => isLoading = true);
                          final controller = CommentController(
                            CommentRepository(ApiService()),
                          );
                          final result = await controller.addComment({
                            'mahd': widget.mahd,
                            'id_kh': widget.userData['id'],
                            'id_sp': widget.idSp,
                            'sosao': rating,
                            'noidung': commentCtrl.text,
                          });
                          setState(() => isLoading = false);
                          if (result != null && result.contains('thành công')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đánh giá thành công!'),
                              ),
                            );
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProductDetailScreen(
                                      productId: widget.idSp,
                                      userData: widget.userData,
                                    ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result ?? 'Lỗi đánh giá')),
                            );
                          }
                        },
                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Gửi đánh giá'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
