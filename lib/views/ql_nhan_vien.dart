import 'package:flutter/material.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/views/sua_nhan_vien.dart';
import 'package:luxe_silver_app/views/them_nhan_vien.dart';
import 'package:luxe_silver_app/controllers/user_controller.dart';
import 'package:luxe_silver_app/repository/user_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import 'nhan_vien_card.dart';

class QLNhanVienScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const QLNhanVienScreen({super.key, required this.userData});

  @override
  State<QLNhanVienScreen> createState() => _QLNhanVienScreenState();
}

class _QLNhanVienScreenState extends State<QLNhanVienScreen> {
  late UserController userController;
  List<Map<String, dynamic>> nhanViens = [];
  List<Map<String, dynamic>> filteredNhanViens = [];
  bool isLoading = true;
  String searchText = '';
  int filterStatus = 0; // 0: Tất cả, 1: Đang hoạt động, 2: Không hoạt động

  @override
  void initState() {
    super.initState();
    userController = UserController(UserRepository(ApiService()));
    _fetchNhanViens();
  }

  Future<void> _fetchNhanViens() async {
    setState(() => isLoading = true);
    nhanViens = await userController.getAllStaff();
    _applyFilter();
    setState(() => isLoading = false);
  }

  void _applyFilter() {
    setState(() {
      filteredNhanViens =
          nhanViens.where((nv) {
            // Lọc theo trạng thái
            if (filterStatus == 1 && nv['trangthai'] != 1) return false;
            if (filterStatus == 2 && nv['trangthai'] != 0) return false;
            // Lọc theo tên
            if (searchText.isNotEmpty &&
                !(nv['ten'] ?? '').toString().toLowerCase().contains(
                  searchText.toLowerCase(),
                )) {
              return false;
            }
            return true;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: const Text('Danh sách nhân viên'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                DropdownButton<int>(
                  value: filterStatus,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Tất cả')),
                    DropdownMenuItem(value: 1, child: Text('Đang hoạt động')),
                    DropdownMenuItem(value: 2, child: Text('Không hoạt động')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      filterStatus = value;
                      _applyFilter();
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      searchText = value;
                      _applyFilter();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _fetchNhanViens,
                      child: ListView.builder(
                        itemCount: filteredNhanViens.length,
                        itemBuilder: (context, index) {
                          final nv = filteredNhanViens[index];
                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          SuaNhanVienScreen(nhanVien: nv),
                                ),
                              );
                              if (result == true) {
                                _fetchNhanViens();
                              }
                            },
                            child: NhanVienCard(
                              ten: nv['ten'] ?? '',
                              sdt: nv['sodienthoai'] ?? '',
                              //email: nv['email'] ?? '',
                              diaChi: nv['diachi'] ?? '',
                              isActive: nv['trangthai'] == 1,
                              onLockChanged: (value) async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        backgroundColor: AppColors.alertDialog,
                                        title: Text(
                                          value
                                              ? 'Mở khóa nhân viên'
                                              : 'Khóa nhân viên',
                                        ),
                                        content: Text(
                                          value
                                              ? 'Bạn có chắc muốn mở khóa cho nhân viên này?'
                                              : 'Bạn có chắc muốn khóa nhân viên này?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text('Xác nhận'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  if (value) {
                                    await userController.unhideStaff(
                                      nv['id_nv'],
                                    );
                                    nv['trangthai'] = 1;
                                  } else {
                                    await userController.hideStaff(nv['id_nv']);
                                    nv['trangthai'] = 0;
                                  }
                                  _applyFilter();
                                  setState(() {});
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.background,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThemNhanVienScreen()),
          );
          if (result == true) {
            _fetchNhanViens();
          }
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
