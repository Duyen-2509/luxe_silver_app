import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/views/chi_tiec_dh_nv.dart';
import '../controllers/thongbao_controller.dart';
import 'chi_tiet_don_hang.dart';
import 'chi_tiet_sp.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class ThongBaoScreen extends StatefulWidget {
  final int? idKhach;
  final int? idNhanVien;
  final bool isNhanVien;
  final Map<String, dynamic>? userData;
  const ThongBaoScreen({
    Key? key,
    this.idKhach,
    this.idNhanVien,
    this.isNhanVien = false,
    this.userData,
  }) : super(key: key);

  @override
  State<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends State<ThongBaoScreen> {
  late Future<Map<String, List<dynamic>>> _futureThongBao;
  // Lưu id_tb đã hiện notification để tránh lặp lại
  final Set<int> _notifiedIds = {};

  @override
  void initState() {
    super.initState();
    _reloadThongBao();
  }

  void _reloadThongBao() {
    setState(() {
      if (widget.isNhanVien && widget.idNhanVien != null) {
        _futureThongBao = ThongBaoController().getThongBaoNhanVien(
          widget.idNhanVien!,
        );
      } else if (widget.idKhach != null) {
        _futureThongBao = ThongBaoController().getThongBaoKhach(
          widget.idKhach!,
        );
      } else {
        _futureThongBao = Future.value({'don_hang': [], 'binh_luan': []});
      }
    });
  }

  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default_channel_id',
          'Thông báo',
          channelDescription: 'Kênh thông báo chung',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Hàm hiện notification cho các thông báo chưa đọc, không lặp lại
  void _notifyUnread(List<dynamic> donHangList, List<dynamic> binhLuanList) {
    for (var tb in [...donHangList, ...binhLuanList]) {
      final int? idTb = tb['id_tb'];
      if ((tb['da_doc'] ?? 0) == 0 &&
          idTb != null &&
          !_notifiedIds.contains(idTb)) {
        showLocalNotification(
          tb['tieu_de'] ?? 'Thông báo',
          tb['noi_dung'] ?? '',
        );
        _notifiedIds.add(idTb);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thông báo'),
          centerTitle: true,
          backgroundColor: AppColors.appBarBackground,
        ),
        body: FutureBuilder<Map<String, List<dynamic>>>(
          future: _futureThongBao,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }
            final donHangList = snapshot.data?['don_hang'] ?? [];
            final binhLuanList = snapshot.data?['binh_luan'] ?? [];

            // Hiện notification cho các thông báo chưa đọc (không lặp lại)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _notifyUnread(donHangList, binhLuanList);
            });

            return Column(
              children: [
                Container(
                  color: Colors.grey[400],
                  child: const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(text: 'Đơn hàng', icon: Icon(Icons.shopping_bag)),
                      Tab(text: 'Bình luận', icon: Icon(Icons.comment)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          _reloadThongBao();
                          await _futureThongBao;
                        },
                        child: _buildList(donHangList, Icons.notifications),
                      ),
                      RefreshIndicator(
                        onRefresh: () async {
                          _reloadThongBao();
                          await _futureThongBao;
                        },
                        child: _buildList(binhLuanList, Icons.comment),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> notifications, IconData icon) {
    if (notifications.isEmpty) {
      return const Center(child: Text('Chưa có thông báo'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final tb = notifications[index];
        final bool chuaDoc = (tb['da_doc'] ?? 0) == 0;
        return ListTile(
          leading: Icon(icon, color: Colors.orange),
          title: Text(
            tb['tieu_de'] ?? '',
            style: TextStyle(
              fontWeight: chuaDoc ? FontWeight.bold : FontWeight.normal,
              color: chuaDoc ? Colors.black : Colors.grey[800],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tb['noi_dung'] != null) Text(tb['noi_dung']),
              if (tb['created_at'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    tb['created_at'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
          isThreeLine: true,
          onTap: () async {
            // Đánh dấu đã đọc
            if (tb['id_tb'] != null) {
              await ThongBaoController().danhDauDaDoc(tb['id_tb']);
              _reloadThongBao();
            }
            // Nếu là đơn hàng
            if (icon == Icons.notifications && tb['mahd'] != null) {
              if (widget.isNhanVien) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChiTietDonHangNVScreen(
                          mahd: tb['mahd'],
                          userData: widget.userData ?? {},
                        ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChiTietDonHangScreen(
                          mahd: tb['mahd'],
                          userData: widget.userData ?? {},
                        ),
                  ),
                );
              }
            }
            // Nếu là bình luận
            else if (icon == Icons.comment) {
              int? idSp = tb['id_sp'];
              if (idSp == null && tb['noi_dung'] != null) {
                final match = RegExp(r'#(\d+)').firstMatch(tb['noi_dung']);
                if (match != null) {
                  idSp = int.tryParse(match.group(1)!);
                }
              }

              if (idSp != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ProductDetailScreen(
                          productId: idSp!,
                          userData: widget.userData ?? {},
                        ),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}
