import 'package:flutter/material.dart';

import '../models/giohang_model.dart';
import '../models/sanPham_model.dart';

class CartController extends ChangeNotifier {
  static final CartController _instance = CartController._internal();
  factory CartController() => _instance;
  CartController._internal();

  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.soLuong);

  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.tongGia);

  void addToCart(SanPham sanPham, {String? size, int quantity = 1}) {
    int existingIndex = _cartItems.indexWhere(
      (item) => item.sanPham.idSp == sanPham.idSp && item.selectedSize == size,
    );
    if (existingIndex >= 0) {
      _cartItems[existingIndex].soLuong += quantity;
    } else {
      _cartItems.add(
        CartItem(sanPham: sanPham, selectedSize: size, soLuong: quantity),
      );
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void removeManyFromCart(List<CartItem> itemsToRemove) {
    cartItems.removeWhere(
      (item) => itemsToRemove.any(
        (selected) =>
            selected.sanPham.idSp == item.sanPham.idSp &&
            selected.selectedSize == item.selectedSize,
      ),
    );
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length && newQuantity > 0) {
      _cartItems[index].soLuong = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
