import '../models/product_model.dart';

class ProductData {
  // Dữ liệu thô cho loại sản phẩm
  static List<LoaiSanPham> loaiSanPhamList = [
    LoaiSanPham(idLoai: 1, tenLoai: 'Dây chuyền'),
    LoaiSanPham(idLoai: 2, tenLoai: 'Nhẫn'),
    LoaiSanPham(idLoai: 3, tenLoai: 'Bông tai'),
    LoaiSanPham(idLoai: 4, tenLoai: 'Lắc tay'),
    LoaiSanPham(idLoai: 5, tenLoai: 'Đồng hồ'),
    LoaiSanPham(idLoai: 6, tenLoai: 'Vòng cổ'),
    LoaiSanPham(idLoai: 7, tenLoai: 'Cặp đôi'),
    LoaiSanPham(idLoai: 8, tenLoai: 'Phụ kiện'),
  ];

  // Dữ liệu thô cho size
  static List<Size> sizeList = [
    Size(idSize: 1, kichThuoc: '3.1', donVi: 'cm'),
    Size(idSize: 2, kichThuoc: '5', donVi: 'cm'),
    Size(idSize: 3, kichThuoc: '7', donVi: 'cm'),
    Size(idSize: 4, kichThuoc: '9', donVi: 'cm'),
    Size(idSize: 5, kichThuoc: '15', donVi: 'cm'),
    Size(idSize: 6, kichThuoc: '18', donVi: 'cm'),
    Size(idSize: 7, kichThuoc: '20', donVi: 'cm'),
    Size(idSize: 8, kichThuoc: '22', donVi: 'cm'),
  ];

