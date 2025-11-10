import 'package:appshopsua/detail_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YeuThichPage extends StatefulWidget {
  final String idKhachHang;
  const YeuThichPage({super.key, required this.idKhachHang});

  @override
  State<YeuThichPage> createState() => _YeuThichPageState();
}

class _YeuThichPageState extends State<YeuThichPage> {
  late Future<List<Map<String, dynamic>>> _favoriteProducts;
  final formatCurrency = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    super.initState();
    _favoriteProducts = _loadFavoriteProducts();
  }

  Future<List<Map<String, dynamic>>> _loadFavoriteProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('yeuthich')
        .where('IdKhachHang', isEqualTo: widget.idKhachHang)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Hàm xử lý khi nhấn vào sản phẩm
  void _onProductTap(Map<String, dynamic> product) {
    // Chuyển hướng đến trang chi tiết sản phẩm
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          idSanPham: product['idSanPham'] ?? '',
          tenSP: product['TenSanPham'] ?? 'Sản phẩm',
          gia: (product['Gia'] ?? 0).toDouble(),
          hinhAnh: product['HinhAnh'] ?? '',
          moTa: product['MoTa'] ?? '',
          doTuoi: product['doTuoi'] ?? '',
          trongLuong: product['trongLuong'] ?? '',
          sanXuat: product['sanXuat'] ?? '',
          soLuong: product['soLuong'] ?? 0,
          idKhuyenMai: product['idKhuyenMai'],
          idKhachHang: widget.idKhachHang,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text(
          "Sản phẩm yêu thích",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC4899),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoriteProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Đang tải sản phẩm yêu thích...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final favorites = snapshot.data!;

          return Column(
            children: [
              // Header thông tin
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${favorites.length} sản phẩm",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "trong danh sách yêu thích",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Danh sách sản phẩm
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final product = favorites[index];
                    return _buildProductItem(product, index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBCFE8), Color(0xFFF9A8D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 50,
              color: Color(0xFFEC4899),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Chưa có sản phẩm yêu thích",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9D174D),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Hãy thêm những sản phẩm bạn yêu thích vào đây để xem lại sau",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, int index) {
    final imageUrl = product['HinhAnh'] ?? '';
    final tenSP = product['TenSanPham'] ?? 'Không có tên';
    final giaGiam = (product['Gia'] ?? 0).toDouble();
    final giaGoc = (product['GiaGoc'] ?? 0).toDouble();
    final phanTramGiam = (product['PhanTramGiam'] ?? 0).toDouble();
    final hasDiscount = giaGoc > giaGiam && phanTramGiam > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.pinkAccent.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onProductTap(product),
          splashColor: Colors.pinkAccent.withOpacity(0.1),
          highlightColor: Colors.pinkAccent.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh sản phẩm
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFFDF2F8),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFFEC4899),
                    size: 40,
                  )
                      : null,
                ),
                const SizedBox(width: 16),

                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenSP,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Giá và khuyến mãi
                      if (hasDiscount) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "-${phanTramGiam.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${formatCurrency.format(giaGoc)}₫",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],

                      Text(
                        "${formatCurrency.format(giaGiam)}₫",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC4899),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Ngày thêm (nếu có)
                      if (product['ngayThem'] != null)
                        Text(
                          "Thêm: ${DateFormat('dd/MM/yyyy').format((product['NgayThem'] as Timestamp).toDate())}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),

                // Nút yêu thích
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFBCFE8),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFEC4899),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Giả định ProductDetailPage (bạn cần import đúng trang chi tiết sản phẩm của bạn)