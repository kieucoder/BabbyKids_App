import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? _userEmail;
  String? _userName;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  DateTime _reviewDate = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isFavorite = false;
  String? _userId;
  String? _idYeuThich;
  bool _loadingKhuyenMai = true;

  //thêm dữ liệu khuyến mãi
  List<QueryDocumentSnapshot> _khuyenMaiDocs = [];

  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _checkFavoriteStatus();
    _layThongTinNguoiDung();
    _loadReviews();
    _loadKhuyenMai();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      await _checkFavoriteStatus();
    }
  }

  //lấy dữ liệu khuyến mãi
  Future<void> _loadKhuyenMai() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("khuyenmai").get();
      if (!mounted) return;
      setState(() {
        _khuyenMaiDocs = snapshot.docs;
        _loadingKhuyenMai = false;
      });
    } catch (e) {
      print("❌ Lỗi khi tải khuyến mãi: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể tải khuyến mãi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  /// Tải danh sách đánh giá
  Future<void> _loadReviews() async {
    try {
      final snapshot = await _firestore
          .collection('danhgia')
          .where('IdSanPham', isEqualTo: widget.idSanPham)
          .orderBy('NgayDanhGia', descending: true)
          .get();
      setState(() {
        _reviews = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      debugPrint('🔥 Lỗi load reviews: $e');
    }
  }

  Future<void> _layThongTinNguoiDung() async {
    try {
      if (widget.idKhachHang.isEmpty) return;

      final doc = await FirebaseFirestore.instance
          .collection('khachhang')
          .doc(widget.idKhachHang)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _userName = data?['ten'] ?? '';
          _userEmail = data?['email'] ?? '';

          _nameController.text = _userName ?? '';
          _emailController.text = _userEmail ?? '';
        });
      }
    } catch (e) {
      print('🔥 Lỗi lấy thông tin khách hàng: $e');
    }
  }

  // ==================== YÊU THÍCH ====================
  Future<void> _checkFavoriteStatus() async {
    try {
      final snapshot = await _firestore
          .collection('yeuthich')
          .where('IdKhachHang', isEqualTo: widget.idKhachHang)
          .where('IdSanPham', isEqualTo: widget.idSanPham)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final trangThai = doc['TrangThai'] ?? false;

        setState(() {
          _isFavorite = trangThai;
          _idYeuThich = doc['IdYeuThich'];
        });
      } else {
        setState(() {
          _isFavorite = false;
          _idYeuThich = null;
        });
      }
    } catch (e) {
      debugPrint('_checkFavoriteStatus error: $e');
    }
  }

  Future<String> _generateYeuThichId() async {
    try {
      final query = await _firestore
          .collection('yeuthich')
          .orderBy('IdYeuThich', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final lastId = query.docs.first['IdYeuThich'] as String;
        final number = int.tryParse(lastId.substring(2)) ?? 0;
        return 'YT${(number + 1).toString().padLeft(2, '0')}';
      } else {
        return 'YT01';
      }
    } catch (e) {
      debugPrint('_generateYeuThichId error: $e');
      return 'YT${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}';
    }
  }

  //hàm tính giá sau khi giảm
  double _calculateDiscountedPrice(double originalPrice, double discountPercent) {
    if (discountPercent > 0) {
      return originalPrice * (1 - discountPercent / 100);
    }
    return originalPrice;
  }
  //hàm lập giả lấy thông tin khuyến mãi (nếu có)
  Map<String, dynamic>? _getKhuyenMaiForProduct(String idKhuyenMai) {
    try {
      return _khuyenMaiDocs.firstWhere(
            (km) => km.id == idKhuyenMai,
      ).data() as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }



  Future<void> _addToFavorites() async {
    try {
      final query = await _firestore
          .collection('yeuthich')
          .where('IdKhachHang', isEqualTo: widget.idKhachHang)
          .where('IdSanPham', isEqualTo: widget.idSanPham)
          .limit(1)
          .get();

      String idYeuThich;

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        idYeuThich = doc['IdYeuThich'];
        await _firestore.collection('yeuthich').doc(idYeuThich).update({'TrangThai': true});
      } else {
        idYeuThich = await _generateYeuThichId();
        await _firestore.collection('yeuthich').doc(idYeuThich).set({
          'IdYeuThich': idYeuThich,
          'IdKhachHang': widget.idKhachHang,
          'IdSanPham': widget.idSanPham,
          'TenSanPham': widget.tenSP,
          'Gia': widget.gia,
          'HinhAnh': widget.hinhAnh,
          'NgayThem': FieldValue.serverTimestamp(),
          'TrangThai': true,
        });
      }

      if (!mounted) return;
      setState(() {
        _isFavorite = true;
        _idYeuThich = idYeuThich;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm vào danh sách yêu thích'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
    } catch (e) {
      debugPrint('_addToFavorites error: $e');
    }
  }

  Future<void> _removeFromFavorites() async {
    try {
      if (_idYeuThich == null) return;

      await _firestore
          .collection('yeuthich')
          .doc(_idYeuThich)
          .update({'TrangThai': false});

      if (!mounted) return;
      setState(() {
        _isFavorite = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khỏi danh sách yêu thích'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      debugPrint('_removeFromFavorites error: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _removeFromFavorites();
    } else {
      await _addToFavorites();
    }
  }

  // ==================== GIỎ HÀNG ====================
  Future<void> _addToCart(Map<String, dynamic> sanPham) async {
    try {
      final userId = widget.idKhachHang;

      // Kiểm tra đăng nhập
      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng đăng nhập để mua hàng"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Lấy SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cartKey = 'cart_$userId'; // Mỗi khách hàng có 1 giỏ riêng

      // Lấy giỏ hàng hiện tại (nếu có)
      List<Map<String, dynamic>> cart = [];
      final existingData = prefs.getString(cartKey);
      if (existingData != null) {
        cart = List<Map<String, dynamic>>.from(json.decode(existingData));
      }

      // Lấy thông tin sản phẩm
      final productId = sanPham['IdSanPham'] ?? sanPham['id'] ?? '';
      if (productId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy ID sản phẩm!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Xử lý khuyến mãi (nếu có)
      String? idKhuyenMai = sanPham["IdKhuyenMai"]?.toString();
      Map<String, dynamic>? km = idKhuyenMai != null && idKhuyenMai.isNotEmpty
          ? _getKhuyenMaiForProduct(idKhuyenMai)
          : null;

      double phanTramGiam = 0;
      var giamRaw = km?["PhanTramGiam"];
      if (giamRaw is int) phanTramGiam = giamRaw.toDouble();
      else if (giamRaw is double) phanTramGiam = giamRaw;
      else if (giamRaw is String) phanTramGiam = double.tryParse(giamRaw) ?? 0;

      double giaGoc = 0;
      var giaRaw = sanPham["Gia"];
      if (giaRaw is int) giaGoc = giaRaw.toDouble();
      else if (giaRaw is double) giaGoc = giaRaw;
      else if (giaRaw is String) giaGoc = double.tryParse(giaRaw) ?? 0;

      // ✅ Tính giá sau giảm
      double giaSauGiam = _calculateDiscountedPrice(giaGoc, phanTramGiam);

      // ✅ Kiểm tra xem sản phẩm đã tồn tại trong giỏ chưa
      int index = cart.indexWhere((item) => item['IdSanPham'] == productId);

      if (index != -1) {
        // Nếu có rồi -> tăng số lượng
        cart[index]['SoLuong'] = (cart[index]['SoLuong'] ?? 1) + 1;
      } else {
        // Nếu chưa có -> thêm mới
        cart.add({
          'IdSanPham': productId,
          'TenSanPham': sanPham['TenSanPham'] ?? '',
          'HinhAnh': sanPham['HinhAnh'] ?? '',
          'GiaGoc': giaGoc,
          'GiaSauGiam': giaSauGiam,
          'PhanTramGiam': phanTramGiam,
          'IdKhuyenMai': idKhuyenMai,
          'SoLuong': 1,
        });
      }

      // ✅ Lưu giỏ hàng mới vào SharedPreferences
      await prefs.setString(cartKey, json.encode(cart));

      // ✅ Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã thêm vào giỏ hàng tạm!"),
          backgroundColor: Colors.pinkAccent,
        ),
      );
    } catch (e) {
      print("❌ Lỗi khi thêm vào giỏ hàng: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi thêm sản phẩm vào giỏ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  //kiêểm tra đơn hàng mua chua
  Future<bool> _kiemTraDonHangDaGiao() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('donhang')
          .where('IdKhachHang', isEqualTo: widget.idKhachHang)
          .where('TrangThai', isEqualTo: 'Đã giao')
          .get();

      for (var doc in query.docs) {
        final data = doc.data();
        final sanPhamList = data['SanPham'] as List<dynamic>?;

        if (sanPhamList != null) {
          final daMua = sanPhamList.any(
                (sp) => sp['IdSanPham'] == widget.idSanPham,
          );
          if (daMua) return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi kiểm tra đơn hàng: $e");
      return false;
    }
  }


  // ==================== ĐÁNH GIÁ ====================
  Future<void> _submitReview() async {
    try {
      final name = _userName ?? _nameController.text.trim();
      final email = _userEmail ?? _emailController.text.trim();
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

      await _firestore.collection('danhgia').add({
        'IdKhachHang': widget.idKhachHang,
        'IdSanPham': widget.idSanPham,
        'TenNguoiDanhGia': name,
        'Email': email,
        'SoSao': _userRating,
        'BinhLuan': comment,
        'NgayDanhGia': Timestamp.now(),
      });

      // Hiển thị ngay trong danh sách đánh giá
      setState(() {
        _reviews.insert(0, {
          'TenNguoiDanhGia': name,
          'Email': email,
          'SoSao': _userRating,
          'BinhLuan': comment,
          'NgayDanhGia': Timestamp.now(),
        });
        _userRating = 0;
        _commentController.clear();
        _reviewDate = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đánh giá thành công!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi gửi đánh giá: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== GIAO DIỆN ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.tenSP, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Ảnh sản phẩm + icon yêu thích
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      widget.hinhAnh,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.error_outline, size: 50)),
                        );
                      },
                    ),
                  ),
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

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${formatCurrency.format(widget.gia)}đ",
                      style: const TextStyle(fontSize: 22, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(widget.tenSP, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TAB thông số
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedTab == 0 ? _buildThongSo() : _buildMoTa(),
            ),

            const SizedBox(height: 30),

            // Form đánh giá
            _buildRatingForm(),

            const SizedBox(height: 20),

            // Danh sách đánh giá
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildReviewList(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> sanPhamMap = {
                      'IdSanPham': widget.idSanPham,
                      'TenSanPham': widget.tenSP,
                      'Gia': widget.gia,
                      'HinhAnh': widget.hinhAnh,
                    };
                    await _addToCart(sanPhamMap);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Thêm vào giỏ hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 45,
          decoration: BoxDecoration(
            color: isSelected ? Colors.pinkAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(text,
              style: TextStyle(color: isSelected ? Colors.white : Colors.pinkAccent, fontWeight: FontWeight.bold)),
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
      ),
      child: Text(widget.moTa.isNotEmpty ? widget.moTa : "Chưa có mô tả sản phẩm."),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // Widget _buildRatingForm() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text("Đánh giá sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: List.generate(
  //             5,
  //                 (index) => IconButton(
  //               onPressed: () => setState(() => _userRating = index + 1.0),
  //               icon: Icon(Icons.star,
  //                   color: _userRating >= index + 1 ? Colors.orange : Colors.grey[300], size: 28),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         TextField(
  //           controller: _commentController,
  //           maxLines: 3,
  //           decoration: const InputDecoration(
  //             labelText: "Nhập bình luận",
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton(
  //             onPressed: _submitReview,
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.pinkAccent,
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //             ),
  //             child: const Text("Gửi đánh giá"),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildReviewList() {
  //   if (_reviews.isEmpty) {
  //     return const Center(
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(vertical: 16),
  //         child: Text("Chưa có đánh giá nào."),
  //       ),
  //     );
  //   }
  //
  //   return ListView.builder(
  //     physics: const NeverScrollableScrollPhysics(),
  //     shrinkWrap: true,
  //     itemCount: _reviews.length,
  //     itemBuilder: (context, index) {
  //       final review = _reviews[index];
  //       final rating = review['SoSao'] ?? 0;
  //       final comment = review['BinhLuan'] ?? '';
  //       final name = review['TenNguoiDanhGia'] ?? '';
  //       final timestamp = review['NgayDanhGia'] as Timestamp?;
  //       final date = timestamp != null ? timestamp.toDate() : DateTime.now();
  //
  //       return Card(
  //         margin: const EdgeInsets.symmetric(vertical: 8),
  //         child: ListTile(
  //           title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
  //           subtitle: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: List.generate(5, (i) => Icon(Icons.star,
  //                     color: i < rating ? Colors.orange : Colors.grey[300], size: 16)),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(comment),
  //               const SizedBox(height: 4),
  //               Text(DateFormat('dd/MM/yyyy').format(date),
  //                   style: const TextStyle(fontSize: 12, color: Colors.grey)),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildRatingForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Đánh giá sản phẩm",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => GestureDetector(
                  onTap: () => setState(() => _userRating = index + 1.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star_rounded,
                      size: 36,
                      color: _userRating >= index + 1
                          ? Colors.amber
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Nhập bình luận của bạn",
              labelStyle: TextStyle(color: Colors.grey.shade600),
              floatingLabelStyle: const TextStyle(color: Colors.pinkAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.deepPurple.withOpacity(0.3),
              ),
              child: const Text(
                "Gửi đánh giá",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    if (_reviews.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.reviews_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              "Chưa có đánh giá nào",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        final rating = review['SoSao'] ?? 0;
        final comment = review['BinhLuan'] ?? '';
        final name = review['TenNguoiDanhGia'] ?? '';
        final timestamp = review['NgayDanhGia'] as Timestamp?;
        final date = timestamp != null ? timestamp.toDate() : DateTime.now();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: i < rating ? Colors.amber : Colors.grey.shade300,
                      )),
                      const SizedBox(width: 8),
                      Text(
                        '$rating.0',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    comment,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
