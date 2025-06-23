import 'package:flutter/material.dart';

class ThongKeScreen extends StatefulWidget {
  const ThongKeScreen({super.key});

  @override
  State<ThongKeScreen> createState() => _ThongKeScreenState();
}

class _ThongKeScreenState extends State<ThongKeScreen> {
  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    String dateRangeText =
        selectedRange == null
            ? 'Chọn khoảng thời gian'
            : '${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year} - '
                '${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 1),
                  initialDateRange:
                      selectedRange ??
                      DateTimeRange(
                        start: now.subtract(const Duration(days: 7)),
                        end: now,
                      ),
                );
                if (picked != null) {
                  setState(() {
                    selectedRange = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(dateRangeText)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Doanh thu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('0', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _buildStatusCard('Chờ xử lý', 3, Icons.access_time),
                  _buildStatusCard('Đang xử lý', 1, Icons.sync),
                  _buildStatusCard('Đang giao', 0, Icons.local_shipping),
                  _buildStatusCard('Đã giao', 0, Icons.check_circle_outline),
                  _buildStatusCard('Đã huỷ', 2, Icons.cancel_outlined),
                  _buildStatusCard('Trả hàng', 0, Icons.reply),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatusCard(String title, int count, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Số lượng: $count', style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
