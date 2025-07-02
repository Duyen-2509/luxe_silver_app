class SanPham {
  final int idSp;
  final String tensp;
  final String gioitinh;
  final String chatlieu;
  final String? tenpk;
  final int idLoai;
  final String tenloai;
  final String? mota;
  final String? imageUrl;
  final List<String>? images;
  final List<SanPhamDetail>? details;
  final int? gia;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  int? trangthai;

  SanPham({
    required this.idSp,
    required this.tensp,
    required this.gioitinh,
    required this.chatlieu,
    this.tenpk,
    required this.idLoai,
    required this.tenloai,
    this.mota,
    this.imageUrl,
    this.images,
    this.details,
    this.gia,
    this.trangthai,
    this.createdAt,
    this.updatedAt,
  });

  /// Lấy giá thấp nhất từ details (nếu có), nếu không thì lấy trường gia, trả về chuỗi đã format
  String get formattedMinPrice {
    // Nếu có details và có ít nhất 1 phần tử, lấy giá nhỏ nhất trong details
    if (details != null && details!.isNotEmpty) {
      final minGia = details!.map((d) => d.gia).reduce((a, b) => a < b ? a : b);
      return '${minGia.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
    }
    // Nếu không có details, lấy trường gia (giá tổng quát của sản phẩm)
    if (gia != null) {
      return '${gia!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
    }
    // Nếu không có giá, trả về "Liên hệ"
    return 'Liên hệ';
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sp': idSp,
      'tensp': tensp,
      'gioitinh': gioitinh,
      'chatlieu': chatlieu,
      'tenpk': tenpk,

      'id_loai': idLoai,
      'tenloai': tenloai,
      'mota': mota,
      'image_url': imageUrl,
      'images': images,
      'details': details?.map((e) => e.toJson()).toList(),
      'gia': gia,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory SanPham.fromJson(Map<String, dynamic> json) {
    return SanPham(
      idSp: json['id_sp'],
      tensp: json['tensp'],
      gioitinh: json['gioitinh'],
      chatlieu: json['chatlieu'],
      tenpk: json['tenpk'],

      idLoai: json['id_loai'],
      tenloai: json['tenloai'] ?? '',
      mota: json['mota'],
      imageUrl: json['image_url'],
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      details:
          (json['details'] as List?)
              ?.map((e) => SanPhamDetail.fromJson(e))
              .toList(),
      gia: json['gia'],
      trangthai:
          json['trangthai'] is int
              ? json['trangthai']
              : int.tryParse(json['trangthai']?.toString() ?? '1'),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }
}

class SanPhamDetail {
  final int idCtsp;
  final int gia;
  final int soluongKho;
  final int soluongDaban;
  final String kichthuoc;
  final String donvi;

  SanPhamDetail({
    required this.idCtsp,
    required this.gia,
    required this.soluongKho,
    required this.soluongDaban,
    required this.kichthuoc,
    required this.donvi,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_ctsp': idCtsp,
      'gia': gia,
      'soluong_kho': soluongKho,
      'soluong_daban': soluongDaban,
      'kichthuoc': kichthuoc,
      'donvi': donvi,
    };
  }

  factory SanPhamDetail.fromJson(Map<String, dynamic> json) {
    return SanPhamDetail(
      idCtsp: json['id_ctsp'],
      gia: json['gia'],
      soluongKho: json['soluong_kho'] ?? 0,
      soluongDaban: json['soluong_daban'] ?? 0,
      kichthuoc: json['kichthuoc'].toString(),
      donvi: json['donvi'],
    );
  }
}
