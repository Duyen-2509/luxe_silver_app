import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import '../controllers/thongke_controller.dart';

class ThongKeScreen extends StatefulWidget {
  const ThongKeScreen({super.key});

  @override
  State<ThongKeScreen> createState() => _ThongKeScreenState();
}

enum KieuThongKe { ngay, thang, nam }

class _ThongKeScreenState extends State<ThongKeScreen> {
  KieuThongKe kieuThongKe = KieuThongKe.ngay;

  DateTime selectedDate = DateTime.now();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int selectedYearOnly = DateTime.now().year;

  Map<String, dynamic>? thongKeData;
  bool isLoading = false;
  String? error;

  final ThongKeController thongKeController = ThongKeController();

  @override
  void initState() {
    super.initState();
    _fetchThongKe();
  }

  void _fetchThongKe() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      String kieu;
      String? ngay;
      int? thang, nam;

      switch (kieuThongKe) {
        case KieuThongKe.ngay:
          kieu = 'ngay';
          ngay = DateFormat('yyyy-MM-dd').format(selectedDate);
          break;
        case KieuThongKe.thang:
          kieu = 'thang';
          thang = selectedMonth;
          nam = selectedYear;
          break;
        case KieuThongKe.nam:
          kieu = 'nam';
          nam = selectedYearOnly;
          break;
      }

      final data = await thongKeController.fetchThongKe(
        kieu: kieu,
        ngay: ngay,
        thang: thang,
        nam: nam,
      );
      setState(() {
        thongKeData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  bool get isSmallScreen => MediaQuery.of(context).size.width < 600;
  bool get isMediumScreen =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
  bool get isLargeScreen => MediaQuery.of(context).size.width >= 1200;

  double get horizontalPadding {
    if (isSmallScreen) return 12.0;
    if (isMediumScreen) return 20.0;
    return 32.0;
  }

  double get verticalSpacing {
    if (isSmallScreen) return 8.0;
    if (isMediumScreen) return 12.0;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    String filterText = '';
    switch (kieuThongKe) {
      case KieuThongKe.ngay:
        filterText = 'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}';
        break;
      case KieuThongKe.thang:
        filterText = 'Tháng: $selectedMonth/$selectedYear';
        break;
      case KieuThongKe.nam:
        filterText = 'Năm: $selectedYearOnly';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          'Thống kê',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
        leading: const BackButton(),
        elevation: isSmallScreen ? 1 : 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Chọn kiểu thống kê
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<KieuThongKe>(
                    value: kieuThongKe,
                    decoration: const InputDecoration(
                      labelText: 'Kiểu thống kê',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: KieuThongKe.ngay,
                        child: Text('Theo ngày'),
                      ),
                      DropdownMenuItem(
                        value: KieuThongKe.thang,
                        child: Text('Theo tháng'),
                      ),
                      DropdownMenuItem(
                        value: KieuThongKe.nam,
                        child: Text('Theo năm'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          kieuThongKe = value;
                        });
                        _fetchThongKe();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chọn giá trị theo kiểu thống kê
            if (kieuThongKe == KieuThongKe.ngay)
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365 * 5),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                    _fetchThongKe();
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
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),

            if (kieuThongKe == KieuThongKe.thang)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Tháng',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Tháng ${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMonth = value;
                          });
                          _fetchThongKe();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Năm',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: List.generate(
                        6,
                        (index) => DropdownMenuItem(
                          value: DateTime.now().year - 3 + index,
                          child: Text('${DateTime.now().year - 3 + index}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                          });
                          _fetchThongKe();
                        }
                      },
                    ),
                  ),
                ],
              ),
            if (kieuThongKe == KieuThongKe.nam)
              DropdownButtonFormField<int>(
                value: selectedYearOnly,
                decoration: const InputDecoration(
                  labelText: 'Năm',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: List.generate(
                  6,
                  (index) => DropdownMenuItem(
                    value: DateTime.now().year - 3 + index,
                    child: Text('${DateTime.now().year - 3 + index}'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedYearOnly = value;
                    });
                    _fetchThongKe();
                  }
                },
              ),
            const SizedBox(height: 12),

            // Hiển thị thông tin lọc
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                filterText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Center(
                child: Text(
                  'Lỗi: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (!isLoading && error == null)
              Column(
                children: [
                  // Thống kê doanh thu từ API
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Colors.green,
                              size: isSmallScreen ? 24 : 28,
                            ),
                            SizedBox(width: verticalSpacing),
                            Text(
                              'Doanh thu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(height: verticalSpacing),
                            Text(
                              thongKeData != null
                                  ? NumberFormat("#,###").format(
                                    int.tryParse(
                                          thongKeData!['doanhthu'].toString(),
                                        ) ??
                                        0,
                                  )
                                  : '0',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 24 : 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              ' VNĐ',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Thống kê trạng thái đơn hàng từ API
                  if (thongKeData != null)
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 7,
                      childAspectRatio: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatusCard(
                          'Chờ xử lý',
                          thongKeData!['counts']?['cho_xu_ly'] ?? 0,
                          Icons.access_time,
                          Colors.orange,
                        ),
                        _buildStatusCard(
                          'Đang xử lý',
                          thongKeData!['counts']?['dang_xu_ly'] ?? 0,
                          Icons.sync,
                          Colors.blue,
                        ),
                        _buildStatusCard(
                          'Đang giao',
                          thongKeData!['counts']?['dang_giao'] ?? 0,
                          Icons.local_shipping,
                          Colors.purple,
                        ),
                        _buildStatusCard(
                          'Đã giao',
                          thongKeData!['counts']?['da_giao'] ?? 0,
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                        _buildStatusCard(
                          'Đã huỷ',
                          thongKeData!['counts']?['da_huy'] ?? 0,
                          Icons.redo,
                          Colors.red,
                        ),
                        _buildStatusCard(
                          'Trả hàng',
                          thongKeData!['counts']?['tra_hang'] ?? 0,
                          Icons.reply,
                          Colors.teal,
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatusCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Giữ nền trắng như cũ
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat("#,###").format(count),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
