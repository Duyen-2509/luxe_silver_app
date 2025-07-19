import 'dart:io';
import '../repository/product_repository.dart';

class ProductController {
  final ProductRepository productRepository;
  ProductController(this.productRepository);

  Future<String?> addProduct({
    required String tensp,
    required String gioitinh,
    required String chatlieu,
    required String tenpk,
    required int idLoai,
    required String mota,
    required String donvi,
    required List<Map<String, String>> sizes,
    required bool isFreesize,
    required List<File> images,
  }) {
    return productRepository.addProduct(
      tensp: tensp,
      gioitinh: gioitinh,
      chatlieu: chatlieu,
      tenpk: tenpk,
      idLoai: idLoai,
      mota: mota,
      donvi: donvi,
      sizes: sizes,
      isFreesize: isFreesize,
      images: images,
    );
  }

  Future<String?> updateProduct({
    required int id,
    required String tensp,
    required String gioitinh,
    required String chatlieu,
    required String tenpk,
    required int idLoai,
    required String mota,
    required int trangthai,
    List<File>? images,
    List<String>? deleteImages,
    required List<Map<String, String>> sizes,
    required bool isFreesize,
    required String donvi,
  }) {
    return productRepository.updateProduct(
      id: id,
      tensp: tensp,
      gioitinh: gioitinh,
      chatlieu: chatlieu,
      tenpk: tenpk,
      idLoai: idLoai,
      mota: mota,
      trangthai: trangthai,
      images: images,
      deleteImages: deleteImages,
      sizes: sizes,
      isFreesize: isFreesize,
      donvi: donvi,
    );
  }

  Future<String?> hideProduct(int id) {
    return productRepository.hideProduct(id);
  }

  Future<String?> showProduct(int id) {
    return productRepository.showProduct(id);
  }
}
