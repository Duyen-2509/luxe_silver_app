import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/sanPham_model.dart';
import 'dart:async';

class ProductSearchHelper {
  /// Tìm kiếm sản phẩm chỉ theo tên
  static List<SanPham> searchProductsByName(
    List<SanPham> products, {
    String? keyword,
  }) {
    final lowerKeyword = keyword?.toLowerCase().trim() ?? '';
    if (lowerKeyword.isEmpty) return products;
    return products.where((sp) {
      return sp.tensp.toLowerCase().contains(lowerKeyword);
    }).toList();
  }
}

///hàm lắng nghe giọng nói, trả về kết quả recognizedWords
Future<String?> listenForSearchText(
  BuildContext context, {
  String localeId = 'vi_VN',
}) async {
  final speech = stt.SpeechToText();
  bool available = await speech.initialize();
  if (!available) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không thể khởi tạo nhận diện giọng nói!')),
    );
    return null;
  }
  final completer = Completer<String?>();
  bool dialogOpen = true;

  // Lắng nghe kết quả
  speech.listen(
    localeId: localeId,
    listenFor: const Duration(seconds: 5),
    onResult: (val) {
      if (!completer.isCompleted) {
        completer.complete(val.recognizedWords);
      }
      if (dialogOpen && context.mounted) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        dialogOpen = false;
      }
    },
    cancelOnError: true,
    partialResults: false,
  );

  // Hiện dialog trong lúc đang nghe
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => const AlertDialog(
          backgroundColor: AppColors.alertDialog,
          content: Row(
            children: [
              Icon(Icons.mic, color: Colors.red),
              SizedBox(width: 10),
              Text('Đang nghe...'),
            ],
          ),
        ),
  );

  // Đóng dialog sau 6s nếu chưa có kết quả
  Future.delayed(const Duration(seconds: 6), () {
    if (!completer.isCompleted) {
      completer.complete(null);
      if (dialogOpen && context.mounted) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        dialogOpen = false;
      }
    }
  });

  final result = await completer.future;
  await speech.stop();
  return result;
}