  // Dữ liệu khách hàng
  static List<KhachHang> khachHangList = [
    KhachHang(
      idKh: 1,
      ten: 'Nguyễn Thị Lan',
      email: 'lan.nguyen@email.com',
      sodienthoai: '0901234567',
      diachi: '123 Nguyễn Huệ, Q1, TP.HCM',
      gioiTinh: 'Nữ',
      ngaySinh: DateTime(1995, 5, 15),
      createdAt: DateTime.now().subtract(Duration(days: 60)),
      updatedAt: DateTime.now(),
    ),
    KhachHang(
      idKh: 2,
      ten: 'Trần Văn Nam',
      email: 'nam.tran@email.com',
      sodienthoai: '0912345678',
      diachi: '456 Lê Lợi, Q3, TP.HCM',
      gioiTinh: 'Nam',
      ngaySinh: DateTime(1990, 8, 22),
      createdAt: DateTime.now().subtract(Duration(days: 45)),
      updatedAt: DateTime.now(),
    ),
    KhachHang(
      idKh: 3,
      ten: 'Lê Thị Hoa',
      email: 'hoa.le@email.com',
      sodienthoai: '0923456789',
      diachi: '789 Võ Văn Tần, Q3, TP.HCM',
      gioiTinh: 'Nữ',
      ngaySinh: DateTime(1988, 12, 10),
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    KhachHang(
      idKh: 4,
      ten: 'Phạm Minh Tuấn',
      email: 'tuan.pham@email.com',
      sodienthoai: '0934567890',
      diachi: '321 Hai Bà Trưng, Q1, TP.HCM',
      gioiTinh: 'Nam',
      ngaySinh: DateTime(1992, 3, 8),
      createdAt: DateTime.now().subtract(Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    KhachHang(
      idKh: 5,
      ten: 'Hoàng Thị Mai',
      email: 'mai.hoang@email.com',
      sodienthoai: '0945678901',
      diachi: '654 Cách Mạng Tháng 8, Q10, TP.HCM',
      gioiTinh: 'Nữ',
      ngaySinh: DateTime(1996, 7, 25),
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Dữ liệu nhân viên
  static List<NhanVien> nhanVienList = [
    NhanVien(
      idNv: 1,
      ten: 'Admin System',
      email: 'admin@luxesilver.com',
      sodienthoai: '0987654321',
      diachi: '100 Nguyễn Văn Cừ, Q5, TP.HCM',
      password: 'admin123',
      idQuyen: 1,
      gioiTinh: 'Nam',
      ngaySinh: DateTime(1985, 1, 1),
      trangThai: true,
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    NhanVien(
      idNv: 2,
      ten: 'Nguyễn Văn Quản',
      email: 'quan.manager@luxesilver.com',
      sodienthoai: '0976543210',
      diachi: '200 Lý Thường Kiệt, Q10, TP.HCM',
      password: 'manager123',
      idQuyen: 2,
      gioiTinh: 'Nam',
      ngaySinh: DateTime(1987, 6, 15),
      trangThai: true,
      createdAt: DateTime.now().subtract(Duration(days: 300)),
      updatedAt: DateTime.now(),
    ),
    NhanVien(
      idNv: 3,
      ten: 'Trần Thị Bán',
      email: 'ban.staff@luxesilver.com',
      sodienthoai: '0965432109',
      diachi: '300 Điện Biên Phủ, Q3, TP.HCM',
      password: 'staff123',
      idQuyen: 3,
      gioiTinh: 'Nữ',
      ngaySinh: DateTime(1993, 9, 20),
      trangThai: true,
      createdAt: DateTime.now().subtract(Duration(days: 180)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Dữ liệu phân quyền
  static List<PhanQuyen> phanQuyenList = [
    PhanQuyen(
      idQuyen: 1,
      ten: 'Administrator',
      created_at: DateTime.now().subtract(Duration(days: 365)),
      updated_at: DateTime.now(),
    ),
    PhanQuyen(
      idQuyen: 2,
      ten: 'Manager',
      created_at: DateTime.now().subtract(Duration(days: 365)),
      updated_at: DateTime.now(),
    ),
    PhanQuyen(
      idQuyen: 3,
      ten: 'Staff',
      created_at: DateTime.now().subtract(Duration(days: 365)),
      updated_at: DateTime.now(),
    ),
  ];

  // Dữ liệu sản phẩm mở rộng
  static List<SanPham> sanPhamList = [
    // Dây chuyền
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
    SanPham(
      idSp: 7,
      idLoai: 1,
      tenSp: 'Dây chuyền Bạc Trái Tim Đôi',
      gia: '520000',
      gioiTinh: 'Nữ',
      chatLieu: 'Bạc 925',
      tenPk: 'Dây chuyền romantic',
      inhManh:
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400&h=400&fit=crop',
      mota: 'Dây chuyền bạc với mặt trái tim đôi, biểu tượng tình yêu bất diệt',
      soluong: 30,
      trangThai: true,
      tenLoai: 'Dây chuyền',
      createdAt: DateTime.now().subtract(Duration(days: 12)),
      updatedAt: DateTime.now(),
    ),

    // Nhẫn
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
      idSp: 8,
      idLoai: 2,
      tenSp: 'Nhẫn Cưới Bạc Trơn Classic',
      gia: '320000',
      gioiTinh: 'Unisex',
      chatLieu: 'Bạc 925',
      tenPk: 'Nhẫn cưới',
      inhManh:
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400&h=400&fit=crop',
      mota: 'Nhẵn cưới bạc trơn thiết kế cổ điển, bền đẹp theo thời gian',
      soluong: 60,
      trangThai: true,
      tenLoai: 'Nhẫn',
      createdAt: DateTime.now().subtract(Duration(days: 18)),
      updatedAt: DateTime.now(),
    ),
    SanPham(
      idSp: 9,
      idLoai: 2,
      tenSp: 'Nhẫn Nữ Đính Đá CZ Hình Hoa',
      gia: '385000',
      gioiTinh: 'Nữ',
      chatLieu: 'Bạc 925',
      tenPk: 'Nhẫn hoa',
      inhManh:
          'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?w=400&h=400&fit=crop',
      mota: 'Nhẫn nữ thiết kế hình hoa với đá CZ lấp lánh, nữ tính và tinh tế',
      soluong: 28,
      trangThai: true,
      tenLoai: 'Nhẫn',
      createdAt: DateTime.now().subtract(Duration(days: 8)),
      updatedAt: DateTime.now(),
    ),

    // Bông tai
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
      idSp: 10,
      idLoai: 3,
      tenSp: 'Bông tai Bạc Dáng Dài Elegant',
      gia: '295000',
      gioiTinh: 'Nữ',
      chatLieu: 'Bạc 925',
      tenPk: 'Bông tai dài',
      inhManh:
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400&h=400&fit=crop',
      mota: 'Bông tai bạc dáng dài thanh lịch, phù hợp dự tiệc và sự kiện',
      soluong: 35,
      trangThai: true,
      tenLoai: 'Bông tai',
      createdAt: DateTime.now().subtract(Duration(days: 14)),
      updatedAt: DateTime.now(),
    ),
    SanPham(
      idSp: 11,
      idLoai: 3,
      tenSp: 'Bông tai Tròn Mini Đính Đá',
      gia: '180000',
      gioiTinh: 'Nữ',
      chatLieu: 'Bạc 925',
      tenPk: 'Bông tai tròn',
      inhManh:
          'https://images.unsplash.com/photo-1629194737308-7bef90f4b81b?w=400&h=400&fit=crop',
      mota: 'Bông tai tròn nhỏ xinh đính đá, phù hợp đeo hàng ngày',
      soluong: 50,
      trangThai: true,
      tenLoai: 'Bông tai',
      createdAt: DateTime.now().subtract(Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),

    // Lắc tay
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
      idSp: 12,
      idLoai: 4,
      tenSp: 'Lắc tay Bạc Xích Oval Sang Trọng',
      gia: '420000',
      gioiTinh: 'Unisex',
      chatLieu: 'Bạc 925',
      tenPk: 'Lắc tay xích',
      inhManh:
          'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=400&h=400&fit=crop',
      mota: 'Lắc tay bạc xích oval thiết kế sang trọng, phù hợp cả nam và nữ',
      soluong: 25,
      trangThai: true,
      tenLoai: 'Lắc tay',
      createdAt: DateTime.now().subtract(Duration(days: 11)),
      updatedAt: DateTime.now(),
    ),

    // Đồng hồ
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
      idSp: 13,
      idLoai: 5,
      tenSp: 'Đồng hồ Nam Sport Chống Nước',
      gia: '1200000',
      gioiTinh: 'Nam',
      chatLieu: 'Thép không gỉ',
      tenPk: 'Đồng hồ thể thao',
      inhManh:
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400&h=400&fit=crop',
      mota: 'Đồng hồ nam thể thao chống nước 50m, bền bỉ và mạnh mẽ',
      soluong: 12,
      trangThai: true,
      tenLoai: 'Đồng hồ',
      createdAt: DateTime.now().subtract(Duration(days: 6)),
      updatedAt: DateTime.now(),
    ),

    // Vòng cổ
    SanPham(
      idSp: 14,
      idLoai: 6,
      tenSp: 'Vòng cổ Choker Bạc Minimalist',
      gia: '250000',
      gioiTinh: 'Nữ',
      chatLieu: 'Bạc 925',
      tenPk: 'Vòng cổ choker',
      inhManh:
          'https://images.unsplash.com/photo-1596944924616-7b38e7cfac36?w=400&h=400&fit=crop',
      mota:
          'Vòng cổ choker bạc thiết kế tối giản, xu hướng thời trang hiện đại',
      soluong: 45,
      trangThai: true,
      tenLoai: 'Vòng cổ',
      createdAt: DateTime.now().subtract(Duration(days: 9)),
      updatedAt: DateTime.now(),
    ),

    // Cặp đôi
    SanPham(
      idSp: 15,
      idLoai: 7,
      tenSp: 'Nhẫn Cặp Đôi Khắc Tên Forever Love',
      gia: '580000',
      gioiTinh: 'Unisex',
      chatLieu: 'Bạc 925',
      tenPk: 'Nhẫn cặp đôi',
      inhManh:
          'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?w=400&h=400&fit=crop',
      mota: 'Cặp nhẫn đôi có thể khắc tên, biểu tượng tình yêu vĩnh cửu',
      soluong: 20,
      trangThai: true,
      tenLoai: 'Cặp đôi',
      createdAt: DateTime.now().subtract(Duration(days: 4)),
      updatedAt: DateTime.now(),
    ),

    // Phụ kiện
    SanPham(
      idSp: 16,
      idLoai: 8,
      tenSp: 'Hộp Đựng Trang Sức Cao Cấp',
      gia: '150000',
      gioiTinh: 'Unisex',
      chatLieu: 'Da PU',
      tenPk: 'Hộp đựng trang sức',
      inhManh:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
      mota: 'Hộp đựng trang sức bằng da cao cấp, nhiều ngăn tiện lợi',
      soluong: 100,
      trangThai: true,
      tenLoai: 'Phụ kiện',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Chi tiết sản phẩm theo size (mở rộng)
  static List<ChiTietSanPham> chiTietSanPhamList = [
    // Dây chuyền ID 1
    ChiTietSanPham(
      idCtsp: 1,
      idSp: 1,
      idSize: 5,
      soluong: 20,
      gia: '360000',
      kichThuoc: '15',
      donVi: 'cm',
      createdAt: DateTime.now(),
    ),
    ChiTietSanPham(
      idCtsp: 2,
      idSp: 1,
      idSize: 6,
      soluong: 30,
      gia: '360000',
      kichThuoc: '18',
      donVi: 'cm',
      createdAt: DateTime.now(),
    ),
    // Nhẫn ID 2
    ChiTietSanPham(
      idCtsp: 3,
      idSp: 2,
      idSize: 1,
      soluong: 10,
      gia: '280000',
      kichThuoc: '3.1',
      donVi: 'cm',
      createdAt: DateTime.now(),
    ),
    ChiTietSanPham(
      idCtsp: 4,
      idSp: 2,
      idSize: 2,
      soluong: 15,
      gia: '280000',
      kichThuoc: '5',
      donVi: 'cm',
      createdAt: DateTime.now(),
    ),
    ChiTietSanPham(
      idCtsp: 5,
      idSp: 2,
      idSize: 3,
      soluong: 10,
      gia: '280000',
      kichThuoc: '7',
      donVi: 'cm',
      createdAt: DateTime.now(),
    ),
    // More size details for other products...
  ];

  // Dữ liệu hóa đơn
  static List<HoaDon> hoaDonList = [
    HoaDon(
      id: 1,
      idKh: 1,
      idNv: 3,
      tongGia: 640000,
      ngayLap: DateTime.now().subtract(Duration(days: 10)),
      createdAt: DateTime.now().subtract(Duration(days: 10)),
    ),
    HoaDon(
      id: 2,
      idKh: 2,
      idNv: 3,
      tongGia: 280000,
      ngayLap: DateTime.now().subtract(Duration(days: 8)),
      createdAt: DateTime.now().subtract(Duration(days: 8)),
    ),
    HoaDon(
      id: 3,
      idKh: 3,
      idNv: 2,
      tongGia: 1200000,
      ngayLap: DateTime.now().subtract(Duration(days: 5)),
      createdAt: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  // Chi tiết hóa đơn
  static List<ChiTietHoaDon> chiTietHoaDonList = [
    ChiTietHoaDon(
      idCthd: 1,
      id: 1,
      idCtsp: 1,
      soluong: 1,
      gia: 360000,
      createdAt: DateTime.now().subtract(Duration(days: 10)),
    ),
    ChiTietHoaDon(
      idCthd: 2,
      id: 1,
      idCtsp: 2,
      soluong: 1,
      gia: 280000,
      createdAt: DateTime.now().subtract(Duration(days: 10)),
    ),
    ChiTietHoaDon(
      idCthd: 3,
      id: 2,
      idCtsp: 3,
      soluong: 1,
      gia: 280000,
      createdAt: DateTime.now().subtract(Duration(days: 8)),
    ),
  ];

  // Voucher
  static List<Voucher> voucherList = [
    Voucher(
      idVoucher: 1,
      idLoaiVoucher: 1,
      ten: 'SUMMER2024',
      giatriMin: 15,
      giatriMax: 100000,
      soLuong: 100,
      ngayBatDau: DateTime.now().subtract(Duration(days: 30)),
      ngayKetThuc: DateTime.now().add(Duration(days: 30)),
      trangThai: true,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Voucher(
      idVoucher: 2,
      idLoaiVoucher: 2,
      ten: 'NEWCUSTOMER',
      giatriMin: 50000,
      giatriMax: 0,
      soLuong: 50,
      ngayBatDau: DateTime.now().subtract(Duration(days: 15)),
      ngayKetThuc: DateTime.now().add(Duration(days: 60)),
      trangThai: true,
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Loại voucher
  static List<LoaiVoucher> loaiVoucherList = [
    LoaiVoucher(
      idLoaiVoucher: 1,
      ten: 'Giảm phần trăm',
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    LoaiVoucher(
      idLoaiVoucher: 2,
      ten: 'Giảm tiền mặt',
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Trạng thái đơn hàng
  static List<TrangThaiDonHang> trangThaiDonHangList = [
    TrangThaiDonHang(
      idTtdh: 1,
      ten: 'Chờ xác nhận',
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    TrangThaiDonHang(
      idTtdh: 2,
      ten: 'Đã xác nhận',
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    TrangThaiDonHang(
      idTtdh: 3,
      ten: 'Đang giao hàng',
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    TrangThaiDonHang(
      idTtdh: 4,
      ten: 'Đã giao hàng',
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    TrangThaiDonHang(
      idTtdh: 5,
      ten: 'Đã hủy',
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
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

  // Lấy sản phẩm theo giới tính
  static List<SanPham> getSanPhamByGioiTinh(String gioiTinh) {
    return sanPhamList
        .where(
          (sp) =>
              sp.trangThai &&
              (sp.gioiTinh == gioiTinh || sp.gioiTinh == 'Unisex'),
        )
        .toList();
  }

  // Lấy sản phẩm theo khoảng giá
  static List<SanPham> getSanPhamByGia(double minPrice, double maxPrice) {
    return sanPhamList
        .where(
          (sp) =>
              sp.trangThai &&
              double.parse(sp.gia) >= minPrice &&
              double.parse(sp.gia) <= maxPrice,
        )
        .toList();
  }

  // Lấy sản phẩm bán chạy (dựa trên số lượng bán)
  static List<SanPham> getSanPhamBanChay([int limit = 10]) {
    // Tính toán dựa trên chi tiết hóa đơn
    Map<int, int> sanPhamBanCount = {};

    for (var cthd in chiTietHoaDonList) {
      var ctsp = chiTietSanPhamList.firstWhere(
        (ct) => ct.idCtsp == cthd.idCtsp,
      );
      sanPhamBanCount[ctsp.idSp] =
          (sanPhamBanCount[ctsp.idSp] ?? 0) + cthd.soluong;
    }

    var sortedProducts =
        sanPhamList.where((sp) => sp.trangThai).toList()..sort(
          (a, b) => (sanPhamBanCount[b.idSp] ?? 0).compareTo(
            sanPhamBanCount[a.idSp] ?? 0,
          ),
        );

    return sortedProducts.take(limit).toList();
  }

  // Lấy sản phẩm mới nhất
  static List<SanPham> getSanPhamMoiNhat([int limit = 10]) {
    var sortedProducts =
        sanPhamList.where((sp) => sp.trangThai).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedProducts.take(limit).toList();
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

  // Methods cho khách hàng
  static List<KhachHang> getAllKhachHang() {
    return khachHangList;
  }

  static KhachHang? getKhachHangById(int idKh) {
    try {
      return khachHangList.firstWhere((kh) => kh.idKh == idKh);
    } catch (e) {
      return null;
    }
  }

  static List<KhachHang> searchKhachHang(String query) {
    if (query.isEmpty) return khachHangList;

    String lowerQuery = query.toLowerCase();
    return khachHangList
        .where(
          (kh) =>
              kh.ten.toLowerCase().contains(lowerQuery) ||
              kh.email.toLowerCase().contains(lowerQuery) ||
              kh.sodienthoai.contains(query),
        )
        .toList();
  }

  // Methods cho nhân viên
  static List<NhanVien> getAllNhanVien() {
    return nhanVienList.where((nv) => nv.trangThai).toList();
  }

  static NhanVien? getNhanVienById(int idNv) {
    try {
      return nhanVienList.firstWhere((nv) => nv.idNv == idNv);
    } catch (e) {
      return null;
    }
  }

  static NhanVien? loginNhanVien(String email, String password) {
    try {
      return nhanVienList.firstWhere(
        (nv) => nv.email == email && nv.password == password && nv.trangThai,
      );
    } catch (e) {
      return null;
    }
  }

  // Methods cho hóa đơn
  static List<HoaDon> getAllHoaDon() {
    return hoaDonList;
  }

  static HoaDon? getHoaDonById(int id) {
    try {
      return hoaDonList.firstWhere((hd) => hd.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<HoaDon> getHoaDonByKhachHang(int idKh) {
    return hoaDonList.where((hd) => hd.idKh == idKh).toList();
  }

  static List<HoaDon> getHoaDonByNhanVien(int idNv) {
    return hoaDonList.where((hd) => hd.idNv == idNv).toList();
  }

  static List<HoaDon> getHoaDonByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return hoaDonList
        .where(
          (hd) =>
              hd.ngayLap.isAfter(startDate.subtract(Duration(days: 1))) &&
              hd.ngayLap.isBefore(endDate.add(Duration(days: 1))),
        )
        .toList();
  }

  // Methods cho chi tiết hóa đơn
  static List<ChiTietHoaDon> getChiTietHoaDonByHoaDon(int idHoaDon) {
    return chiTietHoaDonList.where((ct) => ct.id == idHoaDon).toList();
  }

  // Methods cho voucher
  static List<Voucher> getAllVoucher() {
    return voucherList;
  }

  static List<Voucher> getVoucherHopLe() {
    DateTime now = DateTime.now();
    return voucherList
        .where(
          (v) =>
              v.trangThai &&
              v.soLuong > 0 &&
              v.ngayBatDau.isBefore(now) &&
              v.ngayKetThuc.isAfter(now),
        )
        .toList();
  }

  static Voucher? getVoucherByTen(String ten) {
    try {
      return voucherList.firstWhere((v) => v.ten == ten && v.trangThai);
    } catch (e) {
      return null;
    }
  }

  // Thống kê
  static Map<String, dynamic> getThongKeTongQuan() {
    double tongDoanhThu = hoaDonList.fold(0, (sum, hd) => sum + hd.tongGia);
    int tongSanPham = sanPhamList.where((sp) => sp.trangThai).length;
    int tongKhachHang = khachHangList.length;
    int tongDonHang = hoaDonList.length;

    return {
      'tongDoanhThu': tongDoanhThu,
      'tongSanPham': tongSanPham,
      'tongKhachHang': tongKhachHang,
      'tongDonHang': tongDonHang,
    };
  }

  static Map<String, int> getThongKeSanPhamTheoLoai() {
    Map<String, int> result = {};
    for (var loai in loaiSanPhamList) {
      int count =
          sanPhamList
              .where((sp) => sp.idLoai == loai.idLoai && sp.trangThai)
              .length;
      result[loai.tenLoai] = count;
    }
    return result;
  }

  static List<Map<String, dynamic>> getDoanhThuTheoThang(int year) {
    List<Map<String, dynamic>> result = [];

    for (int month = 1; month <= 12; month++) {
      double doanhThu = hoaDonList
          .where((hd) => hd.ngayLap.year == year && hd.ngayLap.month == month)
          .fold(0, (sum, hd) => sum + hd.tongGia);

      result.add({
        'thang': month,
        'doanhThu': doanhThu,
        'tenThang': 'Tháng $month',
      });
    }

    return result;
  }

  // CRUD Operations

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

  // CRUD cho khách hàng
  static void addKhachHang(KhachHang khachHang) {
    khachHangList.add(khachHang);
  }

  static bool updateKhachHang(int idKh, KhachHang updatedKhachHang) {
    int index = khachHangList.indexWhere((kh) => kh.idKh == idKh);
    if (index != -1) {
      khachHangList[index] = updatedKhachHang;
      return true;
    }
    return false;
  }

  // CRUD cho hóa đơn
  static void addHoaDon(HoaDon hoaDon) {
    hoaDonList.add(hoaDon);
  }

  static void addChiTietHoaDon(ChiTietHoaDon chiTietHoaDon) {
    chiTietHoaDonList.add(chiTietHoaDon);
  }

  // CRUD cho voucher
  static void addVoucher(Voucher voucher) {
    voucherList.add(voucher);
  }

  static bool updateVoucher(int idVoucher, Voucher updatedVoucher) {
    int index = voucherList.indexWhere((v) => v.idVoucher == idVoucher);
    if (index != -1) {
      voucherList[index] = updatedVoucher;
      return true;
    }
    return false;
  }

  static bool useVoucher(int idVoucher) {
    int index = voucherList.indexWhere((v) => v.idVoucher == idVoucher);
    if (index != -1 && voucherList[index].soLuong > 0) {
      voucherList[index] = voucherList[index].copyWith(
        soLuong: voucherList[index].soLuong - 1,
      );
      return true;
    }
    return false;
  }

  // Utility methods
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
