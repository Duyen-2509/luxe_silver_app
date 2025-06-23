import 'package:flutter/material.dart';

class NhanVienCard extends StatelessWidget {
  final String ten;
  final String sdt;
  //final String email;
  final String diaChi;
  final bool isActive;
  final ValueChanged<bool>? onLockChanged;

  const NhanVienCard({
    super.key,
    required this.ten,
    required this.sdt,
    // required this.email,
    required this.diaChi,
    required this.isActive,
    this.onLockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Họ & tên: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ten),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Số điện thoại: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: sdt),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Text.rich(
            //   TextSpan(
            //     children: [
            //       const TextSpan(
            //         text: 'Email: ',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //       TextSpan(text: email),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Địa chỉ: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: diaChi),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Đang hoạt động:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isActive,
                  onChanged: onLockChanged,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
