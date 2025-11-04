import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSubCategoryPage extends StatefulWidget {
  final String idDanhMucCon;

  const EditSubCategoryPage({super.key, required this.idDanhMucCon});

  @override
  State<EditSubCategoryPage> createState() => _EditSubCategoryPageState();
}

class _EditSubCategoryPageState extends State<EditSubCategoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _tenController = TextEditingController();
  final TextEditingController _hinhAnhController = TextEditingController();
  String _trangThai = "Hoạt Động";
  String? _oldTrangThai; // Lưu trạng thái cũ để so sánh

  String? _selectedIdDanhMucCha;
  List<Map<String, dynamic>> _danhMucChaList = [];

  bool _isLoading = true;

  // Color scheme đồng bộ
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _textColor = const Color(0xFF212529);
  final Color _borderColor = const Color(0xFFDEE2E6);
  final Color _successColor = const Color(0xFF28A745);
  final Color _errorColor = const Color(0xFFDC3545);
  final Color _hintColor = const Color(0xFF6C757D);

  @override
  void initState() {
    super.initState();
    _loadSubCategoryData();
    _loadDanhMucChaList();
  }

  Future<void> _loadSubCategoryData() async {
    try {
      final doc = await _firestore.collection("danhmuccon").doc(widget.idDanhMucCon).get();
      if (doc.exists) {
        final data = doc.data()!;
        _tenController.text = data["TenDanhMucCon"] ?? "";
        _hinhAnhController.text = data["HinhAnh"] ?? "";
        _trangThai = data["TrangThai"] ?? "Hoạt Động";
        _oldTrangThai = _trangThai; // Lưu trạng thái cũ
        _selectedIdDanhMucCha = data["IdDanhMuc"];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi tải dữ liệu: $e"),
          backgroundColor: _errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDanhMucChaList() async {
    try {
      final snapshot = await _firestore
          .collection("danhmuc")
          .where("TrangThai", isEqualTo: "Hoạt Động") // Chỉ load danh mục đang hoạt động
          .get();

      _danhMucChaList = snapshot.docs
          .map((doc) => {
        "id": doc.id,
        "ten": doc.data()["Ten"] ?? "Không có tên"
      })
          .toList();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi tải danh mục cha: $e"),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  Future<void> _updateSubCategory() async {
    if (_tenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên danh mục con")),
      );
      return;
    }

    if (_selectedIdDanhMucCha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn danh mục cha")),
      );
      return;
    }

    try {
      final batch = _firestore.batch();

      // Cập nhật danh mục con
      final subCategoryRef = _firestore.collection("danhmuccon").doc(widget.idDanhMucCon);
      batch.update(subCategoryRef, {
        "TenDanhMucCon": _tenController.text.trim(),
        "HinhAnh": _hinhAnhController.text.trim(),
        "TrangThai": _trangThai,
        "IdDanhMuc": _selectedIdDanhMucCha,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // Nếu chuyển từ Hoạt Động sang Ngưng Hoạt Động
      if (_oldTrangThai == "Hoạt Động" && _trangThai == "Ngưng Hoạt Động") {
        // Ẩn tất cả thương hiệu thuộc danh mục con này
        final brandsSnapshot = await _firestore
            .collection("thuonghieu")
            .where("IdDanhMucCon", isEqualTo: widget.idDanhMucCon)
            .get();

        for (var doc in brandsSnapshot.docs) {
          batch.update(doc.reference, {
            "TrangThai": "Ngưng Hoạt Động",
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }

        // Ẩn tất cả sản phẩm thuộc danh mục con này
        final productsSnapshot = await _firestore
            .collection("sanpham")
            .where("IdDanhMucCon", isEqualTo: widget.idDanhMucCon)
            .get();

        for (var doc in productsSnapshot.docs) {
          batch.update(doc.reference, {
            "TrangThai": "Ngưng Hoạt Động",
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Cập nhật danh mục con thành công!"),
          backgroundColor: _successColor,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi cập nhật: $e"),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chỉnh sửa danh mục con",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chỉnh sửa danh mục con",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Cập nhật thông tin cho danh mục con",
                      style: TextStyle(
                        fontSize: 14,
                        color: _hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Form Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tên danh mục con
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tên danh mục con *",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _textColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: _surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _tenController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Nhập tên danh mục con",
                                    hintStyle: TextStyle(color: _hintColor),
                                    prefixIcon: Icon(Icons.category_outlined, color: _primaryColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  style: TextStyle(color: _textColor, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Danh mục cha
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Danh mục cha *",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _textColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: _surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedIdDanhMucCha,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Chọn danh mục cha",
                                    hintStyle: TextStyle(color: _hintColor),
                                    prefixIcon: Icon(Icons.category, color: _primaryColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  dropdownColor: _surfaceColor,
                                  style: TextStyle(color: _textColor, fontSize: 14),
                                  items: _danhMucChaList
                                      .map((dm) => DropdownMenuItem(
                                    value: dm["id"].toString(),
                                    child: Text(dm["ten"]),
                                  ))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedIdDanhMucCha = v),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Hình ảnh
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "URL hình ảnh",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _textColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: _surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _hinhAnhController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "https://...",
                                    hintStyle: TextStyle(color: _hintColor),
                                    prefixIcon: Icon(Icons.link, color: _primaryColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  style: TextStyle(color: _textColor, fontSize: 14),
                                  onChanged: (v) => setState(() {}),
                                ),
                              ),

                              // Preview Image
                              if (_hinhAnhController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Xem trước hình ảnh",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: _backgroundColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: _borderColor),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            _hinhAnhController.text,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.contain,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                height: 200,
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                  color: _primaryColor,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stack) => Container(
                                              height: 200,
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.error_outline, color: _hintColor, size: 40),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Không tải được ảnh",
                                                    style: TextStyle(color: _hintColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Trạng thái
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Trạng thái *",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _textColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: _surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _trangThai,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      child: Icon(Icons.circle_rounded, color: _primaryColor, size: 18),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  dropdownColor: _surfaceColor,
                                  style: TextStyle(color: _textColor, fontSize: 14),
                                  items: [
                                    DropdownMenuItem(
                                      value: "Hoạt Động",
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.check_circle, color: _successColor, size: 20),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "Hoạt Động",
                                                style: TextStyle(color: _textColor, fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "Ngưng Hoạt Động",
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.pause_circle, color: _errorColor, size: 20),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "Ngưng Hoạt Động",
                                                style: TextStyle(color: _textColor, fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _trangThai = val!),
                                ),
                              ),
                              // Thông báo khi chuyển sang trạng thái ẩn
                              if (_trangThai == "Ngưng Hoạt Động" && _oldTrangThai == "Hoạt Động")
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _errorColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _errorColor),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: _errorColor, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Tất cả thương hiệu và sản phẩm thuộc danh mục này sẽ được ẩn",
                                            style: TextStyle(
                                              color: _errorColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
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

                        const SizedBox(height: 8),

                        // Nút lưu
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: ElevatedButton(
                            onPressed: _updateSubCategory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              "Cập nhật danh mục con",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}