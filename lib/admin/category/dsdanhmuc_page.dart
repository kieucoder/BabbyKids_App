import 'package:appshopsua/admin/category/addcategory_page.dart';
import 'package:appshopsua/admin/category/deletecategory_page.dart';
import 'package:appshopsua/admin/category/editcategory_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  // Color scheme được cải thiện
  final Color _primaryColor = const Color(0xFF2563EB);
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF1E293B);
  final Color _hintColor = const Color(0xFF64748B);
  final Color _successColor = const Color(0xFF10B981);
  final Color _errorColor = const Color(0xFFEF4444);
  final Color _borderColor = const Color(0xFFE2E8F0);

  String _searchText = "";
  String _filterStatus = "Tất cả";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Danh sách danh mục",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
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
                      hintText: "Tìm kiếm danh mục...",
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
                  stream: FirebaseFirestore.instance.collection("danhmuc").orderBy("IdDanhMuc",descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final totalCategories = snapshot.data!.docs.length;
                    final activeCategories = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data["TrangThai"] == "Hoạt Động";
                    }).length;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          value: totalCategories.toString(),
                          label: "Tổng DM",
                          icon: Icons.category_rounded,
                        ),
                        _buildStatItem(
                          value: activeCategories.toString(),
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

          // Danh sách danh mục - CHỈNH SỬA: ListView thay vì GridView
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("danhmuc").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ten = data["Ten"]?.toString().toLowerCase() ?? "";
                  return ten.contains(_searchText);
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
                      return _buildCategoryCard(data, doc.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Nút thêm danh mục
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCategoryPage()),
          );
        },
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          "Thêm danh mục",
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

  // CHỈNH SỬA: Card danh mục hiển thị 1 hàng
  Widget _buildCategoryCard(Map<String, dynamic> data, String docId) {
    final isActive = data["TrangThai"] == "Hoạt Động";

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh danh mục
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              color: _backgroundColor,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: data["HinhAnh"] != null && data["HinhAnh"].toString().isNotEmpty
                  ? Image.network(
                data["HinhAnh"].toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImageError();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImageLoading();
                },
              )
                  : _buildImagePlaceholder(),
            ),
          ),

          // Thông tin danh mục
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header với tên và trạng thái
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["Ten"] ?? "Không có tên",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: _textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Badge trạng thái
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? _successColor.withOpacity(0.1)
                                    : _errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isActive ? _successColor : _errorColor,
                                ),
                              ),
                              child: Text(
                                isActive ? "Hoạt động" : "Ngưng hoạt động",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? _successColor : _errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Mô tả (nếu có)


                  // Nút hành động
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.edit_rounded,
                            color: _primaryColor,
                            tooltip: "Sửa danh mục",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditCategoryPage(
                                    idDanhMuc: data["IdDanhMuc"],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.delete_rounded,
                            color: _errorColor,
                            tooltip: "Xóa danh mục",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeleteCategoryPage(
                                    idDanhMuc: data["IdDanhMuc"],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: _backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, size: 32, color: _hintColor),
          const SizedBox(height: 4),
          Text(
            "Lỗi tải ảnh",
            style: TextStyle(
              fontSize: 12,
              color: _hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageLoading() {
    return Container(
      color: _backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: _backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 32, color: _hintColor),
          const SizedBox(height: 4),
          Text(
            "Không có ảnh",
            style: TextStyle(
              fontSize: 12,
              color: _hintColor,
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20, color: color),
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
            "Đang tải danh mục...",
            style: TextStyle(
              color: _textColor,
              fontSize: 16,
            ),
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
          Icon(Icons.category_outlined, size: 80, color: _hintColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "Chưa có danh mục nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy thêm danh mục đầu tiên của bạn",
            style: TextStyle(
              color: _hintColor,
              fontSize: 14,
            ),
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
          Icon(Icons.search_off_rounded, size: 80, color: _hintColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "Không tìm thấy danh mục",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Thử với từ khóa tìm kiếm khác",
            style: TextStyle(
              color: _hintColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}