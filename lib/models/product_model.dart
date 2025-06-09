import 'package:intl/intl.dart';

// Model cho bảng loai (Categories)
class LoaiSanPham {
  final int idLoai;
  final String tenLoai;

  LoaiSanPham({required this.idLoai, required this.tenLoai});

  factory LoaiSanPham.fromJson(Map<String, dynamic> json) {
    return LoaiSanPham(
      idLoai: json['id_loai'] ?? 0,
      tenLoai: json['tenloai'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_loai': idLoai, 'tenloai': tenLoai};
  }
}

// Model cho bảng size
class Size {
  final int idSize;
  final String kichThuoc;
  final String donVi;

  Size({required this.idSize, required this.kichThuoc, required this.donVi});

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      idSize: json['id_size'] ?? 0,
      kichThuoc: json['kichthuoc'] ?? '',
      donVi: json['donvi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_size': idSize, 'kichthuoc': kichThuoc, 'donvi': donVi};
  }
}

// Model cho bảng sanpham (Products)
class SanPham {
  final int idSp;
  final int idLoai;
  final String tenSp;
  final String gia;
  final String gioiTinh;
  final String chatLieu;
  final String tenPk;
  final String inhManh;
  final String mota;
  final int soluong;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool trangThai;

  // Thông tin join từ bảng khác
  final String? tenLoai;
  final List<ChiTietSanPham>? chiTietList;

  SanPham({
    required this.idSp,
    required this.idLoai,
    required this.tenSp,
    required this.gia,
    required this.gioiTinh,
    required this.chatLieu,
    required this.tenPk,
    required this.inhManh,
    required this.mota,
    required this.soluong,
    required this.createdAt,
    required this.updatedAt,
    this.trangThai = true,
    this.tenLoai,
    this.chiTietList,
  });

  // Format giá tiền theo định dạng VND
  String get formattedPrice {
    try {
      double price = double.parse(gia.replaceAll(',', ''));
      final formatter = NumberFormat('#,###', 'vi_VN');
      return '${formatter.format(price)} VND';
    } catch (e) {
      return '$gia VND';
    }
  }

  // Lấy hình ảnh chính
  String get imageUrl {
    if (inhManh.isNotEmpty) {
      return inhManh;
    }
    // Fallback image
    return 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&h=400&fit=crop';
  }

  factory SanPham.fromJson(Map<String, dynamic> json) {
    return SanPham(
      idSp: json['id_sp'] ?? 0,
      idLoai: json['id_loai'] ?? 0,
      tenSp: json['tensp'] ?? '',
      gia: json['gia']?.toString() ?? '0',
      gioiTinh: json['gioitinh'] ?? '',
      chatLieu: json['chatlieu'] ?? '',
      tenPk: json['tenpk'] ?? '',
      inhManh: json['inhmanh'] ?? '',
      mota: json['mota'] ?? '',
      soluong: json['soluong'] ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      trangThai: json['trangthai'] == 1 || json['trangthai'] == true,
      tenLoai: json['tenloai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sp': idSp,
      'id_loai': idLoai,
      'tensp': tenSp,
      'gia': gia,
      'gioitinh': gioiTinh,
      'chatlieu': chatLieu,
      'tenpk': tenPk,
      'inhmanh': inhManh,
      'mota': mota,
      'soluong': soluong,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'trangthai': trangThai ? 1 : 0,
    };
  }

  SanPham copyWith({
    int? idSp,
    int? idLoai,
    String? tenSp,
    String? gia,
    String? gioiTinh,
    String? chatLieu,
    String? tenPk,
    String? inhManh,
    String? mota,
    int? soluong,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? trangThai,
    String? tenLoai,
    List<ChiTietSanPham>? chiTietList,
  }) {
    return SanPham(
      idSp: idSp ?? this.idSp,
      idLoai: idLoai ?? this.idLoai,
      tenSp: tenSp ?? this.tenSp,
      gia: gia ?? this.gia,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      chatLieu: chatLieu ?? this.chatLieu,
      tenPk: tenPk ?? this.tenPk,
      inhManh: inhManh ?? this.inhManh,
      mota: mota ?? this.mota,
      soluong: soluong ?? this.soluong,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trangThai: trangThai ?? this.trangThai,
      tenLoai: tenLoai ?? this.tenLoai,
      chiTietList: chiTietList ?? this.chiTietList,
    );
  }
}

// Model cho bảng chitiet_sp
class ChiTietSanPham {
  final int idCtsp;
  final int idSp;
  final int idSize;
  final int soluong;
  final String gia;
  final DateTime createdAt;

  // Thông tin join
  final String? kichThuoc;
  final String? donVi;

  ChiTietSanPham({
    required this.idCtsp,
    required this.idSp,
    required this.idSize,
    required this.soluong,
    required this.gia,
    required this.createdAt,
    this.kichThuoc,
    this.donVi,
  });

