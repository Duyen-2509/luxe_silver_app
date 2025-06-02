import '../models/product_model.dart';

class ProductData {
  // Dữ liệu thô cho loại sản phẩm
  static List<LoaiSanPham> loaiSanPhamList = [
    LoaiSanPham(idLoai: 1, tenLoai: 'Dây chuyền'),
    LoaiSanPham(idLoai: 2, tenLoai: 'Nhẫn'),
    LoaiSanPham(idLoai: 3, tenLoai: 'Bông tai'),
    LoaiSanPham(idLoai: 4, tenLoai: 'Lắc tay'),
    LoaiSanPham(idLoai: 5, tenLoai: 'Đồng hồ'),
  ];

  // Dữ liệu thô cho size
  static List<Size> sizeList = [
    Size(idSize: 1, kichThuoc: '3.1', donVi: 'cm'),
    Size(idSize: 2, kichThuoc: '5', donVi: 'cm'),
    Size(idSize: 3, kichThuoc: '7', donVi: 'cm'),
    Size(idSize: 4, kichThuoc: '9', donVi: 'cm'),
  ];

  // Dữ liệu thô cho sản phẩm
  static List<SanPham> sanPhamList = [
    SanPham(
      idSp: 1,
      idLoai: 1,
      tenSp: 'Dây chuyền Nguyệt Quế Hồ Điệp Tím 2413',
      gia: '360000',
      gioiTinh: 'Nữ',
      chatLieu: 'Bạc 925',
      tenPk: 'Dây chuyền cao cấp',
      inhManh:
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&h=400&fit=crop',
      mota:
          'Dây chuyền bạc cao cấp với thiết kế hoa hồ điệp tinh tế, phù hợp cho phái nữ',
      soluong: 50,
      trangThai: true,
      tenLoai: 'Dây chuyền',
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    SanPham(
      idSp: 2,
      idLoai: 2,
      tenSp: 'Nhẫn Bạc Đính Đá Zircon Cao Cấp',
      gia: '280000',
      gioiTinh: 'Unisex',
      chatLieu: 'Bạc 925',
      tenPk: 'Nhẫn đính đá',
      inhManh:
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400&h=400&fit=crop',
      mota: 'Nhẫn bạc 925 đính đá zircon lấp lánh, thiết kế thanh lịch',
      soluong: 35,
      trangThai: true,
      tenLoai: 'Nhẫn',
      createdAt: DateTime.now().subtract(Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    SanPham(
      idSp: 3,
      idLoai: 3,
      tenSp: 'Bông tai Ngọc Trai Thiên Nhiên',
      gia: '420000',
      gioiTinh: 'Nữ',
      chatLieu: 'Ngọc trai',
      tenPk: 'Bông tai ngọc trai',
      inhManh:
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400&h=400&fit=crop',
      mota: 'Bông tai ngọc trai thiên nhiên cao cấp, tôn lên vẻ đẹp quý phái',
      soluong: 20,
      trangThai: true,
      tenLoai: 'Bông tai',
      createdAt: DateTime.now().subtract(Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    SanPham(
      idSp: 4,
      idLoai: 4,
      tenSp: 'Lắc tay Bạc Hình Trái Tim Dễ Thương',
      gia: '315000',
      gioiTinh: 'Nữ',
      chatLieu: 'Bạc 925',
      tenPk: 'Lắc tay charm',
      inhManh:
          'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=400&h=400&fit=crop',
      mota:
          'Lắc tay bạc với charm hình trái tim dễ thương, phù hợp làm quà tặng',
      soluong: 40,
      trangThai: true,
      tenLoai: 'Lắc tay',
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    SanPham(
      idSp: 5,
      idLoai: 5,
      tenSp: 'Đồng hồ Thời Trang Nữ Cao Cấp',
      gia: '890000',
      gioiTinh: 'Nữ',
      chatLieu: 'Thép không gỉ',
      tenPk: 'Đồng hồ thời trang',
      inhManh:
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400&h=400&fit=crop',
      mota: 'Đồng hồ nữ cao cấp với thiết kế sang trọng, chống nước',
      soluong: 15,
      trangThai: true,
      tenLoai: 'Đồng hồ',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    SanPham(
      idSp: 6,
      idLoai: 1,
      tenSp: 'Dây chuyền Bạc Đính Đá Pha Lê',
      gia: '450000',
      gioiTinh: 'Nữ',
      chatLieu: 'Bạc 925',
      tenPk: 'Dây chuyền pha lê',
      inhManh:
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&h=400&fit=crop',
      mota: 'Dây chuyền bạc đính đá pha lê trong suốt, lấp lánh ánh sáng',
      soluong: 25,
      trangThai: true,
      tenLoai: 'Dây chuyền',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Dữ liệu chi tiết sản phẩm theo size
  static List<ChiTietSanPham> chiTietSanPhamList = [
    ChiTietSanPham(
      idCtsp: 1,
      idSp: 1,
      idSize: 1,
      soluong: 20,
      gia: '360000',
      kichThuoc: '3.1',
      donVi: 'cm',
      createdAt: DateTime.now(),
    ),
    ChiTietSanPham(
      idCtsp: 2,
      idSp: 1,
      idSize: 2,
      soluong: 30,
      gia: '360000',
      kichThuoc: '5',
      donVi: 'cm',
      createdAt: DateTime.now(),
    ),
  ];

  // Methods để thao tác với dữ liệu

  // Lấy tất cả sản phẩm
  static List<SanPham> getAllSanPham() {
    return sanPhamList.where((sp) => sp.trangThai).toList();
  }

  // Lấy sản phẩm theo loại
  static List<SanPham> getSanPhamByLoai(int idLoai) {
    return sanPhamList
        .where((sp) => sp.idLoai == idLoai && sp.trangThai)
        .toList();
  }

  // Lấy sản phẩm theo ID
  static SanPham? getSanPhamById(int idSp) {
    try {
      return sanPhamList.firstWhere((sp) => sp.idSp == idSp);
    } catch (e) {
      return null;
    }
  }

  // Tìm kiếm sản phẩm
  static List<SanPham> searchSanPham(String query) {
    if (query.isEmpty) return getAllSanPham();

    String lowerQuery = query.toLowerCase();
    return sanPhamList
        .where(
          (sp) =>
              sp.trangThai &&
              (sp.tenSp.toLowerCase().contains(lowerQuery) ||
                  sp.mota.toLowerCase().contains(lowerQuery) ||
                  sp.chatLieu.toLowerCase().contains(lowerQuery) ||
                  sp.gioiTinh.toLowerCase().contains(lowerQuery) ||
                  (sp.tenLoai?.toLowerCase().contains(lowerQuery) ?? false)),
        )
        .toList();
  }

  // Lấy danh sách loại sản phẩm
  static List<LoaiSanPham> getAllLoaiSanPham() {
    return loaiSanPhamList;
  }

  // Lấy tên loại theo ID
  static String getTenLoaiById(int idLoai) {
    try {
      return loaiSanPhamList
          .firstWhere((loai) => loai.idLoai == idLoai)
          .tenLoai;
    } catch (e) {
      return 'Không xác định';
    }
  }

  // Lấy chi tiết sản phẩm theo ID sản phẩm
  static List<ChiTietSanPham> getChiTietByIdSp(int idSp) {
    return chiTietSanPhamList.where((ct) => ct.idSp == idSp).toList();
  }

  // Lấy danh sách size
  static List<Size> getAllSizes() {
    return sizeList;
  }

  // CRUD Operations (chuẩn bị cho API)

  // Thêm sản phẩm mới
  static void addSanPham(SanPham sanPham) {
    sanPhamList.add(sanPham);
  }

  // Cập nhật sản phẩm
  static bool updateSanPham(int idSp, SanPham updatedSanPham) {
    int index = sanPhamList.indexWhere((sp) => sp.idSp == idSp);
    if (index != -1) {
      sanPhamList[index] = updatedSanPham;
      return true;
    }
    return false;
  }

  // Xóa sản phẩm (soft delete)
  static bool deleteSanPham(int idSp) {
    int index = sanPhamList.indexWhere((sp) => sp.idSp == idSp);
    if (index != -1) {
      sanPhamList[index] = sanPhamList[index].copyWith(trangThai: false);
      return true;
    }
    return false;
  }
}
