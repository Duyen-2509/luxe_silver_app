import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/controllers/hoadon_controller.dart';
import 'package:luxe_silver_app/views/chi_tiec_dh_nv.dart';
import 'package:intl/intl.dart';

class QLDonHangScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const QLDonHangScreen({super.key, required this.userData});

  @override
  State<QLDonHangScreen> createState() => _QLDonHangScreenState();
}

class _QLDonHangScreenState extends State<QLDonHangScreen> {
  String selectedTab = 'Tất cả';
  DateTime? fromDate;
  DateTime? toDate;
  String selectedStatus = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  String formatCurrency(num amount) {
    return NumberFormat("#,##0", "vi_VN").format(amount);
  }

  final List<String> tabs = ['Trạng thái', 'Từ ngày', 'Đến ngày'];
  final List<String> statusList = [
    'Tất cả',
    'Chờ xác nhận',
    'Đang xử lý',
    'Đang giao',
    'Đã nhận',
    'Đã huỷ',
    'Trả hàng',
  ];

  Future<List<Map<String, dynamic>>>? futureHoaDon;

  @override
  void initState() {
    super.initState();
    futureHoaDon = HoaDonController().fetchHoaDonList();
  }

  int? _statusToId(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return 1;
      case 'Đang xử lý':
        return 2;
      case 'Đang giao':
        return 3;
      case 'Đã nhận':
        return 4;
      case 'Đã huỷ':
        return 5;
      case 'Trả hàng':
        return 6;
      default:
        return null;
    }
  }

  bool _matchDate(DateTime? date, DateTime? from, DateTime? to) {
    if (date == null) return true;
    if (from != null && date.isBefore(from)) return false;
    if (to != null && date.isAfter(to)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        backgroundColor: AppColors.appBarBackground,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.grey[200],
            child: Row(
              children: [
                for (final tab in tabs)
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (tab == 'Từ ngày') {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: fromDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              fromDate = picked;
                            });
                          }
                        } else if (tab == 'Đến ngày') {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: toDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              toDate = picked;
                            });
                          }
                        } else if (tab == 'Trạng thái') {
                          showModalBottomSheet(
                            context: context,
                            builder:
                                (context) => ListView(
                                  shrinkWrap: true,
                                  children:
                                      statusList
                                          .map(
                                            (status) => ListTile(
                                              title: Text(status),
                                              onTap: () {
                                                setState(() {
                                                  selectedStatus = status;
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          )
                                          .toList(),
                                ),
                          );
                        }
                        setState(() {
                          selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  selectedTab == tab
                                      ? Colors.black
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontWeight:
                                  selectedTab == tab
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  selectedTab == tab
                                      ? Colors.black
                                      : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Bộ lọc ngày và trạng thái
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (selectedStatus != 'Tất cả') ...[
                  const SizedBox(width: 8),
                  Text(
                    'Trạng thái: $selectedStatus',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
                if (fromDate != null)
                  Text(
                    'Từ: ${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
                    style: const TextStyle(fontSize: 13),
                  ),
                if (toDate != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Đến: ${toDate!.day}/${toDate!.month}/${toDate!.year}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Mã đơn hàng',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          // Danh sách đơn hàng từ API
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  futureHoaDon = HoaDonController().fetchHoaDonList();
                });
                // Đợi dữ liệu load xong để tránh loading mãi
                await futureHoaDon;
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: futureHoaDon,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  final hoadons = snapshot.data ?? [];

                  // Lọc theo trạng thái
                  final int? statusId = _statusToId(selectedStatus);
                  List<Map<String, dynamic>> filtered = hoadons;
                  if (statusId != null) {
                    filtered =
                        filtered
                            .where((hd) => hd['id_ttdh'] == statusId)
                            .toList();
                  }

                  // Lọc theo ngày
                  if (fromDate != null) {
                    filtered =
                        filtered.where((hd) {
                          final ngaylap =
                              hd['ngaylap'] != null
                                  ? DateTime.tryParse(hd['ngaylap'])
                                  : null;
                          if (ngaylap == null) return false;
                          // So sánh chỉ theo ngày, bỏ qua giờ
                          return ngaylap.year > fromDate!.year ||
                              (ngaylap.year == fromDate!.year &&
                                  ngaylap.month > fromDate!.month) ||
                              (ngaylap.year == fromDate!.year &&
                                  ngaylap.month == fromDate!.month &&
                                  ngaylap.day >= fromDate!.day);
                        }).toList();
                  }
                  if (toDate != null) {
                    filtered =
                        filtered.where((hd) {
                          final ngaylap =
                              hd['ngaylap'] != null
                                  ? DateTime.tryParse(hd['ngaylap'])
                                  : null;
                          if (ngaylap == null) return false;
                          // So sánh chỉ theo ngày, bỏ qua giờ
                          return ngaylap.year < toDate!.year ||
                              (ngaylap.year == toDate!.year &&
                                  ngaylap.month < toDate!.month) ||
                              (ngaylap.year == toDate!.year &&
                                  ngaylap.month == toDate!.month &&
                                  ngaylap.day <= toDate!.day);
                        }).toList();
                  }

                  // Lọc theo mã đơn hàng
                  final searchText = _searchController.text.trim();
                  if (searchText.isNotEmpty) {
                    filtered =
                        filtered
                            .where(
                              (hd) => (hd['mahd'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchText.toLowerCase()),
                            )
                            .toList();
                  }

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Không có đơn hàng nào'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final hd = filtered[index];
                      final ngaylap =
                          hd['ngaylap'] != null
                              ? DateTime.tryParse(hd['ngaylap'])
                              : null;
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChiTietDonHangNVScreen(
                                    mahd: hd['mahd'],
                                    userData: widget.userData,
                                  ),
                            ),
                          );
                          // Load lại danh sách hóa đơn
                          setState(() {
                            futureHoaDon = HoaDonController().fetchHoaDonList();
                          });
                        },
                        child: Card(
                          color: AppColors.background,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hd['id_nv'] != null &&
                                    hd['ten_nhanvien'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'Nhân viên xử lý: ${hd['id_nv']} - ${hd['ten_nhanvien']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text('Mã đơn: ${hd['mahd'] ?? ''}'),
                                Text(
                                  'Ngày: ${ngaylap != null ? '${ngaylap.day}/${ngaylap.month}/${ngaylap.year}' : ''}',
                                ),
                                Text(
                                  'Tổng: ${formatCurrency(hd['tonggia'] ?? 0)} VND',
                                ),
                                Text(
                                  'Trạng thái: ${hd['ten_trangthai'] ?? ''}',
                                ),
                                if (hd['id_ttdh'] == 5 &&
                                    (hd['ly_do_kh'] != null ||
                                        hd['ly_do_nv'] != null)) // Đã huỷ
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Lý do huỷ: ${hd['ly_do_nv'] ?? hd['ly_do_kh'] ?? ''}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                if (hd['id_ttdh'] == 6 &&
                                    hd['ly_do_kh'] != null) // Trả hàng
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Lý do trả : ${hd['ly_do_kh']}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                if (hd['id_ttdh'] == 1) // 1 = Chờ xác nhận
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          // Lấy idNv từ userData
                                          final idNvRaw =
                                              widget.userData['id_nv'];
                                          final int? idNv =
                                              idNvRaw is int
                                                  ? idNvRaw
                                                  : int.tryParse(
                                                    idNvRaw?.toString() ?? '',
                                                  );
                                          if (idNv == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Không xác định được mã nhân viên!',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          // Nhân viên hủy đơn
                                          String?
                                          lyDo = await showDialog<String>(
                                            context: context,
                                            builder: (context) {
                                              String input = '';
                                              return AlertDialog(
                                                backgroundColor:
                                                    AppColors.alertDialog,
                                                title: const Text(
                                                  'Lý do hủy đơn',
                                                ),
                                                content: TextField(
                                                  autofocus: true,
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText:
                                                            'Nhập lý do hủy đơn',
                                                      ),
                                                  onChanged:
                                                      (value) => input = value,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                    child: const Text('Hủy'),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(input),
                                                    child: const Text(
                                                      'Xác nhận',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (lyDo == null ||
                                              lyDo.trim().isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Vui lòng nhập lý do hủy đơn!',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          final ok = await HoaDonController()
                                              .huyDonNV(hd['mahd'], lyDo, idNv);
                                          if (ok) {
                                            setState(() {
                                              hd['id_ttdh'] = 5;
                                              hd['ten_trangthai'] = 'Đã hủy';
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Đã hủy đơn hàng',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.cancel_outlined,
                                          size: 18,
                                        ),
                                        label: const Text('Hủy đơn'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final idNvRaw =
                                              widget.userData['id_nv'];
                                          final int? idNv =
                                              idNvRaw is int
                                                  ? idNvRaw
                                                  : int.tryParse(
                                                    idNvRaw?.toString() ?? '',
                                                  );
                                          final tenNv = widget.userData['ten'];
                                          if (idNv == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Không xác định được mã nhân viên!',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          // Gán nhân viên xử lý cho đơn hàng
                                          final okNv = await HoaDonController()
                                              .ganNhanVien(hd['mahd'], idNv);
                                          // Gọi API cập nhật trạng thái sang Đang xử lý
                                          final okTrangThai =
                                              await HoaDonController().dangXuLy(
                                                hd['mahd'],
                                              );
                                          if (okNv && okTrangThai) {
                                            setState(() {
                                              hd['id_ttdh'] = 2;
                                              hd['ten_trangthai'] =
                                                  'Đang xử lý';
                                              hd['id_nv'] = idNv;
                                              hd['ten_nhanvien'] = tenNv;
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Đã xác nhận đơn',
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Cập nhật trạng thái thất bại!',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Xác nhận'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
