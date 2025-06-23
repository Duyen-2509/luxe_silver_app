import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luxe_silver_app/repository/contact_info_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/contact_info_controller.dart';

class ContactDialog {
  static Future<void> show(
    BuildContext context,
    ContactInfoController controller,
    int id, {
    bool isAdmin = false,
  }) async {
    // Lấy số mới nhất từ API
    await controller.loadContactInfo(id);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Liên hệ'),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      Navigator.pop(context); // Đóng dialog hiện tại
                      await _showEditContactDialog(context, controller, id);
                    },
                  ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.phone, color: Colors.green),
                  title: Text('Gọi điện thoại'),
                  subtitle: Text(
                    controller.phoneNumber,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _handlePhoneCall(context, controller.phoneNumber);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.content_copy, color: Colors.blue),
                  title: Text('Sao chép số điện thoại'),
                  subtitle: Text(
                    'Nhấn để sao chép',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _copyPhoneNumber(context, controller.phoneNumber);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat, color: Colors.blue),
                  title: Text('Zalo'),
                  subtitle: Text(
                    'Mở Zalo',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _handleZaloContact(context, controller.phoneZalo);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.content_copy, color: Colors.orange),
                  title: Text('Sao chép link Zalo'),
                  subtitle: Text(
                    'Dán vào trình duyệt',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _copyZaloLink(context, controller.phoneZalo);
                  },
                ),
              ],
            ),
          ),
    );
  }

  static Future<void> _handlePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    bool launched = false;
    try {
      launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!launched) {
      try {
        launched = await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
    if (!launched) {
      try {
        if (await canLaunchUrl(phoneUri)) {
          launched = await launchUrl(phoneUri);
        }
      } catch (_) {}
    }
    if (!launched) {
      _showManualContactDialog(context, phoneNumber);
    }
  }

  static Future<void> _handleZaloContact(
    BuildContext context,
    String phoneZalo,
  ) async {
    bool launched = false;
    final Uri zaloAppUri = Uri.parse('zalo://chat?phone=$phoneZalo');
    try {
      if (await canLaunchUrl(zaloAppUri)) {
        launched = await launchUrl(
          zaloAppUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {}
    if (!launched) {
      final Uri zaloWebUri = Uri.parse('https://zalo.me/$phoneZalo');
      try {
        launched = await launchUrl(
          zaloWebUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }
    if (!launched) {
      _showZaloInstructions(context, phoneZalo);
    }
  }

  static void _copyPhoneNumber(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    _showSuccessSnackBar(context, 'Đã sao chép số điện thoại: $phoneNumber');
  }

  static void _copyZaloLink(BuildContext context, String phoneZalo) {
    final zaloLink = 'https://zalo.me/$phoneZalo';
    Clipboard.setData(ClipboardData(text: zaloLink));
    _showSuccessSnackBar(
      context,
      'Đã sao chép link Zalo. Hãy dán vào trình duyệt để mở.',
    );
  }

  static void _showManualContactDialog(
    BuildContext context,
    String phoneNumber,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Liên hệ thủ công'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do hạn chế bảo mật của thiết bị, vui lòng liên hệ thủ công:',
                ),
                SizedBox(height: 16),
                SelectableText(
                  'Số điện thoại: $phoneNumber',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '(Số đã được sao chép tự động)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _copyPhoneNumber(context, phoneNumber);
                },
                child: Text('Sao chép lại'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Đóng'),
              ),
            ],
          ),
    );
    _copyPhoneNumber(context, phoneNumber);
  }

  static void _showZaloInstructions(BuildContext context, String phoneZalo) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hướng dẫn kết nối Zalo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Link Zalo đã được sao chép. Để kết nối:'),
                SizedBox(height: 12),
                Text('1. Mở trình duyệt (Chrome, Firefox...)'),
                Text('2. Dán link vào thanh địa chỉ'),
                Text('3. Nhấn Enter để mở Zalo'),
                SizedBox(height: 12),
                SelectableText(
                  'https://zalo.me/$phoneZalo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _copyZaloLink(context, phoneZalo);
                },
                child: Text('Sao chép link'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Đóng'),
              ),
            ],
          ),
    );
    _copyZaloLink(context, phoneZalo);
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> _showEditContactDialog(
    BuildContext context,
    ContactInfoController controller,
    int id,
  ) async {
    final phoneController = TextEditingController(text: controller.phoneNumber);
    final zaloController = TextEditingController(text: controller.phoneZalo);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sửa thông tin liên hệ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: zaloController,
                  decoration: const InputDecoration(labelText: 'Zalo'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final phone = phoneController.text.trim();
                  final zalo = zaloController.text.trim();
                  final success = await controller.updateContactInfo(
                    id,
                    phone,
                    zalo,
                  );
                  Navigator.pop(context);
                  if (success) {
                    _showSuccessSnackBar(context, 'Cập nhật thành công!');
                    // Reload lại dialog liên hệ
                    await controller.loadContactInfo(id);
                    show(context, controller, id, isAdmin: true);
                  } else {
                    _showSuccessSnackBar(context, 'Cập nhật thất bại!');
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }
}
