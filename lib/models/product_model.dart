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
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
    this.createdAt,
    this.updatedAt,
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
      // Nếu có đường dẫn hình từ database
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
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
  final DateTime? createdAt;

  // Thông tin join
  final String? kichThuoc;
  final String? donVi;

  ChiTietSanPham({
    required this.idCtsp,
    required this.idSp,
    required this.idSize,
    required this.soluong,
    required this.gia,
    this.createdAt,
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
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
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
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
