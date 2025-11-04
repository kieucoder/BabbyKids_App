// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class DeleteSubCategoryPage extends StatefulWidget {
//   final String idDanhMucCon;
//
//   const DeleteSubCategoryPage({super.key, required this.idDanhMucCon});
//
//   @override
//   State<DeleteSubCategoryPage> createState() => _DeleteSubCategoryPageState();
// }
//
// class _DeleteSubCategoryPageState extends State<DeleteSubCategoryPage> {
//   final Color mainBlue = const Color(0xFF007BFF);
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   String tenDanhMucCon = "";
//   String hinhAnh = "";
//   String tenDanhMucCha = "";
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSubCategory();
//   }
//
//   Future<void> _loadSubCategory() async {
//     try {
//       final doc = await _firestore.collection("danhmuccon").doc(widget.idDanhMucCon).get();
//
//       if (doc.exists) {
//         final data = doc.data()!;
//         final idDanhMucCha = data["IdDanhMucCha"] ?? "";
//
//         // 🔹 Lấy tên danh mục cha
//         String tenCha = "";
//         if (idDanhMucCha.isNotEmpty) {
//           final chaDoc = await _firestore.collection("danhmuc").doc(idDanhMucCha).get();
//           if (chaDoc.exists) {
//             tenCha = chaDoc["TenDanhMuc"] ?? "";
//           }
//         }
//
//         setState(() {
//           tenDanhMucCon = data["TenDanhMucCon"] ?? "";
//           hinhAnh = data["HinhAnh"] ?? "";
//           tenDanhMucCha = tenCha.isNotEmpty ? tenCha : "(Không xác định)";
//           _loading = false;
//         });
//       } else {
//         setState(() => _loading = false);
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi khi tải dữ liệu: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   Future<void> _deleteSubCategory() async {
//     final check = await _firestore
//         .collection("sanpham")
//         .where("IdDanhMucCon", isEqualTo: widget.idDanhMucCon)
//         .limit(1)
//         .get();
//
//     if (check.docs.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("❌ Không thể xóa — danh mục con này có sản phẩm liên kết!"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     await _firestore.collection("danhmuccon").doc(widget.idDanhMucCon).delete();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("✅ Đã xóa danh mục con thành công!"),
//         backgroundColor: Colors.green,
//       ),
//     );
//
//     Navigator.pop(context, true);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue.shade50,
//       appBar: AppBar(
//         backgroundColor: mainBlue,
//         title: const Text("Xóa danh mục con",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(20),
//         child: Card(
//           elevation: 5,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 🔹 Hình ảnh
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     hinhAnh,
//                     height: 150,
//                     width: 150,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) =>
//                     const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // 🔹 Tên danh mục con
//                 Text(
//                   tenDanhMucCon,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//
//                 // 🔹 Tên danh mục cha
//                 Text(
//                   "Danh mục cha: $tenDanhMucCha",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.blueGrey,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // 🔹 Cảnh báo
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade100.withOpacity(0.4),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     "⚠️ Bạn có chắc chắn muốn xóa danh mục con này không?\nHành động này không thể hoàn tác!",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//
//                 // 🔹 Nút xóa
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: _deleteSubCategory,
//                     icon: const Icon(Icons.delete_forever, color: Colors.white),
//                     label: const Text(
//                       "Xóa danh mục con",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.redAccent,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteSubCategoryPage extends StatefulWidget {
  final String idDanhMucCon;

  const DeleteSubCategoryPage({super.key, required this.idDanhMucCon});

  @override
  State<DeleteSubCategoryPage> createState() => _DeleteSubCategoryPageState();
}

