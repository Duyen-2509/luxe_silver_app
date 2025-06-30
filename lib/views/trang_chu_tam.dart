import 'package:flutter/material.dart';
import 'package:luxe_silver_app/views/chi_tiet_sp.dart';
import 'package:luxe_silver_app/views/khung_san_pham.dart';
import '../models/sanPham_model.dart';
import '../repository/produt_data_repository.dart';
import '../services/api_service.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<List<SanPham>> _futureProducts =
        ProductDataRepository(ApiService()).fetchProducts();

    return Scaffold(
      appBar: AppBar(title: const Text('LuxeSilver')),
      body: FutureBuilder<List<SanPham>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          final visibleProducts =
              products
                  .where((sp) => (sp.trangthai ?? 1) == 1 && sp.soluongKho > 0)
                  .toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: visibleProducts.length,
            itemBuilder: (context, index) {
              final sanPham = visibleProducts[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductDetailScreen(
                            userData: {},
                            productId: sanPham.idSp,
                          ),
                    ),
                  );
                },
                child: ProductCard(sanPham: sanPham),
              );
            },
          );
        },
      ),
    );
  }
}
