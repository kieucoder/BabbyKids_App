
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_page.dart';

class CheckoutPage extends StatefulWidget {
  final String idKhachHang;
  final Map<String, dynamic> userData;
  const CheckoutPage({super.key, required this.idKhachHang, required this.userData});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _phuongThucThanhToan = "COD";
  final TextEditingController _ghiChuController = TextEditingController();
  bool _isPlacingOrder = false;
  List<Map<String, dynamic>> _cartItems = [];
  bool _loading = true;
  double _totalPrice = 0.0;
  bool _deliveryToHome = true;
  double _savedAmount = 0.0;

  Map<String, dynamic> _customerInfo = {};
  bool _loadingCustomer = true;
  String _customerError = '';

  // Map để lưu thông tin khuyến mãi
  Map<String, dynamic> _khuyenMaiMap = {};
  final NumberFormat formatCurrency = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    super.initState();
    _loadCustomerInfo();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // 🔹 Lấy dữ liệu khuyến mãi (nếu cần)
      final kmSnap = await FirebaseFirestore.instance.collection('khuyenmai').get();
      for (var doc in kmSnap.docs) {
        _khuyenMaiMap[doc.id] = doc.data();
      }

      // 🔹 Lấy giỏ hàng tạm của khách hàng từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cartKey = 'cart_${widget.idKhachHang}';
      final cartData = prefs.getString(cartKey);

      List<Map<String, dynamic>> temp = [];

      if (cartData != null) {
        final List<dynamic> decoded = json.decode(cartData);
        temp = List<Map<String, dynamic>>.from(decoded);

        // 🔹 Đồng bộ thông tin sản phẩm mới nhất (tên, hình ảnh, giá)
        for (var i = 0; i < temp.length; i++) {
          var item = temp[i];
          String idSP = item['IdSanPham'] ?? '';
          if (idSP.isEmpty) continue;

          var spSnap = await FirebaseFirestore.instance.collection('sanpham').doc(idSP).get();
          if (!spSnap.exists) continue;

          var sp = spSnap.data()!;
          String ten = sp['TenSanPham'] ?? item['TenSanPham'] ?? "Sản phẩm";
          String hinh = sp['HinhAnh'] ?? item['HinhAnh'] ?? "";
          double giaGoc = (sp['Gia'] as num?)?.toDouble() ?? (item['GiaGoc'] ?? 0);

          // 🔹 Lấy phần trăm giảm nếu có
          String? idKM;
          if (sp['IdKhuyenMai'] is String) {
            idKM = sp['IdKhuyenMai'];
          } else if (sp['IdKhuyenMai'] is DocumentReference) {
            idKM = (sp['IdKhuyenMai'] as DocumentReference).id;
          }

          double phanTram = 0;
          if (idKM != null && _khuyenMaiMap.containsKey(idKM)) {
            var km = _khuyenMaiMap[idKM];
            var raw = km?['PhanTramGiam'];
            if (raw is int) phanTram = raw.toDouble();
            else if (raw is double) phanTram = raw;
            else if (raw is String) phanTram = double.tryParse(raw) ?? 0;
          }

          double giaSauGiam = _calculateDiscountedPrice(giaGoc, phanTram);

          // 🔹 Cập nhật item trong danh sách
          temp[i] = {
            ...item,
            'TenSanPham': ten,
            'HinhAnh': hinh,
            'GiaGoc': giaGoc,
            'Gia': giaSauGiam,
            'PhanTramGiam': phanTram,
          };
        }
      }

