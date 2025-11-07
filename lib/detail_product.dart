import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final String idKhachHang;
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
    required this.idKhachHang,
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
  bool _isFavorite = false;
  String? _userId;
  String? _idYeuThich;      // ✅ thêm dòng này

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _checkFavoriteStatus();     // kiểm tra khi mở trang chi tiết về yêu thích sản phẩm
  }

  // 🚨 LẤY USER ID TỪ FIREBASE AUTH
  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      await _checkFavoriteStatus();
    }
  }


  // 1) Kiểm tra trạng thái yêu thích
  Future<void> _checkFavoriteStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('yeuthich')
          .where('idKhachHang', isEqualTo: widget.idKhachHang)
          .where('idSanPham', isEqualTo: widget.idSanPham)
          .limit(1)
          .get();

      if (!mounted) return; // <-- tránh setState khi widget đã rời
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _isFavorite = true;
          _idYeuThich = snapshot.docs.first['idYeuThich'];
        });
      } else {
        setState(() {
          _isFavorite = false;
          _idYeuThich = null;
        });
      }
    } catch (e, st) {
      debugPrint('❌ _checkFavoriteStatus error: $e\n$st');
    }
  }

// 2) Sinh idYeuThich dạng YT01, YT02
  Future<String> _generateYeuThichId() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('yeuthich')
          .orderBy('idYeuThich', descending: true) // dùng cùng tên field
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final lastId = query.docs.first['idYeuThich'] as String;
        final number = int.tryParse(lastId.substring(2)) ?? 0;
        return 'YT${(number + 1).toString().padLeft(2, '0')}';
      } else {
        return 'YT01';
      }
    } catch (e, st) {
      debugPrint('❌ _generateYeuThichId error: $e\n$st');
      // fallback an toàn
      return DateTime.now().millisecondsSinceEpoch.toString().replaceAll(RegExp(r'\D'), '').substring(0, 6);
    }
  }

// 3) Thêm vào yêu thích (có mounted check trước setState)
  Future<void> _addToFavorites() async {
    try {
      final idYeuThich = await _generateYeuThichId();

      double giaHienTai = widget.gia;
      if (widget.idKhuyenMai != null && widget.idKhuyenMai!.isNotEmpty) {
        final kmDoc = await FirebaseFirestore.instance
            .collection('khuyenmai')
            .doc(widget.idKhuyenMai)
            .get();

        if (kmDoc.exists && kmDoc.data()?['TrangThai'] == 'Đang hoạt động') {
          final phanTram = (kmDoc.data()?['PhanTramGiam'] as num?)?.toDouble() ?? 0;
          giaHienTai = widget.gia * (1 - phanTram / 100);
        }
      }

      await FirebaseFirestore.instance.collection('yeuthich').doc(idYeuThich).set({
        'IdYeuThich': idYeuThich,
        'IdKhachHang': widget.idKhachHang,
        'IdSanPham': widget.idSanPham,
        'TenSanPham': widget.tenSP,
        'Gia': giaHienTai,
        'GiaGoc': widget.gia,
        'HinhAnh': widget.hinhAnh,
        'NgayThem': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _isFavorite = true;
        _idYeuThich = idYeuThich;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm vào danh sách yêu thích '), backgroundColor: Colors.pinkAccent),
      );
    } catch (e, st) {
      debugPrint('❌ _addToFavorites error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi thêm yêu thích: $e')));
    }
  }

// 4) Xóa khỏi yêu thích (có mounted check)
  Future<void> _removeFromFavorites() async {
    try {
      if (_idYeuThich == null) return;

      await FirebaseFirestore.instance.collection('yeuthich').doc(_idYeuThich).delete();

      if (!mounted) return;
      setState(() {
        _isFavorite = false;
        _idYeuThich = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa khỏi danh sách yêu thích'), backgroundColor: Colors.grey),
      );
    } catch (e, st) {
      debugPrint('❌ _removeFromFavorites error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa yêu thích: $e')));
    }
  }