class _DeleteSubCategoryPageState extends State<DeleteSubCategoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Color scheme đồng bộ
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _textColor = const Color(0xFF212529);
  final Color _borderColor = const Color(0xFFDEE2E6);
  final Color _successColor = const Color(0xFF28A745);
  final Color _errorColor = const Color(0xFFDC3545);
  final Color _warningColor = const Color(0xFFFFC107);
  final Color _hintColor = const Color(0xFF6C757D);

  String _tenDanhMucCon = "";
  String _hinhAnh = "";
  String _tenDanhMucCha = "";
  String _trangThai = "";
  bool _isLoading = true;
  bool _hasConstraints = false;
  bool _isDeleting = false;
  final List<String> _constraintDetails = [];

  @override
  void initState() {
    super.initState();
    _loadSubCategoryData();
  }

  Future<void> _loadSubCategoryData() async {
    try {
      final doc = await _firestore.collection("danhmuccon").doc(widget.idDanhMucCon).get();

      if (doc.exists) {
        final data = doc.data()!;
        final idDanhMucCha = data["IdDanhMuc"] ?? "";

        // Lấy tên danh mục cha
        String tenCha = "Không xác định";
        if (idDanhMucCha.isNotEmpty) {
          final chaDoc = await _firestore.collection("danhmuc").doc(idDanhMucCha).get();
          if (chaDoc.exists) {
            tenCha = chaDoc.data()!["Ten"] ?? "Không có tên";
          }
        }

        // Kiểm tra ràng buộc - THÊM KIỂM TRA THƯƠNG HIỆU
        final products = await _firestore
            .collection("sanpham")
            .where("IdDanhMucCon", isEqualTo: widget.idDanhMucCon)
            .get();

        final brands = await _firestore
            .collection("thuonghieu")
            .where("IdDanhMucCon", isEqualTo: widget.idDanhMucCon)
            .get();

        // Kiểm tra ràng buộc
        if (products.docs.isNotEmpty) {
          _hasConstraints = true;
          _constraintDetails.add("${products.docs.length} sản phẩm");
        }

        if (brands.docs.isNotEmpty) {
          _hasConstraints = true;
          _constraintDetails.add("${brands.docs.length} thương hiệu");
        }

        setState(() {
          _tenDanhMucCon = data["TenDanhMucCon"] ?? "";
          _hinhAnh = data["HinhAnh"] ?? "";
          _tenDanhMucCha = tenCha;
          _trangThai = data["TrangThai"] ?? "";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Danh mục con không tồn tại")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu: $e"),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  Future<void> _hideSubCategory() async {
    setState(() => _isDeleting = true);
    try {
      final batch = _firestore.batch();

      // Ẩn danh mục con
      final subCategoryRef = _firestore.collection("danhmuccon").doc(widget.idDanhMucCon);
      batch.update(subCategoryRef, {
        "TrangThai": "Ngưng Hoạt Động",
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // Ẩn thương hiệu liên quan
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

      // Ẩn sản phẩm liên quan
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

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã ẩn danh mục con và các dữ liệu liên quan thành công!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi ẩn danh mục con: $e"),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  Future<void> _deleteSubCategory() async {
    if (_hasConstraints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể xóa danh mục con vì đang có ràng buộc dữ liệu!")),
      );
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await _firestore.collection("danhmuccon").doc(widget.idDanhMucCon).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xóa danh mục con thành công!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi xóa danh mục con: $e"),
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
        title: Text(
          _hasConstraints ? "Ẩn danh mục con" : "Xóa danh mục con",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: _hasConstraints ? _warningColor : _errorColor,
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
                      _hasConstraints
                          ? "Không thể xóa danh mục con"
                          : "Xác nhận xóa danh mục con",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasConstraints
                          ? "Danh mục con này đang được sử dụng trong hệ thống"
                          : "Bạn có chắc chắn muốn xóa danh mục con này?",
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content Card
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
                        // Hình ảnh
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
                            child: _hinhAnh.isNotEmpty
                                ? Image.network(
                              _hinhAnh,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: _borderColor, size: 40),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Không tải được ảnh",
                                          style: TextStyle(color: _borderColor),
                                        ),
                                      ],
                                    ),
                                  ),
                            )
                                : Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      color: _borderColor, size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Không có hình ảnh",
                                    style: TextStyle(color: _borderColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Thông tin danh mục con
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ID: ${widget.idDanhMucCon}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _tenDanhMucCon,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Danh mục cha: $_tenDanhMucCha",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Trạng thái: $_trangThai",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _trangThai == "Hoạt Động"
                                      ? _successColor
                                      : _errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Thông báo ràng buộc
                        if (_hasConstraints) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _warningColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: _warningColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Đang có ràng buộc dữ liệu",
                                      style: TextStyle(
                                        color: _textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Danh mục con này đang chứa:",
                                  style: TextStyle(
                                    color: _textColor.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ..._constraintDetails.map((detail) =>
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, top: 2),
                                      child: Text(
                                        "• $detail",
                                        style: TextStyle(
                                          color: _textColor.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Bạn chỉ có thể ẩn danh mục con thay vì xóa.",
                                  style: TextStyle(
                                    color: _warningColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Nút hành động
                        _isDeleting
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                          children: [
                            // Nút hủy
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: _borderColor),
                                ),
                                child: Text(
                                  "Hủy",
                                  style: TextStyle(
                                    color: _textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Nút chính
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _hasConstraints
                                    ? _hideSubCategory
                                    : _deleteSubCategory,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasConstraints
                                      ? _warningColor
                                      : _errorColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _hasConstraints ? "Ẩn danh mục con" : "Xóa",
                                  style: const TextStyle(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}