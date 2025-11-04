import 'package:appshopsua/admin/khuyenmai/add_promotion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ListKhuyenMaiPage extends StatefulWidget {
  const ListKhuyenMaiPage({Key? key}) : super(key: key);

  @override
  State<ListKhuyenMaiPage> createState() => _ListKhuyenMaiPageState();
}

class _ListKhuyenMaiPageState extends State<ListKhuyenMaiPage> {
  final Color mainBlue = const Color(0xFF007BFF);
  final Color lightBlue = const Color(0xFFe6f2ff);

  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _khuyenMaiList = [];
  List<Map<String, dynamic>> _filteredKhuyenMaiList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKhuyenMai();
    _searchController.addListener(_filterKhuyenMai);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterKhuyenMai() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredKhuyenMaiList = _khuyenMaiList.where((km) {
        final tenKM = km['TenKhuyenMai'].toString().toLowerCase();
        final trangThai = km['TrangThai'].toString().toLowerCase();
        return tenKM.contains(query) || trangThai.contains(query);
      }).toList();
    });
  }

  Future<void> _loadKhuyenMai() async {
    try {
      final snapshot = await _firestore
          .collection('khuyenmai')
          .orderBy('NgayTao', descending: true)
          .get();

      setState(() {
        _khuyenMaiList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'TenKhuyenMai': data['TenKhuyenMai'],
            'PhanTramGiam': data['PhanTramGiam'],
            'NgayBatDau': (data['NgayBatDau'] as Timestamp).toDate(),
            'NgayKetThuc': (data['NgayKetThuc'] as Timestamp).toDate(),
            'TrangThai': data['TrangThai'],
            'SoSanPham': (data['IdSanPham'] as List).length,
            'NgayTao': (data['NgayTao'] as Timestamp).toDate(),
          };
        }).toList();
        _filteredKhuyenMaiList = _khuyenMaiList;
      });
    } catch (e) {
      print("Lỗi tải khuyến mãi: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getTrangThaiText(DateTime ngayBatDau, DateTime ngayKetThuc, String trangThai) {
    if (trangThai == "Ngừng hoạt động") return "Ngừng hoạt động";

    final now = DateTime.now();
    if (now.isBefore(ngayBatDau)) return "Sắp diễn ra";
    if (now.isAfter(ngayKetThuc)) return "Đã kết thúc";
    return "Đang hoạt động";
  }

  Color _getTrangThaiColor(String trangThaiText) {
    switch (trangThaiText) {
      case "Đang hoạt động":
        return Colors.green;
      case "Sắp diễn ra":
        return Colors.orange;
      case "Đã kết thúc":
        return Colors.red;
      case "Ngừng hoạt động":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _xoaKhuyenMai(String id, List<String> idSanPham) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa khuyến mãi này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        // Xóa khuyến mãi
        await _firestore.collection('khuyenmai').doc(id).delete();

        // Xóa khuyến mãi khỏi các sản phẩm
        final batch = _firestore.batch();
        for (final spId in idSanPham) {
          final spRef = _firestore.collection('sanpham').doc(spId);
          batch.update(spRef, {
            'KhuyenMaiApDung': FieldValue.arrayRemove([id])
          });
        }
        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa khuyến mãi thành công!")),
        );

        await _loadKhuyenMai();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi xóa: $e")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildKhuyenMaiItem(Map<String, dynamic> km) {
    final trangThaiText = _getTrangThaiText(
        km['NgayBatDau'],
        km['NgayKetThuc'],
        km['TrangThai']
    );
    final trangThaiColor = _getTrangThaiColor(trangThaiText);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: mainBlue, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      km['TenKhuyenMai'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trangThaiColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: trangThaiColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      trangThaiText,
                      style: TextStyle(
                        color: trangThaiColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: mainBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${km['PhanTramGiam']}%",
                      style: TextStyle(
                        color: mainBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          "${km['SoSanPham']} SP",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              "Bắt đầu: ${DateFormat('dd/MM/yyyy').format(km['NgayBatDau'])}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              "Kết thúc: ${DateFormat('dd/MM/yyyy').format(km['NgayKetThuc'])}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _xoaKhuyenMai(km['id'], List<String>.from(km['IdSanPham']));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Xóa"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 8),
            const Text("Danh sách khuyến mãi"),
          ],
        ),
        backgroundColor: mainBlue,
      ),
      body: Column(
        children: [
          // Header với thống kê
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: lightBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quản lý khuyến mãi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tổng số: ${_filteredKhuyenMaiList.length} khuyến mãi",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Tìm kiếm khuyến mãi...",
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterKhuyenMai();
                  },
                )
                    : null,
              ),
            ),
          ),

          // Danh sách khuyến mãi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredKhuyenMaiList.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.percent, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Chưa có khuyến mãi nào",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadKhuyenMai,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredKhuyenMaiList.length,
                itemBuilder: (context, index) {
                  return _buildKhuyenMaiItem(_filteredKhuyenMaiList[index]);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddKhuyenMaiPage()),
          ).then((_) => _loadKhuyenMai());
        },
        backgroundColor: mainBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}