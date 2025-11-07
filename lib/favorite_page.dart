import 'package:appshopsua/detail_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';// Import trang chi tiết sản phẩm

class FavoritePage extends StatefulWidget {
  final String idKhachHang;

  const FavoritePage({
    Key? key,
    required this.idKhachHang,
  }) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formatCurrency = NumberFormat.decimalPattern('vi_VN');

  List<DocumentSnapshot> _favoriteProducts = [];
  bool _loading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      // Nếu idKhachHang được truyền vào widget (ví dụ từ trang đăng nhập)
      if (widget.idKhachHang != null && widget.idKhachHang!.isNotEmpty) {
        setState(() {
          _currentUserId = widget.idKhachHang!;
        });

        // Sau khi lấy được id, tải danh sách yêu thích
        await _loadFavoriteProducts();
      } else {
        // Không có idKhachHang => không đăng nhập
        setState(() {
          _loading = false;
        });
        debugPrint(' Không có idKhachHang, người dùng chưa đăng nhập.');
      }
    } catch (e, st) {
      debugPrint(' Lỗi khi lấy người dùng hiện tại: $e\n$st');
      setState(() {
        _loading = false;
      });
    }
  }


  // Tải danh sách sản phẩm yêu thích
  Future<void> _loadFavoriteProducts() async {
    try {
      if (_currentUserId == null) return;

      final snapshot = await _firestore
          .collection('yeuthich')
          .where('IdKhachHang', isEqualTo: _currentUserId)
          .orderBy('NgayThem', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _favoriteProducts = snapshot.docs;
          _loading = false;
        });
      }
    } catch (e) {
      print('🔥 Lỗi tải danh sách yêu thích: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Xóa sản phẩm khỏi danh sách yêu thích
  Future<void> _removeFromFavorites(String idYeuThich, int index) async {
    try {
      // Hiển thị dialog xác nhận
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa sản phẩm này khỏi danh sách yêu thích?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              child: const Text('Xóa'),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      await _firestore.collection('yeuthich').doc(idYeuThich).delete();

      // Cập nhật UI ngay lập tức
      if (mounted) {
        setState(() {
          _favoriteProducts.removeAt(index);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khỏi danh sách yêu thích'),
          backgroundColor: Colors.pinkAccent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('🔥 Lỗi xóa yêu thích: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Xóa tất cả sản phẩm yêu thích
  Future<void> _clearAllFavorites() async {
    try {
      if (_favoriteProducts.isEmpty) return;

      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Bạn có chắc muốn xóa tất cả (${_favoriteProducts.length}) sản phẩm khỏi danh sách yêu thích?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              child: const Text('Xóa tất cả'),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      // Xóa tất cả documents
      final batch = _firestore.batch();
      for (final doc in _favoriteProducts) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) {
        setState(() {
          _favoriteProducts.clear();
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa tất cả sản phẩm yêu thích'),
          backgroundColor: Colors.pinkAccent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('🔥 Lỗi xóa tất cả yêu thích: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa tất cả: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        actions: [
          if (_favoriteProducts.isNotEmpty)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Xóa tất cả',
            ),
          IconButton(
            onPressed: _loadFavoriteProducts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _currentUserId == null
          ? _buildLoginRequired()
          : _favoriteProducts.isEmpty
          ? _buildEmptyState()
          : _buildFavoriteList(),
    );
  }

  // Widget hiển thị khi chưa đăng nhập
  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Vui lòng đăng nhập',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Đăng nhập để xem sản phẩm yêu thích của bạn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Điều hướng đến trang đăng nhập
              // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: const Icon(Icons.login),
            label: const Text('Đăng nhập'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị khi danh sách trống
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Chưa có sản phẩm yêu thích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hãy thêm sản phẩm bạn yêu thích vào đây',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Quay lại trang trước
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Khám phá sản phẩm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách sản phẩm yêu thích
  Widget _buildFavoriteList() {
    return Column(
      children: [
        // Header thông tin
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.pinkAccent.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_favoriteProducts.length} sản phẩm yêu thích',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              Text(
                'ID: ${_currentUserId!.substring(0, 8)}...',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // Danh sách sản phẩm
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = _favoriteProducts[index];
              final data = product.data() as Map<String, dynamic>;

              return _buildFavoriteItem(product.id, data, index);
            },
          ),
        ),
      ],
    );
  }

  // Widget hiển thị từng item sản phẩm yêu thích
  Widget _buildFavoriteItem(String idYeuThich, Map<String, dynamic> data, int index) {
    final timestamp = data['ngayThem'] as Timestamp?;
    final addedDate = timestamp != null
        ? DateFormat('dd/MM/yyyy').format(timestamp.toDate())
        : 'Không xác định';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Điều hướng đến trang chi tiết sản phẩm
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(
                  idSanPham: data['idSanPham'],
                  tenSP: data['tenSanPham'] ?? 'Sản phẩm',
                  gia: (data['giaGoc'] as num?)?.toDouble() ?? 0,
                  hinhAnh: data['hinhAnh'] ?? '',
                  moTa: '', // Có thể cần lấy thêm từ Firestore
                  doTuoi: data['doTuoi'] ?? '',
                  trongLuong: data['trongLuong'] ?? '',
                  sanXuat: data['sanXuat'] ?? '',
                  soLuong: data['soLuong'] ?? 0,
                  idKhuyenMai: data['idKhuyenMai'],
                  idKhachHang: widget.idKhachHang,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Hình ảnh sản phẩm
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: data['hinhAnh'] != null && data['hinhAnh'].isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(data['hinhAnh']),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: data['hinhAnh'] == null || data['hinhAnh'].isEmpty
                      ? const Icon(Icons.shopping_bag, color: Colors.grey, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),

                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['tenSanPham'] ?? 'Sản phẩm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Giá sản phẩm
                      Row(
                        children: [
                          Text(
                            "${formatCurrency.format(data['gia'])}đ",
                            style: const TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (data['giaGoc'] != null && data['giaGoc'] > data['gia'])
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                "${formatCurrency.format(data['giaGoc'])}đ",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Thông tin ID và ngày thêm
                      Row(
                        children: [
                          Text(
                            'ID: ${data['idYeuThich']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Thêm: $addedDate',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Nút xóa yêu thích
                IconButton(
                  onPressed: () => _removeFromFavorites(idYeuThich, index),
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.pinkAccent,
                  ),
                  tooltip: 'Xóa khỏi yêu thích',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}