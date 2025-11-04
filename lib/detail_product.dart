import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final String idSanPham;
  final String tenSP;
  final double gia;
  final String hinhAnh;
  final String moTa;
  final String doTuoi;
  final String trongLuong;
  final String sanXuat;
  final int soLuong;
  final String? idKhuyenMai;

  const ProductDetailPage({
    super.key,
    required this.idSanPham,
    required this.tenSP,
    required this.gia,
    required this.hinhAnh,
    required this.moTa,
    required this.doTuoi,
    required this.trongLuong,
    required this.sanXuat,
    required this.soLuong,
    this.idKhuyenMai,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedTab = 0;
  final formatCurrency = NumberFormat.decimalPattern('vi_VN');

  double _userRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime _reviewDate = DateTime.now();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔥 HÀM LẤY PHẦN TRĂM GIẢM TỪ FIRESTORE
  Future<double> _fetchPhanTramGiam() async {
    try {
      if (widget.idKhuyenMai == null || widget.idKhuyenMai!.isEmpty) return 0;

      final doc = await FirebaseFirestore.instance
          .collection('khuyenmai')
          .doc(widget.idKhuyenMai)
          .get();

      if (!doc.exists) return 0;

      final data = doc.data();
      if (data == null) return 0;

      if (data['TrangThai'] != 'Đang hoạt động') return 0;

      return (data['PhanTramGiam'] as num?)?.toDouble() ?? 0;
    } catch (e) {
      print("🔥 Lỗi lấy khuyến mãi: $e");
      return 0;
    }
  }

  // 🛒 Thêm vào giỏ hàng
  Future<void> _addToCart(Map<String, dynamic> sanPham) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng đăng nhập để mua hàng")),
        );
        return;
      }

      final gioHangRef = FirebaseFirestore.instance
          .collection('chitietdonhang')
          .doc(userId)
          .collection('sanpham');

      final productId = sanPham['IdSanPham'] ?? '';
      if (productId.isEmpty) return;

      final existing =
      await gioHangRef.where('IdSanPham', isEqualTo: productId).limit(1).get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final soLuongCu = doc['SoLuong'] ?? 1;
        await gioHangRef.doc(doc.id).update({'SoLuong': soLuongCu + 1});
      } else {
        await gioHangRef.add({
          'IdSanPham': productId,
          'TenSanPham': sanPham['TenSanPham'] ?? '',
          'Gia': sanPham['Gia'] ?? 0,
          'HinhAnh': sanPham['HinhAnh'] ?? '',
          'SoLuong': 1,
          'PhanTramGiam': sanPham['PhanTramGiam'] ?? 0,

        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã thêm vào giỏ hàng!"),
          backgroundColor: Colors.pinkAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi thêm sản phẩm vào giỏ: $e")),
      );
    }
  }

  // Kiểm tra có thể đánh giá không
  Future<bool> _canReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return false;

      final ratingQuery = await _firestore
          .collection('danhgia')
          .where('IdKhachHang', isEqualTo: userId)
          .where('IdSanPham', isEqualTo: widget.idSanPham)
          .limit(1)
          .get();
      if (ratingQuery.docs.isNotEmpty) return false;

      final ordersQuery = await _firestore
          .collection('donhang')
          .where('IdKhachHang', isEqualTo: userId)
          .where('TrangThai', isEqualTo: 'Đã giao')
          .get();
      if (ordersQuery.docs.isEmpty) return false;

      for (final orderDoc in ordersQuery.docs) {
        final orderId = orderDoc.id;
        final orderItemsQuery = await _firestore
            .collection('chitietdonhang')
            .where('MaDonHang', isEqualTo: orderId)
            .where('IdSanPham', isEqualTo: widget.idSanPham)
            .limit(1)
            .get();
        if (orderItemsQuery.docs.isNotEmpty) return true;
      }
      return false;
    } catch (e) {
      print('🔥 Lỗi kiểm tra đánh giá: $e');
      return false;
    }
  }

  // Gửi đánh giá
  Future<void> _submitReview() async {
    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final comment = _commentController.text.trim();
      if (name.isEmpty || email.isEmpty || comment.isEmpty || _userRating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đủ thông tin!")),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return;

      final canReview = await _canReview();
      if (!canReview) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không đủ điều kiện đánh giá!")),
        );
        return;
      }

      await _firestore.collection('danhgia').add({
        'IdKhachHang': userId,
        'IdSanPham': widget.idSanPham,
        'TenNguoiDanhGia': name,
        'Email': email,
        'SoSao': _userRating,
        'BinhLuan': comment,
        'NgayDanhGia': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đánh giá thành công!")),
      );

      _nameController.clear();
      _emailController.clear();
      _commentController.clear();
      setState(() {
        _userRating = 0;
        _reviewDate = DateTime.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi gửi đánh giá: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.tenSP,
            style: const TextStyle(fontSize: 18, color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
      FutureBuilder<double>(
        future: _fetchPhanTramGiam(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          double phanTram = snapshot.data ?? 0;
          double giaSauGiam = widget.gia * (1 - (phanTram / 100));

          return SingleChildScrollView(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(widget.hinhAnh, fit: BoxFit.contain),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (phanTram > 0)
                        Row(
                          children: [
                            Text(
                              "${formatCurrency.format(widget.gia)}đ",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "-${phanTram.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Text(
                        "${formatCurrency.format(giaSauGiam)}đ",
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.tenSP,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE7EE),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildTabButton("Thông số kỹ thuật", 0),
                      _buildTabButton("Bài viết chi tiết", 1),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _selectedTab == 0 ? _buildThongSo() : _buildMoTa(),
                ),
                const SizedBox(height: 30),
                _buildRatingForm(),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () async {
              double phanTram = await _fetchPhanTramGiam();
              Map<String, dynamic> sanPhamMap = {
                'IdSanPham': widget.idSanPham,
                'TenSanPham': widget.tenSP,
                'Gia': widget.gia,
                'HinhAnh': widget.hinhAnh,
                'PhanTramGiam': phanTram,
              };
              _addToCart(sanPhamMap);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Thêm vào giỏ hàng",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isSelected ? Colors.pinkAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.pinkAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThongSo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Trọng lượng", widget.trongLuong),
        _buildInfoRow("Độ tuổi", widget.doTuoi),
        _buildInfoRow("Xuất xứ", widget.sanXuat),
        _buildInfoRow("Số lượng còn", widget.soLuong.toString()),
      ],
    );
  }

  Widget _buildMoTa() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.moTa.isNotEmpty
            ? widget.moTa
            : "Hiện chưa có mô tả cho sản phẩm này.",
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingForm() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.reviews, color: Colors.pinkAccent, size: 28),
              SizedBox(width: 8),
              Text(
                "Đánh giá sản phẩm",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Tên của bạn",
              prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent),
              filled: true,
              fillColor: const Color(0xFFFFF6F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email của bạn",
              prefixIcon: const Icon(Icons.email, color: Colors.pinkAccent),
              filled: true,
              fillColor: const Color(0xFFFFF6F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _userRating = index + 1.0;
                    });
                  },
                  icon: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Nhập đánh giá của bạn...",
              filled: true,
              fillColor: const Color(0xFFFFF6F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          Text(
            "Ngày đánh giá: ${_reviewDate.day}/${_reviewDate.month}/${_reviewDate.year}",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _submitReview,
              icon: const Icon(Icons.send),
              label: const Text("Gửi đánh giá"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
