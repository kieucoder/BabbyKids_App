// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class DeleteCategoryPage extends StatefulWidget {
//   final String idDanhMuc;
//
//   const DeleteCategoryPage({super.key, required this.idDanhMuc});
//
//   @override
//   State<DeleteCategoryPage> createState() => _DeleteCategoryPageState();
// }
//
// class _DeleteCategoryPageState extends State<DeleteCategoryPage> {
//   bool _isLoading = true;
//   bool _isDeleting = false;
//   bool _cannotDelete = false;
//   Map<String, dynamic>? _categoryData;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategoryData();
//   }
//
//   Future<void> _loadCategoryData() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('danhmuc')
//           .doc(widget.idDanhMuc)
//           .get();
//
//       if (doc.exists) {
//         _categoryData = doc.data();
//
//         // Kiểm tra danh mục con / sản phẩm
//         final products = await FirebaseFirestore.instance
//             .collection("sanpham")
//             .where("IdDanhMuc", isEqualTo: widget.idDanhMuc)
//             .get();
//
//         final subCategories = await FirebaseFirestore.instance
//             .collection("danhmuc")
//             .where("ParentId", isEqualTo: widget.idDanhMuc)
//             .get();
//
//         if (products.docs.isNotEmpty || subCategories.docs.isNotEmpty) {
//           _cannotDelete = true;
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Danh mục không tồn tại")),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi tải dữ liệu: $e")),
//       );
//       Navigator.pop(context);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _deleteCategory() async {
//     if (_cannotDelete) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//                 "Không thể xóa danh mục vì đang có sản phẩm hoặc danh mục con!")),
//       );
//       return;
//     }
//
//     setState(() => _isDeleting = true);
//     try {
//       await FirebaseFirestore.instance
//           .collection("danhmuc")
//           .doc(widget.idDanhMuc)
//           .delete();
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Xóa danh mục thành công!")),
//         );
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       setState(() => _isDeleting = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi xóa danh mục: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Color mainBlue = const Color(0xFF007BFF);
//     final Color lightBlue = const Color(0xFFE6F2FF);
//
//     return Scaffold(
//       backgroundColor: lightBlue,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Navigator.pop(context), // quay về
//         ),
//         title: const Text(
//           "Xóa danh mục",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: mainBlue,
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
//           : Center(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 600),
//           margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 12,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text(
//                 "Thông tin danh mục",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Hình ảnh
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: _categoryData!["HinhAnh"] != null &&
//                     _categoryData!["HinhAnh"].toString().isNotEmpty
//                     ? Image.network(
//                   _categoryData!["HinhAnh"],
//                   height: 150,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) =>
//                       Container(
//                         height: 150,
//                         color: Colors.grey[200],
//                         alignment: Alignment.center,
//                         child: const Icon(Icons.image_not_supported,
//                             size: 50, color: Colors.grey),
//                       ),
//                 )
//                     : Container(
//                   height: 150,
//                   color: Colors.grey[200],
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.image_outlined,
//                       size: 50, color: Colors.grey),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               Text(
//                 "ID: ${widget.idDanhMuc}",
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 4),
//
//               Text(
//                 _categoryData!["Ten"] ?? "Không có tên",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 4),
//
//               Text(
//                 "Trạng thái: ${_categoryData!["TrangThai"] ?? "Không xác định"}",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: _categoryData!["TrangThai"] == "Hoạt Động"
//                         ? Colors.green
//                         : Colors.redAccent),
//               ),
//               const SizedBox(height: 24),
//
//               _isDeleting
//                   ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
//                   : Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey.shade400,
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text(
//                       "Hủy",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: _deleteCategory,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _cannotDelete
//                           ? Colors.grey
//                           : Colors.redAccent,
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: Text(
//                       _cannotDelete ? "Không thể xóa" : "Xóa",
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCategoryPage extends StatefulWidget {
  final String idDanhMuc;

  const DeleteCategoryPage({super.key, required this.idDanhMuc});

  @override
  State<DeleteCategoryPage> createState() => _DeleteCategoryPageState();
}

class _DeleteCategoryPageState extends State<DeleteCategoryPage> {
  bool _isLoading = true;
  bool _isActionInProgress = false;
  bool _hasConstraints = false;
  Map<String, dynamic>? _categoryData;
  final List<String> _constraintDetails = [];

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('danhmuc')
          .doc(widget.idDanhMuc)
          .get();

      if (doc.exists) {
        _categoryData = doc.data();

        // Kiểm tra danh mục con
        final subCategories = await FirebaseFirestore.instance
            .collection("danhmuccon")
            .where("IdDanhMuc", isEqualTo: widget.idDanhMuc)
            .get();

        // Lấy danh sách ID danh mục con để kiểm tra thương hiệu
        List<String> subCategoryIds = [];
        for (var doc in subCategories.docs) {
          if (doc['IdDanhMucCon'] != null) {
            subCategoryIds.add(doc['IdDanhMucCon'] as String);
          }
        }

        // Kiểm tra thương hiệu - SỬA LẠI: chỉ kiểm tra khi có danh mục con
        QuerySnapshot brands = await FirebaseFirestore.instance
            .collection("thuonghieu")
            .where("IdDanhMucCon", whereIn: subCategoryIds.isNotEmpty ? subCategoryIds : ['temp'])
            .get();

        // Kiểm tra sản phẩm - SỬA LẠI: xử lý trường hợp không có danh mục con
        QuerySnapshot products;
        if (subCategoryIds.isNotEmpty) {
          products = await FirebaseFirestore.instance
              .collection("sanpham")
              .where(Filter.or(
              Filter('IdDanhMuc', isEqualTo: widget.idDanhMuc),
              Filter('IdDanhMucCon', whereIn: subCategoryIds)
          ))
              .get();
        } else {
          // Nếu không có danh mục con, chỉ tìm theo IdDanhMuc
          products = await FirebaseFirestore.instance
              .collection("sanpham")
              .where('IdDanhMuc', isEqualTo: widget.idDanhMuc)
              .get();
        }

        // Kiểm tra ràng buộc
        if (subCategories.docs.isNotEmpty) {
          _hasConstraints = true;
          _constraintDetails.add("${subCategories.docs.length} danh mục con");
        }

        // Chỉ thêm thương hiệu nếu có kết quả thực sự (loại bỏ kết quả từ ['temp'])
        if (brands.docs.isNotEmpty && subCategoryIds.isNotEmpty) {
          _hasConstraints = true;
          _constraintDetails.add("${brands.docs.length} thương hiệu");
        }

        if (products.docs.isNotEmpty) {
          _hasConstraints = true;
          _constraintDetails.add("${products.docs.length} sản phẩm");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Danh mục không tồn tại")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu: $e")),
      );
      Navigator.pop(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hideCategory() async {
    setState(() => _isActionInProgress = true);
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Cập nhật danh mục cha
      final categoryRef = FirebaseFirestore.instance.collection("danhmuc").doc(widget.idDanhMuc);
      batch.update(categoryRef, {
        "TrangThai": "Ngưng Hoạt Động",
      });

      // Cập nhật danh mục con
      final subCategoriesSnapshot = await FirebaseFirestore.instance
          .collection("danhmuccon")
          .where("IdDanhMuc", isEqualTo: widget.idDanhMuc)
          .get();

      // Lấy danh sách ID danh mục con để cập nhật thương hiệu
      List<String> subCategoryIds = [];
      for (var doc in subCategoriesSnapshot.docs) {
        if (doc['IdDanhMucCon'] != null) {
          String subCategoryId = doc['IdDanhMucCon'] as String;
          subCategoryIds.add(subCategoryId);

          batch.update(doc.reference, {
            "TrangThai": "Ngưng Hoạt Động",
          });
        }
      }

      // Cập nhật thương hiệu - SỬA LẠI: chỉ cập nhật khi có danh mục con
      if (subCategoryIds.isNotEmpty) {
        final brandsSnapshot = await FirebaseFirestore.instance
            .collection("thuonghieu")
            .where("IdDanhMucCon", whereIn: subCategoryIds)
            .get();

        for (var doc in brandsSnapshot.docs) {
          batch.update(doc.reference, {
            "TrangThai": "Ngưng Hoạt Động",
          });
        }
      }

      // Cập nhật sản phẩm - SỬA LẠI: xử lý cả hai trường hợp
      QuerySnapshot productsSnapshot;
      if (subCategoryIds.isNotEmpty) {
        productsSnapshot = await FirebaseFirestore.instance
            .collection("sanpham")
            .where(Filter.or(
            Filter('IdDanhMuc', isEqualTo: widget.idDanhMuc),
            Filter('IdDanhMucCon', whereIn: subCategoryIds)
        ))
            .get();
      } else {
        productsSnapshot = await FirebaseFirestore.instance
            .collection("sanpham")
            .where('IdDanhMuc', isEqualTo: widget.idDanhMuc)
            .get();
      }

      for (var doc in productsSnapshot.docs) {
        batch.update(doc.reference, {
          "TrangThai": "Ngưng Hoạt Động",
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã ẩn danh mục và các dữ liệu liên quan thành công!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isActionInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi ẩn danh mục: $e")),
      );
    }
  }

  Future<void> _deleteCategory() async {
    if (_hasConstraints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Không thể xóa danh mục vì đang có ràng buộc dữ liệu!")),
      );
      return;
    }

    setState(() => _isActionInProgress = true);
    try {
      await FirebaseFirestore.instance
          .collection("danhmuc")
          .doc(widget.idDanhMuc)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xóa danh mục thành công!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isActionInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi xóa danh mục: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _backgroundColor = const Color(0xFFF8F9FA);
    final Color _surfaceColor = const Color(0xFFFFFFFF);
    final Color _textColor = const Color(0xFF212529);
    final Color _borderColor = const Color(0xFFDEE2E6);
    final Color _errorColor = const Color(0xFFDC3545);
    final Color _warningColor = const Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _hasConstraints ? "Ẩn danh mục" : "Xóa danh mục",
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
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
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
                          ? "Không thể xóa danh mục"
                          : "Xác nhận xóa danh mục",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasConstraints
                          ? "Danh mục này đang được sử dụng trong hệ thống"
                          : "Bạn có chắc chắn muốn xóa danh mục này?",
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
                          height: 160,
                          decoration: BoxDecoration(
                            color: _backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _categoryData!["HinhAnh"] != null &&
                                _categoryData!["HinhAnh"].toString().isNotEmpty
                                ? Image.network(
                              _categoryData!["HinhAnh"],
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 160,
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
                              height: 160,
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

                        // Thông tin danh mục
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
                                "ID: ${widget.idDanhMuc}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _categoryData!["Ten"] ?? "Không có tên",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Trạng thái: ${_categoryData!["TrangThai"] ?? "Không xác định"}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _categoryData!["TrangThai"] == "Hoạt Động"
                                      ? Colors.green
                                      : Colors.redAccent,
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
                                  "Danh mục này đang chứa:",
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
                                  "Bạn chỉ có thể ẩn danh mục thay vì xóa.",
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
                        _isActionInProgress
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
                                    ? _hideCategory
                                    : _deleteCategory,
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
                                  _hasConstraints ? "Ẩn danh mục" : "Xóa",
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