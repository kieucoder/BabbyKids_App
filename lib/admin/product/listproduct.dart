import 'package:appshopsua/admin/product/addproduct_page.dart';
import 'package:appshopsua/admin/product/deleteproduct.dart';
import 'package:appshopsua/admin/product/editproduct.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListProductPage extends StatefulWidget {
  const ListProductPage({super.key});

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _backgroundColor = const Color(0xFFF0F8FF);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF1E293B);
  final Color _hintColor = const Color(0xFF64748B);
  final Color _successColor = const Color(0xFF10B981);
  final Color _errorColor = const Color(0xFFEF4444);

  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();

  // Format currency
  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Danh sách sản phẩm",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header với thống kê
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Thanh tìm kiếm
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm sản phẩm...",
                      hintStyle: TextStyle(color: _hintColor),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search_rounded, color: _primaryColor),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: _hintColor),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = "");
                        },
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) => setState(() => _searchText = value.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(height: 16),
                // Thống kê nhanh
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("sanpham").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final totalProducts = snapshot.data!.docs.length;
                    final activeProducts = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data["TrangThai"] == "Hoạt Động";
                    }).length;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          value: totalProducts.toString(),
                          label: "Tổng SP",
                          icon: Icons.inventory_2_rounded,
                        ),
                        _buildStatItem(
                          value: activeProducts.toString(),
                          label: "Đang hoạt động",
                          icon: Icons.check_circle_rounded,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Danh sách sản phẩm
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("sanpham").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ten = data["TenSanPham"]?.toString().toLowerCase() ?? "";
                  final id = data["IdSanPham"]?.toString().toLowerCase() ?? "";
                  return ten.contains(_searchText) || id.contains(_searchText);
                }).toList();

                if (docs.isEmpty) {
                  return _buildNoResultsState();
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildProductCard(data, doc.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Nút thêm sản phẩm
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  AddProductPage()),
          );
        },
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          "Thêm sản phẩm",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label, required IconData icon}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> data, String docId) {
    final isActive = data["TrangThai"] == "Hoạt Động";
    final price = data["Gia"] ?? 0;
    final discount = data["PhanTramGiam"] ?? 0;
    final finalPrice = discount > 0 ? price * (100 - discount) ~/ 100 : price;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh sản phẩm
                _buildProductImage(data["HinhAnh"] ?? ""),
                const SizedBox(width: 12),

                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên sản phẩm và trạng thái
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data["TenSanPham"] ?? "Không có tên",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: _textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _successColor.withOpacity(0.1)
                                  : _errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActive ? _successColor : _errorColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isActive ? "🟢 Hoạt động" : "🔴 Ngưng hoạt động",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isActive ? _successColor : _errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Giá sản phẩm
                      if (discount > 0) ...[
                        Row(
                          children: [
                            Text(
                              _formatPrice(finalPrice),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatPrice(price),
                              style: TextStyle(
                                fontSize: 12,
                                color: _hintColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "-$discount%",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          _formatPrice(price),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Thông tin bổ sung
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _buildInfoItem(
                            icon: Icons.inventory_2_rounded,
                            text: "SL: ${data["SoLuong"] ?? 0}",
                          ),
                          if (data["DoTuoi"] != null && data["DoTuoi"].toString().isNotEmpty)
                            _buildInfoItem(
                              icon: Icons.child_care_rounded,
                              text: data["DoTuoi"].toString(),
                            ),
                          if (data["TrongLuong"] != null && data["TrongLuong"].toString().isNotEmpty)
                            _buildInfoItem(
                              icon: Icons.scale_rounded,
                              text: data["TrongLuong"].toString(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer với các nút hành động
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // ID sản phẩm
                Expanded(
                  child: Text(
                    "ID: ${data["IdSanPham"] ?? "N/A"}",
                    style: TextStyle(
                      fontSize: 12,
                      color: _hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Nút hành động
                Row(
                  children: [
                    // Nút sửa
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: _primaryColor,
                      tooltip: "Sửa sản phẩm",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductPage(
                              productId: data["IdSanPham"],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),

                    // Nút xóa
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: _errorColor,
                      tooltip: "Xóa sản phẩm",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeleteProductPage(
                              idSanPham: data["IdSanPham"],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _backgroundColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: _backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_rounded, color: _hintColor, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    "No Image",
                    style: TextStyle(
                      fontSize: 10,
                      color: _hintColor,
                    ),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: _backgroundColor,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: _primaryColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _hintColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: _hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 16),
          Text(
            "Đang tải sản phẩm...",
            style: TextStyle(color: _hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: _hintColor),
          const SizedBox(height: 16),
          Text(
            "Chưa có sản phẩm nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy thêm sản phẩm đầu tiên của bạn",
            style: TextStyle(color: _hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: _hintColor),
          const SizedBox(height: 16),
          Text(
            "Không tìm thấy sản phẩm",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Thử với từ khóa tìm kiếm khác",
            style: TextStyle(color: _hintColor),
          ),
        ],
      ),
    );
  }
}