      setState(() {
        _cartItems = temp;
        _calculateTotalPrice();
        _loading = false;
      });
    } catch (e) {
      print("❌ Lỗi khi tải giỏ hàng: $e");
      setState(() => _loading = false);
    }
  }

  double _calculateDiscountedPrice(double giaGoc, double phanTramGiam) {
    if (phanTramGiam <= 0) return giaGoc;
    double giaSauGiam = giaGoc - (giaGoc * phanTramGiam / 100);
    return double.parse(giaSauGiam.toStringAsFixed(0));
  }

  // Cập nhật số lượng trong session (dùng IdSanPham)
  Future<void> _updateQuantity(String idSanPham, int soLuong) async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'cart_${widget.idKhachHang}';
    final raw = prefs.getString(cartKey);
    if (raw == null) return;

    List<Map<String, dynamic>> cart = List<Map<String, dynamic>>.from(json.decode(raw));
    final idx = cart.indexWhere((it) => it['IdSanPham'] == idSanPham);
    if (idx == -1) return;

    if (soLuong <= 0) {
      cart.removeAt(idx);
    } else {
      cart[idx]['SoLuong'] = soLuong;
    }

    await prefs.setString(cartKey, json.encode(cart));
    setState(() {
      _cartItems = cart;
      _calculateTotalPrice();
    });
  }

  // Xóa 1 sản phẩm trong session (dùng IdSanPham)
  Future<void> _removeItem(String idSanPham) async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'cart_${widget.idKhachHang}';
    final raw = prefs.getString(cartKey);
    if (raw == null) return;

    List<Map<String, dynamic>> cart = List<Map<String, dynamic>>.from(json.decode(raw));
    cart.removeWhere((it) => it['IdSanPham'] == idSanPham);

    await prefs.setString(cartKey, json.encode(cart));
    setState(() {
      _cartItems = cart;
      _calculateTotalPrice();
    });
  }

  // Xóa tất cả (session)
  Future<void> _removeAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'cart_${widget.idKhachHang}';
    await prefs.remove(cartKey);
    setState(() {
      _cartItems = [];
      _calculateTotalPrice();
    });
  }


  double _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      double giaSauGiam = (item['Gia'] as num?)?.toDouble() ?? 0; // Sử dụng giá sau giảm đã được tính
      int soLuong = (item['SoLuong'] as int?) ?? 1;
      total += giaSauGiam * soLuong;
    }
    return total;
  }
  void _calculateTotalPrice() {
    _totalPrice = 0.0;
    _savedAmount = 0.0;

    for (var item in _cartItems) {
      double gia = (item['Gia'] as num?)?.toDouble() ?? 0;
      double giaGoc = (item['GiaGoc'] as num?)?.toDouble() ?? gia;
      double phanTram = (item['PhanTramGiam'] as num?)?.toDouble() ?? 0;
      double giaSauGiam = phanTram > 0 ? giaGoc * (1 - phanTram / 100) : gia;
      int sl = (item['SoLuong'] as int?) ?? 1;

      _totalPrice += giaSauGiam * sl;
      _savedAmount += (giaGoc - giaSauGiam) * sl;
    }
  }

  Future<void> _loadCustomerInfo() async {
    setState(() {
      _loadingCustomer = true;
      _customerError = '';
    });

    final userId = widget.idKhachHang;

    if (userId.isEmpty) {
      setState(() {
        _loadingCustomer = false;
        _customerError = 'Vui lòng đăng nhập để xem thông tin';
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('khachhang')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          _customerInfo = doc.data() ?? {};
        });
      } else {
        setState(() {
          _customerError = 'Không tìm thấy thông tin khách hàng';
        });
      }
    } catch (e) {
      setState(() {
        _customerError = 'Lỗi khi tải thông tin khách hàng';
      });
    } finally {
      setState(() => _loadingCustomer = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng trống!')),
      );
      return;
    }

    if (_customerInfo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cập nhật thông tin nhận hàng!')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      // 🔹 Lấy danh sách đơn hàng hiện có để tạo mã tự tăng
      final donHangSnapshot = await FirebaseFirestore.instance.collection('donhang').get();
      final soLuongDonHang = donHangSnapshot.size;
      final maDonHang = 'DH${(soLuongDonHang + 1).toString().padLeft(4, '0')}';

      // 🔹 Lấy thông tin người dùng từ customerInfo (thông tin mới nhất từ Firestore)
      final tenNguoiDat = _customerInfo['ten'] ?? 'Khách hàng';
      final sdt = _customerInfo['sdt'] ?? '';
      final diaChi = _customerInfo['diachi'] ?? '';
      final ghiChu = _ghiChuController.text.trim();
      final tongTien = _calculateTotal();

      // 🔹 Chuẩn bị dữ liệu đơn hàng
      final order = {
        'MaDonHang': maDonHang,
        'IdKhachHang': widget.idKhachHang,
        'TenNguoiDat': tenNguoiDat,
        'SDT': sdt,
        'DiaChi': diaChi,
        'GhiChu': ghiChu,
        'CachThanhToan': _phuongThucThanhToan,
        'TongTien': tongTien,
        'TrangThai': 'Chờ xác nhận',
        'NgayTao': Timestamp.now(),
        'NgayCapNhat': Timestamp.now(),
        'NgayGiao': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
      };

      // 🔹 Lưu đơn hàng chính
      await FirebaseFirestore.instance
          .collection('donhang')
          .doc(maDonHang)
          .set(order);

      // 🔹 Lưu chi tiết từng sản phẩm - SỬA LẠI PHẦN NÀY
      int index = 1;
      for (var item in _cartItems) {
        final maCT = 'CT${maDonHang}_${index.toString().padLeft(2, '0')}';
        index++;

        // 🔹 Lấy thông tin giá CHÍNH XÁC từ item (đã được tính toán trong _loadData)
        double giaGoc = (item['GiaGoc'] as num?)?.toDouble() ?? 0;
        double giaSauGiam = (item['Gia'] as num?)?.toDouble() ?? giaGoc; // Đây là giá sau giảm thực tế
        double phanTram = (item['PhanTramGiam'] as num?)?.toDouble() ?? 0;
        int soLuong = (item['SoLuong'] as int?) ?? 1;

        // 🔹 Tính thành tiền CHÍNH XÁC từ giá sau giảm
        double thanhTien = giaSauGiam * soLuong;

        await FirebaseFirestore.instance
            .collection('chitietdonhang')
            .doc(maCT)
            .set({
          'MaChiTiet': maCT,
          'MaDonHang': maDonHang,
          'IdSanPham': item['IdSanPham'],
          'TenSanPham': item['TenSanPham'],
          'GiaGoc': giaGoc,           // Giá gốc
          'GiaSauGiam': giaSauGiam,   // Giá sau giảm thực tế
          'PhanTramGiam': phanTram,   // Phần trăm giảm
          'SoLuong': soLuong,
          'ThanhTien': thanhTien,     // Thành tiền = giá sau giảm * số lượng
        });
      }

      // 🔹 Xóa giỏ hàng trong local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart_${widget.idKhachHang}');

      // 🔹 Thông báo thành công và điều hướng
      _showOrderSuccessDialog(maDonHang, tongTien);

    } catch (e) {
      print("❌ Lỗi khi đặt hàng: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đặt hàng: $e')),
      );
    } finally {
      setState(() => _isPlacingOrder = false);
    }
  }
  void _showOrderSuccessDialog(String maDonHang, double tongTien) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Đặt hàng thành công!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã đơn hàng: $maDonHang'),
              Text('Tổng tiền: ${_formatPrice(tongTien)}'),
              const SizedBox(height: 10),
              const Text('Cảm ơn bạn đã mua hàng! Đơn hàng sẽ được xử lý trong thời gian sớm nhất.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Quay về trang chủ
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      idKhachHang: widget.idKhachHang,
                      userData: widget.userData,
                    ),
                  ),
                      (route) => false,
                );
              },
              child: const Text('Về trang chủ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Có thể điều hướng đến trang chi tiết đơn hàng ở đây
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: const Text('Xem đơn hàng', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatPrice(double price) {
    return '${formatCurrency.format(price)} đ';
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Danh sách sản phẩm (0)",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SvgPicture.network(
            "https://cdnv2.tgdd.vn/webmwg/production-fe/avakids-v2/_next/public/static/images/empty-cart-v2.svg",
            width: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            "Giỏ hàng của bạn đang trống",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          const Text(
            "Mua sắm ngay để tận hưởng ưu đãi đang có từ Babby Kids.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Vào trang mua sắm",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    if (_loadingCustomer) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
          ),
        ),
      );
    }

    if (_customerInfo.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B9D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: Color(0xFFFF6B9D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Thông tin nhận hàng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _editCustomerInfo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Thêm địa chỉ",
                      style: TextStyle(
                        color: Color(0xFFFF6B9D),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Bạn chưa có thông tin nhận hàng",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final ten = _customerInfo['ten'] ?? 'Chưa có tên';
    final sdt = _customerInfo['sdt'] ?? 'Chưa có số điện thoại';
    final diachi = _customerInfo['diachi'] ?? 'Chưa có địa chỉ';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: Color(0xFFFF6B9D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Thông tin nhận hàng",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _editCustomerInfo,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Thay đổi",
                    style: TextStyle(
                      color: Color(0xFFFF6B9D),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "(Anh) $ten • $sdt",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    diachi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editCustomerInfo() {
    // TODO: Implement edit customer info
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chức năng đang phát triển'),
        content: const Text('Tính năng chỉnh sửa thông tin khách hàng đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item, int index) {
    double gia = (item['Gia'] as num?)?.toDouble() ?? 0;
    double giaGoc = (item['GiaGoc'] as num?)?.toDouble() ?? 0;
    double giaSauGiam = (item['Gia'] as num?)?.toDouble() ?? giaGoc; // Đây là giá sau giảm thực tế
    double phanTram = (item['PhanTramGiam'] as num?)?.toDouble() ?? 0;
    int soLuong = (item['SoLuong'] as int?) ?? 1;

    // 🔹 Tính tiết kiệm chính xác
    double itemSavedAmount = (giaGoc - giaSauGiam) * soLuong;
    bool hasDiscount = phanTram > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B9D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_rounded,
                                size: 16,
                                color: Color(0xFFFF6B9D),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Danh sách sản phẩm (${_cartItems.length})",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _removeAllItems,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.delete_outline_rounded, size: 12, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(
                                "Xoá tất cả",
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh sản phẩm
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: item['HinhAnh'] != null && item['HinhAnh'].isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(item['HinhAnh']),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: item['HinhAnh'] == null || item['HinhAnh'].isEmpty
                      ? const Icon(Icons.shopping_bag, color: Colors.grey, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),

                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên sản phẩm
                      Text(
                        item['TenSanPham'] ?? 'Sản phẩm',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Hiển thị giá
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _formatPrice(giaSauGiam),
                                  style: const TextStyle(
                                    color: Colors.pinkAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (hasDiscount)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    "-${phanTram.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          if (hasDiscount)
                            Row(
                              children: [
                                Text(
                                  _formatPrice(giaGoc),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.orangeAccent, width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department,
                                        color: Colors.orangeAccent,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 2),
                                      const Text(
                                        "Flash Sale",
                                        style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Thông báo tiết kiệm
                      if (hasDiscount && itemSavedAmount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Tiết kiệm ${_formatPrice(itemSavedAmount)}",
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFFFF6B9D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Nút điều chỉnh số lượng
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nút giảm
                          InkWell(
                            onTap: soLuong > 1 ? () => _updateQuantity(item['IdSanPham'], soLuong - 1) : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: soLuong > 1 ? const Color(0xFFFF6B9D) : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove, size: 22, color: Colors.white),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Số lượng
                          Text(
                            soLuong.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Nút tăng
                          InkWell(
                            onTap: () => _updateQuantity(item['IdSanPham'], soLuong + 1),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B9D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 22, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () => _removeItem(item['IdSanPham']),
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete, size: 22, color: Colors.grey),
                          const SizedBox(width: 2),
                          const Text(
                            "Xóa",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Phương thức thanh toán",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          RadioListTile(
            title: const Text('Thanh toán khi nhận hàng (COD)'),
            value: "COD",
            groupValue: _phuongThucThanhToan,
            onChanged: (value) => setState(() => _phuongThucThanhToan = value!),
            activeColor: const Color(0xFFFF6B9D),
          ),
          RadioListTile(
            title: const Text('Thanh toán qua VNPay'),
            value: "VnPay",
            groupValue: _phuongThucThanhToan,
            onChanged: (value) => setState(() => _phuongThucThanhToan = value!),
            activeColor: const Color(0xFFFF6B9D),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ghi chú đơn hàng",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ghiChuController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Nhập ghi chú cho đơn hàng (nếu có)...",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_savedAmount > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF4CAF50).withOpacity(0.1),
                      const Color(0xFF8BC34A).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.savings_rounded, color: Colors.green[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bạn đã tiết kiệm được ${_formatPrice(_savedAmount)}",
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Tiếp tục mua sắm để tiết kiệm thêm nhé!",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(_calculateTotal()),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B9D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _cartItems.isEmpty || _isPlacingOrder ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: const Color(0xFFFF6B9D).withOpacity(0.3),
                    ),
                    child: _isPlacingOrder
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'ĐẶT HÀNG',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thanh toán",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildDeliveryInfo(),
                  _buildPaymentMethod(),
                  _buildNoteSection(),
                  ..._cartItems.asMap().entries.map(
                        (entry) => _buildProductItem(entry.value, entry.key),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }
}