  String get formattedPrice {
    try {
      double price = double.parse(gia.replaceAll(',', ''));
      final formatter = NumberFormat('#,###', 'vi_VN');
      return '${formatter.format(price)} VND';
    } catch (e) {
      return '$gia VND';
    }
  }

  factory ChiTietSanPham.fromJson(Map<String, dynamic> json) {
    return ChiTietSanPham(
      idCtsp: json['id_ctsp'] ?? 0,
      idSp: json['id_sp'] ?? 0,
      idSize: json['id_size'] ?? 0,
      soluong: json['soluong'] ?? 0,
      gia: json['gia']?.toString() ?? '0',
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      kichThuoc: json['kichthuoc'],
      donVi: json['donvi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ctsp': idCtsp,
      'id_sp': idSp,
      'id_size': idSize,
      'soluong': soluong,
      'gia': gia,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Model cho bảng khachhang
class KhachHang {
  final int idKh;
  final String ten;
  final String email;
  final String sodienthoai;
  final String diachi;
  final String gioiTinh;
  final DateTime ngaySinh;
  final DateTime createdAt;
  final DateTime updatedAt;

  KhachHang({
    required this.idKh,
    required this.ten,
    required this.email,
    required this.sodienthoai,
    required this.diachi,
    required this.gioiTinh,
    required this.ngaySinh,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      idKh: json['id_kh'] ?? 0,
      ten: json['ten'] ?? '',
      email: json['email'] ?? '',
      sodienthoai: json['sodienthoai'] ?? '',
      diachi: json['diachi'] ?? '',
      gioiTinh: json['gioitinh'] ?? '',
      ngaySinh:
          json['ngaysinh'] != null
              ? DateTime.tryParse(json['ngaysinh'].toString()) ?? DateTime.now()
              : DateTime.now(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kh': idKh,
      'ten': ten,
      'email': email,
      'sodienthoai': sodienthoai,
      'diachi': diachi,
      'gioitinh': gioiTinh,
      'ngaysinh': ngaySinh.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Model cho bảng nhanvien
class NhanVien {
  final int idNv;
  final String ten;
  final String email;
  final String sodienthoai;
  final String diachi;
  final String password;
  final int idQuyen;
  final String gioiTinh;
  final DateTime ngaySinh;
  final bool trangThai;
  final DateTime createdAt;
  final DateTime updatedAt;

  NhanVien({
    required this.idNv,
    required this.ten,
    required this.email,
    required this.sodienthoai,
    required this.diachi,
    required this.password,
    required this.idQuyen,
    required this.gioiTinh,
    required this.ngaySinh,
    this.trangThai = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NhanVien.fromJson(Map<String, dynamic> json) {
    return NhanVien(
      idNv: json['id_nv'] ?? 0,
      ten: json['ten'] ?? '',
      email: json['email'] ?? '',
      sodienthoai: json['sodienthoai'] ?? '',
      diachi: json['diachi'] ?? '',
      password: json['password'] ?? '',
      idQuyen: json['id_quyen'] ?? 0,
      gioiTinh: json['gioitinh'] ?? '',
      ngaySinh:
          json['ngaysinh'] != null
              ? DateTime.tryParse(json['ngaysinh'].toString()) ?? DateTime.now()
              : DateTime.now(),
      trangThai: json['trangthai'] == 1 || json['trangthai'] == true,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_nv': idNv,
      'ten': ten,
      'email': email,
      'sodienthoai': sodienthoai,
      'diachi': diachi,
      'password': password,
      'id_quyen': idQuyen,
      'gioitinh': gioiTinh,
      'ngaysinh': ngaySinh.toIso8601String(),
      'trangthai': trangThai ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Model cho bảng phanquyen
class PhanQuyen {
  final int idQuyen;
  final String ten;
  final DateTime created_at;
  final DateTime updated_at;

  PhanQuyen({
    required this.idQuyen,
    required this.ten,
    required this.created_at,
    required this.updated_at,
  });

  factory PhanQuyen.fromJson(Map<String, dynamic> json) {
    return PhanQuyen(
      idQuyen: json['id_quyen'] ?? 0,
      ten: json['ten'] ?? '',
      created_at:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      updated_at:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_quyen': idQuyen,
      'ten': ten,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }
}

// Model cho bảng hoadon
class HoaDon {
  final int id;
  final int idKh;
  final int idNv;
  final double tongGia;
  final DateTime ngayLap;
  final DateTime createdAt;

  HoaDon({
    required this.id,
    required this.idKh,
    required this.idNv,
    required this.tongGia,
    required this.ngayLap,
    required this.createdAt,
  });

  String get formattedTotal {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(tongGia)} VND';
  }

  factory HoaDon.fromJson(Map<String, dynamic> json) {
    return HoaDon(
      id: json['id'] ?? 0,
      idKh: json['id_kh'] ?? 0,
      idNv: json['id_nv'] ?? 0,
      tongGia: (json['tonggia'] ?? 0).toDouble(),
      ngayLap:
          json['ngaylap'] != null
              ? DateTime.tryParse(json['ngaylap'].toString()) ?? DateTime.now()
              : DateTime.now(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_kh': idKh,
      'id_nv': idNv,
      'tonggia': tongGia,
      'ngaylap': ngayLap.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Model cho bảng chitiethoadon
class ChiTietHoaDon {
  final int idCthd;
  final int id;
  final int idCtsp;
  final int soluong;
  final double gia;
  final DateTime createdAt;

  ChiTietHoaDon({
    required this.idCthd,
    required this.id,
    required this.idCtsp,
    required this.soluong,
    required this.gia,
    required this.createdAt,
  });

  String get formattedPrice {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(gia)} VND';
  }

  double get thanhTien => gia * soluong;

  String get formattedThanhTien {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(thanhTien)} VND';
  }

  factory ChiTietHoaDon.fromJson(Map<String, dynamic> json) {
    return ChiTietHoaDon(
      idCthd: json['id_cthd'] ?? 0,
      id: json['id'] ?? 0,
      idCtsp: json['id_ctsp'] ?? 0,
      soluong: json['soluong'] ?? 0,
      gia: (json['gia'] ?? 0).toDouble(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cthd': idCthd,
      'id': id,
      'id_ctsp': idCtsp,
      'soluong': soluong,
      'gia': gia,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Model cho bảng voucher
class Voucher {
  final int idVoucher;
  final int idLoaiVoucher;
  final String ten;
  final double giatriMin;
  final double giatriMax;
  final int soLuong;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final bool trangThai;
  final DateTime createdAt;
  final DateTime updatedAt;

  Voucher({
    required this.idVoucher,
    required this.idLoaiVoucher,
    required this.ten,
    required this.giatriMin,
    required this.giatriMax,
    required this.soLuong,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    this.trangThai = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Voucher copyWith({
    int? idVoucher,
    int? idLoaiVoucher,
    String? ten,
    double? giatriMin,
    double? giatriMax,
    int? soLuong,
    DateTime? ngayBatDau,
    DateTime? ngayKetThuc,
    bool? trangThai,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Voucher(
      idVoucher: idVoucher ?? this.idVoucher,
      idLoaiVoucher: idLoaiVoucher ?? this.idLoaiVoucher,
      ten: ten ?? this.ten,
      giatriMin: giatriMin ?? this.giatriMin,
      giatriMax: giatriMax ?? this.giatriMax,
      soLuong: soLuong ?? this.soLuong,
      ngayBatDau: ngayBatDau ?? this.ngayBatDau,
      ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
      trangThai: trangThai ?? this.trangThai,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      idVoucher: json['id_voucher'] ?? 0,
      idLoaiVoucher: json['id_loai_voucher'] ?? 0,
      ten: json['ten'] ?? '',
      giatriMin: (json['giatrimin'] ?? 0).toDouble(),
      giatriMax: (json['giatrimax'] ?? 0).toDouble(),
      soLuong: json['soluong'] ?? 0,
      ngayBatDau:
          json['ngaybatdau'] != null
              ? DateTime.tryParse(json['ngaybatdau'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      ngayKetThuc:
          json['ngayketthuc'] != null
              ? DateTime.tryParse(json['ngayketthuc'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      trangThai: json['trangthai'] == 1 || json['trangthai'] == true,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_voucher': idVoucher,
      'id_loai_voucher': idLoaiVoucher,
      'ten': ten,
      'giatrimin': giatriMin,
      'giatrimax': giatriMax,
      'soluong': soLuong,
      'ngaybatdau': ngayBatDau.toIso8601String(),
      'ngayketthuc': ngayKetThuc.toIso8601String(),
      'trangthai': trangThai ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Model cho bảng loaivoucher
class LoaiVoucher {
  final int idLoaiVoucher;
  final String ten;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoaiVoucher({
    required this.idLoaiVoucher,
    required this.ten,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoaiVoucher.fromJson(Map<String, dynamic> json) {
    return LoaiVoucher(
      idLoaiVoucher: json['id_loai_voucher'] ?? 0,
      ten: json['ten'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_loai_voucher': idLoaiVoucher,
      'ten': ten,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Model cho bảng trangthaidonhang
class TrangThaiDonHang {
  final int idTtdh;
  final String ten;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrangThaiDonHang({
    required this.idTtdh,
    required this.ten,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrangThaiDonHang.fromJson(Map<String, dynamic> json) {
    return TrangThaiDonHang(
      idTtdh: json['id_ttdh'] ?? 0,
      ten: json['ten'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ttdh': idTtdh,
      'ten': ten,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