// 5) Toggle
  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _removeFromFavorites();
    } else {
      await _addToFavorites();
    }
  }



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


  Future<void> _addToCart(Map<String, dynamic> sanPham) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng đăng nhập để mua hàng"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final userId = user.uid;

      final gioHangRef = FirebaseFirestore.instance
          .collection('chitietdonhang')
          .doc(userId)
          .collection('sanpham');

      final productId = sanPham['IdSanPham'] ?? '';
      if (productId.isEmpty) return;

      final existing = await gioHangRef
          .where('IdSanPham', isEqualTo: productId)
          .limit(1)
          .get();

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
        SnackBar(
          content: Text("Lỗi khi thêm sản phẩm vào giỏ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ... (CÁC PHƯƠNG THỨC KHÁC GIỮ NGUYÊN: _canReview, _submitReview, v.v.)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.tenSP,
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<double>(
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
                // ẢNH SẢN PHẨM VÀ ICON YÊU THÍCH
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      // Ảnh sản phẩm
                      Positioned.fill(
                        child: Image.network(
                          widget.hinhAnh,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.grey, size: 50),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Không thể tải ảnh',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Icon yêu thích
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: _toggleFavorite,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isFavorite ? Colors.pinkAccent : Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.white : Colors.pinkAccent,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Nếu có giảm giá thì hiển thị giá gốc + badge
                      if (phanTram > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${formatCurrency.format(widget.gia)}đ",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "-${phanTram.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      // ✅ Dòng giá chính, luôn căn trái
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${formatCurrency.format(giaSauGiam)}đ",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // ✅ Tên sản phẩm
                      Text(
                        widget.tenSP,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // TAB THÔNG TIN
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

                // NỘI DUNG TAB
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _selectedTab == 0 ? _buildThongSo() : _buildMoTa(),
                ),
                const SizedBox(height: 30),

                // FORM ĐÁNH GIÁ
                _buildRatingForm(),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [

              Expanded(
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

                    await _addToCart(sanPhamMap);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Thêm vào giỏ hàng",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (CÁC WIDGET PHỤ KHÁC GIỮ NGUYÊN)
  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 45,
          decoration: BoxDecoration(
            color: isSelected ? Colors.pinkAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.pinkAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
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
        _buildInfoRow("Số lượng còn", "${widget.soLuong} sản phẩm"),
      ],
    );
  }

  Widget _buildMoTa() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.1)),
      ),
      child: Text(
        widget.moTa.isNotEmpty
            ? widget.moTa
            : "Hiện chưa có mô tả cho sản phẩm này.",
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingForm() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.reviews, color: Colors.pinkAccent, size: 28),
              SizedBox(width: 10),
              Text(
                "Đánh giá sản phẩm",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
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
                    size: 40,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 15),
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
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Text(
            "Ngày đánh giá: ${DateFormat('dd/MM/yyyy').format(_reviewDate)}",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _submitReview,
              icon: const Icon(Icons.send, size: 20),
              label: const Text(
                "Gửi đánh giá",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KIỂM TRA CÓ THỂ ĐÁNH GIÁ KHÔNG
  Future<bool> _canReview() async {
    try {
      if (_userId == null) return false;

      final ratingQuery = await _firestore
          .collection('danhgia')
          .where('IdKhachHang', isEqualTo: _userId)
          .where('IdSanPham', isEqualTo: widget.idSanPham)
          .limit(1)
          .get();
      if (ratingQuery.docs.isNotEmpty) return false;

      final ordersQuery = await _firestore
          .collection('donhang')
          .where('IdKhachHang', isEqualTo: _userId)
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

  // GỬI ĐÁNH GIÁ
  Future<void> _submitReview() async {
    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final comment = _commentController.text.trim();
      if (name.isEmpty || email.isEmpty || comment.isEmpty || _userRating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng nhập đủ thông tin!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final canReview = await _canReview();
      if (!canReview) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không đủ điều kiện đánh giá!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await _firestore.collection('danhgia').add({
        'IdKhachHang': user.uid,
        'IdSanPham': widget.idSanPham,
        'TenNguoiDanhGia': name,
        'Email': email,
        'SoSao': _userRating,
        'BinhLuan': comment,
        'NgayDanhGia': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đánh giá thành công!"),
          backgroundColor: Colors.green,
        ),
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
        SnackBar(
          content: Text("Lỗi gửi đánh giá: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}