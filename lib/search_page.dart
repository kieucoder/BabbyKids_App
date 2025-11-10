// import 'package:flutter/material.dart';
//
//
// class SearchPage extends StatefulWidget {
//   final List<Map<String, dynamic>> allProducts;
//
//   const SearchPage({required this.allProducts, super.key});
//
//   @override
//   _SearchPageState createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   TextEditingController _controller = TextEditingController();
//   List<Map<String, dynamic>> _searchResults = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchResults = [];
//   }
//
//   void _onSearchChanged(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         _searchResults = [];
//       });
//       return;
//     }
//
//     final results = widget.allProducts.where((product) {
//       final name = (product['TenSanPham'] ?? '').toString().toLowerCase();
//       final id = (product['IdSanPham'] ?? '').toString().toLowerCase();
//       return name.contains(query.toLowerCase()) || id.contains(query.toLowerCase());
//     }).toList();
//
//     setState(() {
//       _searchResults = results;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _controller,
//           decoration: const InputDecoration(
//             hintText: "Tìm sản phẩm...",
//             border: InputBorder.none,
//           ),
//           onChanged: _onSearchChanged,
//         ),
//       ),
//       body: _searchResults.isEmpty
//           ? Center(child: Text('Không tìm thấy sản phẩm'))
//           : ListView.builder(
//         itemCount: _searchResults.length,
//         itemBuilder: (context, index) {
//           final p = _searchResults[index];
//           return ListTile(
//             leading: p['HinhAnh'] != null
//                 ? Image.network(p['HinhAnh'], width: 50, height: 50)
//                 : null,
//             title: Text(p['TenSanPham'] ?? ''),
//             subtitle: Text(
//                 'Giá: ${p['GiaSauGiam'] ?? p['Gia']} đ - KM: ${p['PhanTramGiam'] ?? 0}%'),
//             trailing: IconButton(
//               icon: Icon(Icons.add_shopping_cart),
//               onPressed: () {
//                 // Thêm sản phẩm vào giỏ hàng
//                 _addToCart(p);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _addToCart(Map<String, dynamic> sanPham) async {
//     // copy code addToCart từ bạn vào đây
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> allProducts;
  final String idKhachHang;

  const SearchPage({
    required this.allProducts,
    required this.idKhachHang,
    super.key,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchResults = [];
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history_${widget.idKhachHang}') ?? [];
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history_${widget.idKhachHang}', _searchHistory);
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = widget.allProducts.where((product) {
      final name = (product['TenSanPham'] ?? '').toString().toLowerCase();
      final category = (product['TenDanhMuc'] ?? '').toString().toLowerCase();
      final brand = (product['ThuongHieu'] ?? '').toString().toLowerCase();
      final searchLower = query.toLowerCase();

      return name.contains(searchLower) ||
          category.contains(searchLower) ||
          brand.contains(searchLower);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    _controller.text = query;
    _onSearchChanged(query);

    // Thêm vào lịch sử tìm kiếm
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
      _saveSearchHistory();
    }
  }

  void _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history_${widget.idKhachHang}');
    setState(() {
      _searchHistory.clear();
    });
  }

  void _removeSearchItem(String item) {
    setState(() {
      _searchHistory.remove(item);
    });
    _saveSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.decimalPattern('vi_VN');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Ba mẹ muốn tìm gì...",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(Icons.search, color: Colors.pinkAccent),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _performSearch,
          ),
        ),
      ),
      body: _buildBody(formatCurrency),
    );
  }

  Widget _buildBody(NumberFormat formatCurrency) {
    if (_controller.text.isNotEmpty && _searchResults.isNotEmpty) {
      return _buildSearchResults(formatCurrency);
    } else if (_controller.text.isNotEmpty && _searchResults.isEmpty) {
      return _buildNoResults();
    } else {
      return _buildSearchHistory();
    }
  }

  Widget _buildSearchResults(NumberFormat formatCurrency) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        final String ten = product['TenSanPham'] ?? 'Sản phẩm';
        final String? hinhAnh = product['HinhAnh'];
        final double gia = _parsePrice(product['Gia']);
        final double giaSauGiam = _parsePrice(product['GiaSauGiam'] ?? product['Gia']);
        final double phanTramGiam = _parsePrice(product['PhanTramGiam'] ?? 0);

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: hinhAnh != null && hinhAnh.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(hinhAnh),
                  fit: BoxFit.cover,
                )
                    : null,
                color: Colors.grey.shade100,
              ),
              child: hinhAnh == null || hinhAnh.isEmpty
                  ? Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
            title: Text(
              ten,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  "${formatCurrency.format(giaSauGiam)} đ",
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (phanTramGiam > 0) ...[
                  SizedBox(height: 2),
                  Text(
                    "${formatCurrency.format(gia)} đ",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "-${phanTramGiam.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              // Điều hướng đến trang chi tiết sản phẩm
              // Navigator.push(...);
            },
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            "Không tìm thấy sản phẩm nào",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Hãy thử từ khóa tìm kiếm khác",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header "Lịch sử tìm kiếm" + nút "Xóa tất cả"
        if (_searchHistory.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lịch sử tìm kiếm",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _clearSearchHistory,
                  child: Text(
                    "Xóa tất cả",
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Danh sách lịch sử tìm kiếm
        if (_searchHistory.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final searchItem = _searchHistory[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(
                      Icons.history,
                      color: Colors.grey.shade500,
                    ),
                    title: Text(
                      searchItem,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () => _removeSearchItem(searchItem),
                    ),
                    onTap: () => _performSearch(searchItem),
                  ),
                );
              },
            ),
          ),

        // Trạng thái không có lịch sử
        if (_searchHistory.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Chưa có lịch sử tìm kiếm",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Các từ khóa bạn tìm kiếm sẽ hiển thị tại đây",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is int) return price.toDouble();
    if (price is double) return price;
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }
}