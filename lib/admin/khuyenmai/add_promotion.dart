import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddKhuyenMaiPage extends StatefulWidget {
  const AddKhuyenMaiPage({Key? key}) : super(key: key);

  @override
  State<AddKhuyenMaiPage> createState() => _AddKhuyenMaiPageState();
}

class _AddKhuyenMaiPageState extends State<AddKhuyenMaiPage> {
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _tenKMController = TextEditingController();
  final TextEditingController _phanTramController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime? _ngayBatDau;
  DateTime? _ngayKetThuc;
  String _trangThai = "Đang hoạt động";

  List<Map<String, dynamic>> _sanPhamList = [];
  List<Map<String, dynamic>> _filteredSanPhamList = [];
  List<String> _selectedSanPhamList = [];
  List<Map<String, dynamic>> _selectedSanPhamDetails = [];

  bool _isLoading = false;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadSanPham();
    _searchController.addListener(_filterSanPham);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSanPham() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSanPhamList = _sanPhamList.where((sp) {
        final tenSP = sp['ten'].toString().toLowerCase();
        return tenSP.contains(query);
      }).toList();
    });
  }

  Future<void> _loadSanPham() async {
    setState(() => _isLoadingProducts = true);
    try {
      final snapshot = await _firestore.collection('sanpham').get();
      setState(() {
        _sanPhamList = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'ten': doc['TenSanPham'],
            'gia': doc['Gia'],
          };
        }).toList();
        _filteredSanPhamList = _sanPhamList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải sản phẩm: $e")),
      );
    } finally {
      setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _chonNgay(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _ngayBatDau = picked;
        } else {
          _ngayKetThuc = picked;
        }
      });
    }
  }

  void _toggleSanPham(Map<String, dynamic> sanPham, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedSanPhamList.add(sanPham['id']);
        _selectedSanPhamDetails.add(sanPham);
      } else {
        _selectedSanPhamList.remove(sanPham['id']);
        _selectedSanPhamDetails.removeWhere((sp) => sp['id'] == sanPham['id']);
      }
    });
  }

  Future<void> _luuKhuyenMai() async {
    if (_tenKMController.text.isEmpty ||
        _phanTramController.text.isEmpty ||
        _ngayBatDau == null ||
        _ngayKetThuc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    if (_ngayKetThuc!.isBefore(_ngayBatDau!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ngày kết thúc phải sau ngày bắt đầu")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Tạo mã khuyến mãi tự động (KM01, KM02, ...)
      final querySnapshot = await _firestore.collection('khuyenmai').get();
      int maxIndex = 0;
      for (var doc in querySnapshot.docs) {
        final id = doc['IdKhuyenMai'] ?? '';
        if (id.startsWith('KM')) {
          final numberPart = int.tryParse(id.substring(2)) ?? 0;
          if (numberPart > maxIndex) maxIndex = numberPart;
        }
      }
      final newIndex = maxIndex + 1;
      final newKMId = 'KM${newIndex.toString().padLeft(2, '0')}';
      final newKMRef = _firestore.collection("khuyenmai").doc(newKMId);

      final phanTram = int.tryParse(_phanTramController.text) ?? 0;

      // Lưu thông tin khuyến mãi
      await newKMRef.set({
        "IdKhuyenMai": newKMId,
        "TenKhuyenMai": _tenKMController.text,
        "PhanTramGiam": phanTram,
        "NgayBatDau": Timestamp.fromDate(_ngayBatDau!),
        "NgayKetThuc": Timestamp.fromDate(_ngayKetThuc!),
        "TrangThai": _trangThai,
        "IdSanPham": _selectedSanPhamList,
        "NgayTao": FieldValue.serverTimestamp(),
      });

      // Cập nhật IdKhuyenMai cho từng sản phẩm được chọn
      final batch = _firestore.batch();
      for (final spId in _selectedSanPhamList) {
        final spRef = _firestore.collection("sanpham").doc(spId);
        batch.update(spRef, {"IdKhuyenMai": newKMId});
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm khuyến mãi thành công!")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu khuyến mãi: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSanPhamList() {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedSanPhamDetails.isNotEmpty) ...[
          const Text(
            "Sản phẩm đã chọn:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSanPhamDetails.map((sp) {
              return Chip(
                label: Text(sp['ten']),
                onDeleted: () => _toggleSanPham(sp, false),
              );
            }).toList(),
          ),
          const Divider(),
        ],
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: "Tìm kiếm sản phẩm",
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _filterSanPham();
              },
            )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredSanPhamList.length,
            itemBuilder: (context, index) {
              final sp = _filteredSanPhamList[index];
              final isSelected = _selectedSanPhamList.contains(sp['id']);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (val) => _toggleSanPham(sp, val!),
                  ),
                  title: Text(
                    sp['ten'],
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    "Giá: ${NumberFormat.decimalPattern('vi').format(sp['gia'])}đ",
                  ),
                  onTap: () => _toggleSanPham(sp, !isSelected),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true, // Căn giữa tiêu đề
        elevation: 2, // tạo chiều sâu nhẹ cho AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Thêm Khuyến Mãi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thông tin khuyến mãi",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tenKMController,
                      decoration: const InputDecoration(
                        labelText: "Tên khuyến mãi *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phanTramController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Phần trăm giảm (%) *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _chonNgay(true),
                            child: Text(_ngayBatDau == null
                                ? "Chọn ngày bắt đầu *"
                                : "Bắt đầu: ${DateFormat('dd/MM/yyyy').format(_ngayBatDau!)}"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _chonNgay(false),
                            child: Text(_ngayKetThuc == null
                                ? "Chọn ngày kết thúc *"
                                : "Kết thúc: ${DateFormat('dd/MM/yyyy').format(_ngayKetThuc!)}"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _trangThai,
                      items: ["Đang hoạt động", "Ngừng hoạt động"]
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _trangThai = val!),
                      decoration: const InputDecoration(
                        labelText: "Trạng thái",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Chọn sản phẩm áp dụng",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildSanPhamList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _luuKhuyenMai,
                icon: const Icon(Icons.save),
                label: const Text("Lưu khuyến mãi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
