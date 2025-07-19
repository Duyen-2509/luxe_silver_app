import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_silver_app/constant/app_styles.dart';

class VoucherCard extends StatelessWidget {
  final Map<String, dynamic> voucher;
  final void Function(Map<String, dynamic>)? onTap;
  final Widget? trailing;
  const VoucherCard({
    required this.voucher,
    this.onTap,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    final minOrder = voucher['giatri_min'] ?? 0;
    final minOrderStr = formatter.format(minOrder);
    return InkWell(
      onTap: onTap != null ? () => onTap!(voucher) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Image.asset(
                'assets/voucher.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (voucher['trangthai'] == 0 ||
                                  voucher['trangthai'] == '0')
                                const Icon(
                                  Icons.lock,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              if (voucher['trangthai'] == 0 ||
                                  voucher['trangthai'] == '0')
                                const SizedBox(width: 4),
                              Text(
                                '${voucher['ten'] ?? ''}',
                                style: TextStyle(
                                  fontSize: AppStyles.voucherTitle.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          Text(
                            'Đơn tối thiểu $minOrderStr VND',
                            style: TextStyle(
                              fontSize: AppStyles.voucherContent.fontSize,
                              color: Colors.grey[600],
                            ),
                          ),

                          Text(
                            'Còn: ${voucher['soluong'] ?? ''}',
                            style: TextStyle(
                              fontSize: AppStyles.voucherContent.fontSize,
                              color: Colors.grey[600],
                            ),
                          ),

                          Text(
                            'Hạn sử dụng:',
                            style: TextStyle(
                              fontSize: AppStyles.voucherContent.fontSize,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            '${voucher['ngaybatdau'] ?? ''} - ${voucher['ngayketthuc'] ?? ''}',
                            style: TextStyle(
                              fontSize: AppStyles.voucherContent.fontSize,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
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
