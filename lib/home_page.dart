import 'dart:async';
import 'dart:convert';
import 'package:appshopsua/account/account_page.dart';
import 'package:appshopsua/cart/cart_page.dart';
import 'package:appshopsua/chatbox/chat_screen.dart';
import 'package:appshopsua/detail_product.dart';
import 'package:appshopsua/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String idKhachHang;
  final Map<String, dynamic> userData;

  const HomePage({
    Key? key,
    required this.idKhachHang,
    required this.userData,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

final formatCurrency = NumberFormat("#,###", "vi_VN");

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  Timer? _timer;

  List<QueryDocumentSnapshot> _khuyenMaiDocs = [];
  List<QueryDocumentSnapshot> _danhMucDocs = [];
  List<QueryDocumentSnapshot> _sanPhamDocs = [];

  bool _loadingKhuyenMai = true;
  bool _loadingDanhMuc = true;
  bool _loadingSanPham = true;

  List<Map<String, dynamic>> _allProducts = [];

  final List<String> banners = [
    "assets/banner1.png",
    "assets/banner2.png",
    "assets/banner3.png",
    "assets/banner4.png",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentBannerIndex = (_currentBannerIndex + 1) % banners.length;
      });
    });
  }

  Future<void> _loadData() async {
    final firestore = FirebaseFirestore.instance;

    // Load danh mục
    firestore
        .collection("danhmuc")
        .where("TrangThai", isEqualTo: "Hoạt Động")
        .get()
        .then((snapshot) {
      setState(() {
        _danhMucDocs = snapshot.docs;
        _loadingDanhMuc = false;
      });
    });

    // Load khuyến mãi
    firestore.collection("khuyenmai").get().then((snapshot) {
      setState(() {
        _khuyenMaiDocs = snapshot.docs;
        _loadingKhuyenMai = false;
      });
    });

    // Load sản phẩm
    firestore.collection("sanpham").get().then((snapshot) {
      List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'IdSanPham': data['IdSanPham'] ?? doc.id,
          'TenSanPham': data['TenSanPham'] ?? '',
          'HinhAnh': data['HinhAnh'] ?? '',
          'Gia': (data['Gia'] ?? 0).toDouble(),
          'IdKhuyenMai': data['IdKhuyenMai'] ?? '',
          'PhanTramGiam': (data['PhanTramGiam'] ?? 0).toDouble(),
          'GiaSauGiam': (data['Gia'] ?? 0).toDouble() -
              ((data['Gia'] ?? 0) * ((data['PhanTramGiam'] ?? 0) / 100)),
        };
      }).toList();

      setState(() {
        _sanPhamDocs = snapshot.docs;
        _allProducts = products;
        _loadingSanPham = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<String, dynamic>? _getKhuyenMaiForProduct(String idKhuyenMai) {
    try {
      return _khuyenMaiDocs
          .firstWhere((km) => km.id == idKhuyenMai)
          .data() as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  double _calculateDiscountedPrice(double originalPrice, double discountPercent) {
    return discountPercent > 0
        ? originalPrice * (1 - discountPercent / 100)
        : originalPrice;
  }

  Future<void> _addToCart(Map<String, dynamic> sanPham) async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = 'cart_${widget.idKhachHang}';

    List<Map<String, dynamic>> cart = [];
    final existingData = prefs.getString(cartKey);
    if (existingData != null) {
      cart = List<Map<String, dynamic>>.from(json.decode(existingData));
    }

    final productId = sanPham['IdSanPham'] ?? '';
    int index = cart.indexWhere((item) => item['IdSanPham'] == productId);

    if (index != -1) {
      cart[index]['SoLuong'] = (cart[index]['SoLuong'] ?? 1) + 1;
    } else {
      cart.add({...sanPham, 'SoLuong': 1});
    }

    await prefs.setString(cartKey, json.encode(cart));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Đã thêm vào giỏ hàng tạm!"),
      backgroundColor: Colors.pinkAccent,
    ));
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.pinkAccent,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchPage(allProducts: _allProducts, idKhachHang: widget.idKhachHang,)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "Ba mẹ muốn tìm gì...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.notifications_none, color: Colors.pink),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildBanner(),
            _buildCategoryList(),
            _buildFlashSale(),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 160,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: Image.asset(
            banners[_currentBannerIndex],
            key: ValueKey(_currentBannerIndex),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: _loadingDanhMuc
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _danhMucDocs.length,
        itemBuilder: (context, index) {
          var doc = _danhMucDocs[index];
          String ten = doc["Ten"] ?? "Danh mục";
          String? hinhAnh = doc["HinhAnh"];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    image: (hinhAnh != null && hinhAnh.isNotEmpty)
                        ? DecorationImage(
                        image: NetworkImage(hinhAnh), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (hinhAnh == null || hinhAnh.isEmpty)
                      ? const Icon(Icons.category, color: Colors.pink)
                      : null,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 70,
                  child: Text(
                    ten,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlashSale() {
    return Container(
      color: Colors.pink.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("FLASH SALE ⚡",
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
          Text("Kết thúc trong: 06:59:05", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return _loadingSanPham
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.50, // Giữ chiều cao đồng nhất
      ),
      itemCount: _sanPhamDocs.length,
      itemBuilder: (context, index) {
        var sanPham = _sanPhamDocs[index];

        String ten = sanPham["TenSanPham"]?.toString() ?? "Sản phẩm";
        String? hinhAnh = sanPham["HinhAnh"]?.toString();
        double gia = 0;
        var giaRaw = sanPham["Gia"];
        if (giaRaw is int) gia = giaRaw.toDouble();
        else if (giaRaw is double) gia = giaRaw;
        else if (giaRaw is String) gia = double.tryParse(giaRaw) ?? 0;

        String? trongLuong = sanPham["TrongLuong"]?.toString();
        String? doTuoi = sanPham["DoTuoi"]?.toString();
        String? idKhuyenMai = sanPham["IdKhuyenMai"]?.toString();

        Map<String, dynamic>? km = idKhuyenMai != null && idKhuyenMai.isNotEmpty
            ? _getKhuyenMaiForProduct(idKhuyenMai)
            : null;

        double phanTramGiam = 0;
        var giamRaw = km?["PhanTramGiam"];
        if (giamRaw is int) phanTramGiam = giamRaw.toDouble();
        else if (giamRaw is double) phanTramGiam = giamRaw;
        else if (giamRaw is String) phanTramGiam = double.tryParse(giamRaw) ?? 0;

        double giaSauGiam = phanTramGiam > 0 ? gia * (1 - phanTramGiam / 100) : gia;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(
                  idKhachHang: widget.idKhachHang,
                  idSanPham: sanPham.id,
                  tenSP: sanPham['TenSanPham'],
                  gia: (sanPham['Gia'] as num).toDouble(),
                  hinhAnh: sanPham['HinhAnh'],
                  moTa: sanPham['MoTa'] ?? '',
                  doTuoi: sanPham['DoTuoi'] ?? '',
                  trongLuong: sanPham['TrongLuong'] ?? '',
                  sanXuat: sanPham['SanXuat'] ?? '',
                  soLuong: sanPham['SoLuong'] ?? 0,
                  idKhuyenMai: sanPham['IdKhuyenMai'],
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼 Ảnh sản phẩm
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: (hinhAnh != null && hinhAnh.isNotEmpty)
                        ? Image.network(hinhAnh, fit: BoxFit.cover)
                        : Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),

                // 🧾 Nội dung
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 💰 Giá & giảm giá cùng hàng
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "${formatCurrency.format(giaSauGiam)} đ",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (phanTramGiam > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "-${phanTramGiam.toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        if (phanTramGiam > 0)
                          Text(
                            "${formatCurrency.format(gia)} đ",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (phanTramGiam == 0)
                          const SizedBox(height: 18),

                        const SizedBox(height: 4),
                        Text(
                          ten,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (doTuoi != null && doTuoi.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  doTuoi,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            const SizedBox(width: 6),
                            if (trongLuong != null && trongLuong.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  trongLuong,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child:
                          OutlinedButton(
                            onPressed: () {
                              _addToCart({
                                'IdSanPham': sanPham['IdSanPham'],
                                'TenSanPham': sanPham['TenSanPham'],
                                'Gia': gia, // giá gốc
                                'HinhAnh': sanPham['HinhAnh'],

                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.pinkAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Chọn mua",
                              style: TextStyle(
                                color: Colors.pinkAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return CartPage(
            idKhachHang: widget.idKhachHang, userData: widget.userData);
      case 2:
        return ChatScreen();
      case 3:
        return AccountPage(
            idKhachHang: widget.idKhachHang, userData: widget.userData);
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Giỏ hàng"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Tài khoản"),
        ],
      ),
    );
  }
}
