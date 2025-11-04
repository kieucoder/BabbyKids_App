// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class DeleteBrandPage extends StatefulWidget {
//   final String idThuongHieu;
//
//   const DeleteBrandPage({Key? key, required this.idThuongHieu}) : super(key: key);
//
//   @override
//   State<DeleteBrandPage> createState() => _DeleteBrandPageState();
// }
//
// class _DeleteBrandPageState extends State<DeleteBrandPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Color scheme - Đồng bộ với ListProduct
//   final Color _primaryColor = Color(0xFF2563EB);
//   final Color _secondaryColor = Color(0xFF60A5FA);
//   final Color _backgroundColor = Color(0xFFF8FAFC);
//   final Color _surfaceColor = Colors.white;
//   final Color _textColor = Color(0xFF1E293B);
//   final Color _hintColor = Color(0xFF64748B);
//   final Color _successColor = Color(0xFF10B981);
//   final Color _errorColor = Color(0xFFEF4444);
//   final Color _warningColor = Color(0xFFF59E0B);
//   final Color _borderColor = Color(0xFFE2E8F0);
//
//   // State variables
//   Map<String, dynamic>? _brandData;
//   bool _loading = true;
//   bool _deleting = false;
//   bool _canDelete = true;
//   int _productCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBrandData();
//     _checkBrandInProducts();
//   }
//
//   Future<void> _loadBrandData() async {
//     try {
//       final doc = await _firestore.collection("thuonghieu").doc(widget.idThuongHieu).get();
//       if (!doc.exists) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❌ Không tìm thấy thương hiệu")),
//         );
//         Navigator.pop(context);
//         return;
//       }
//
//       setState(() {
//         _brandData = doc.data()!;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ Lỗi khi tải dữ liệu: $e")),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _checkBrandInProducts() async {
//     try {
//       // Kiểm tra trong bảng sản phẩm
//       final productsSnapshot = await _firestore
//           .collection("sanpham")
//           .where("IdThuongHieu", isEqualTo: widget.idThuongHieu)
//           .get();
//
//       setState(() {
//         _productCount = productsSnapshot.docs.length;
//         _canDelete = _productCount == 0;
//       });
//     } catch (e) {
//       print("Lỗi khi kiểm tra sản phẩm: $e");
//     }
//   }
//
//   Future<void> _deleteBrand() async {
//     if (!_canDelete) return;
//
//     setState(() => _deleting = true);
//
//     try {
//       await _firestore.collection("thuonghieu").doc(widget.idThuongHieu).delete();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("✅ Xóa thương hiệu thành công"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Lỗi khi xóa thương hiệu: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _deleting = false);
//     }
//   }
//
//   Widget _buildBrandInfo() {
//     if (_brandData == null) return const SizedBox();
//
//     final isActive = _brandData!["TrangThai"] == "Hoạt Động";
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: _surfaceColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header với hình ảnh và thông tin
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Hình ảnh thương hiệu
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: _backgroundColor,
//                 ),
//                 child: _brandData!["HinhAnh"] != null && _brandData!["HinhAnh"].toString().isNotEmpty
//                     ? ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     _brandData!["HinhAnh"].toString(),
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: _backgroundColor,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.image_not_supported_rounded, color: _hintColor, size: 24),
//                             const SizedBox(height: 4),
//                             Text(
//                               "No Image",
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: _hintColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 )
//                     : Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.image_outlined, color: _hintColor, size: 32),
//                     const SizedBox(height: 4),
//                     Text(
//                       "No Image",
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: _hintColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//
//               // Thông tin chính
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Tên thương hiệu
//                     Text(
//                       _brandData!["TenThuongHieu"] ?? "Không có tên",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: _textColor,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//
//                     // ID thương hiệu
//                     Text(
//                       "ID: ${_brandData!["IdThuongHieu"] ?? "N/A"}",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: _hintColor,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//
//                     // Trạng thái
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: isActive
//                             ? _successColor.withOpacity(0.1)
//                             : _errorColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: isActive ? _successColor : _errorColor,
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         isActive ? "🟢 Hoạt động" : "🔴 Ngưng hoạt động",
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                           color: isActive ? _successColor : _errorColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//
//           // Thông tin chi tiết
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: _backgroundColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 _buildDetailItem(
//                   icon: Icons.category_rounded,
//                   label: "Mã danh mục con",
//                   value: _brandData!["IdDanhMucCon"] ?? "N/A",
//                 ),
//                 if (_brandData!["MoTa"] != null && _brandData!["MoTa"].toString().isNotEmpty)
//                   _buildDetailItem(
//                     icon: Icons.description_rounded,
//                     label: "Mô tả",
//                     value: _brandData!["MoTa"].toString(),
//                   ),
//                 _buildDetailItem(
//                   icon: Icons.inventory_2_rounded,
//                   label: "Số sản phẩm đang sử dụng",
//                   value: "$_productCount sản phẩm",
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailItem({required IconData icon, required String label, required String value}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: _hintColor),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: _textColor,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: _hintColor,
//               ),
//               textAlign: TextAlign.right,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWarningMessage() {
//     if (_canDelete) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: _warningColor.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: _warningColor.withOpacity(0.3)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: _warningColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.warning_amber_rounded, size: 32, color: _warningColor),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "Xác nhận xóa thương hiệu",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: _textColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Bạn có chắc chắn muốn xóa thương hiệu này? Hành động này không thể hoàn tác và tất cả dữ liệu liên quan sẽ bị xóa vĩnh viễn.",
//               style: TextStyle(
//                 color: _hintColor,
//                 fontSize: 14,
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: _errorColor.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: _errorColor.withOpacity(0.3)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: _errorColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.error_outline_rounded, size: 32, color: _errorColor),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "Không thể xóa thương hiệu",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: _textColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             RichText(
//               textAlign: TextAlign.center,
//               text: TextSpan(
//                 style: TextStyle(
//                   color: _hintColor,
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//                 children: [
//                   const TextSpan(text: "Thương hiệu này đang được sử dụng trong "),
//                   TextSpan(
//                     text: "$_productCount sản phẩm",
//                     style: TextStyle(
//                       color: _errorColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const TextSpan(text: ". Bạn không thể xóa thương hiệu đã có sản phẩm sử dụng."),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: _errorColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline_rounded, size: 16, color: _errorColor),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       "Để xóa thương hiệu, trước tiên cần xóa/chuyển tất cả sản phẩm đang sử dụng thương hiệu này",
//                       style: TextStyle(
//                         color: _errorColor,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Scaffold(
//         backgroundColor: _backgroundColor,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: _primaryColor),
//               const SizedBox(height: 16),
//               Text(
//                 "Đang tải thông tin thương hiệu...",
//                 style: TextStyle(
//                   color: _textColor,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           "Xóa thương hiệu",
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: _primaryColor,
//         centerTitle: true,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           if (_deleting)
//             Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Thông tin thương hiệu
//             _buildBrandInfo(),
//
//             const SizedBox(height: 24),
//
//             // Cảnh báo hoặc thông báo không thể xóa
//             _buildWarningMessage(),
//
//             const SizedBox(height: 32),
//
//             // Nút hành động
//             if (_canDelete) ...[
//               // Nút xóa và hủy khi có thể xóa
//               Row(
//                 children: [
//                   // Nút hủy
//                   Expanded(
//                     child: Container(
//                       height: 56,
//                       decoration: BoxDecoration(
//                         color: _surfaceColor,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: _borderColor),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 6,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: TextButton(
//                         onPressed: _deleting ? null : () => Navigator.pop(context),
//                         style: TextButton.styleFrom(
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: Text(
//                           "HỦY",
//                           style: TextStyle(
//                             color: _textColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//
//                   // Nút xóa
//                   Expanded(
//                     child: Container(
//                       height: 56,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [_errorColor, Color(0xFFDC2626)],
//                           begin: Alignment.centerLeft,
//                           end: Alignment.centerRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _errorColor.withOpacity(0.3),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ElevatedButton(
//                         onPressed: _deleting ? null : _deleteBrand,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shadowColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: _deleting
//                             ? Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               "ĐANG XÓA...",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         )
//                             : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.delete_rounded, color: Colors.white, size: 20),
//                             const SizedBox(width: 8),
//                             Text(
//                               "XÓA THƯƠNG HIỆU",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             ] else ...[
//               // Chỉ nút quay lại khi không thể xóa
//               Container(
//                 width: double.infinity,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [_primaryColor, _secondaryColor],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _primaryColor.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         "QUAY LẠI DANH SÁCH",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteBrandPage extends StatefulWidget {
  final String idThuongHieu;

  const DeleteBrandPage({Key? key, required this.idThuongHieu}) : super(key: key);

  @override
  State<DeleteBrandPage> createState() => _DeleteBrandPageState();
}

class _DeleteBrandPageState extends State<DeleteBrandPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Color scheme đồng bộ
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _textColor = const Color(0xFF212529);
  final Color _borderColor = const Color(0xFFDEE2E6);
  final Color _successColor = const Color(0xFF28A745);
  final Color _errorColor = const Color(0xFFDC3545);
  final Color _warningColor = const Color(0xFFFFC107);

  Map<String, dynamic>? _brandData;
  bool _isLoading = true;
  bool _isActionInProgress = false;
  bool _hasConstraints = false;
  int _productCount = 0;
  final List<String> _constraintDetails = [];

  @override
  void initState() {
    super.initState();
    _loadBrandData();
  }

  Future<void> _loadBrandData() async {
    try {
      final doc = await _firestore.collection("thuonghieu").doc(widget.idThuongHieu).get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy thương hiệu")),
        );
        Navigator.pop(context);
        return;
      }

      _brandData = doc.data()!;

      // Kiểm tra sản phẩm
      final productsSnapshot = await _firestore
          .collection("sanpham")
          .where("IdThuongHieu", isEqualTo: widget.idThuongHieu)
          .get();

      // Kiểm tra ràng buộc
      if (productsSnapshot.docs.isNotEmpty) {
        _hasConstraints = true;
        _productCount = productsSnapshot.docs.length;
        _constraintDetails.add("$_productCount sản phẩm");
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tải dữ liệu: $e"),
          backgroundColor: _errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hideBrand() async {
    setState(() => _isActionInProgress = true);
    try {
      final batch = _firestore.batch();

      // Ẩn thương hiệu
      final brandRef = _firestore.collection("thuonghieu").doc(widget.idThuongHieu);
      batch.update(brandRef, {
        "TrangThai": "Ngưng Hoạt Động",
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // Ẩn tất cả sản phẩm thuộc thương hiệu này
      final productsSnapshot = await _firestore
          .collection("sanpham")
          .where("IdThuongHieu", isEqualTo: widget.idThuongHieu)
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
          const SnackBar(content: Text("Đã ẩn thương hiệu và các sản phẩm liên quan thành công!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isActionInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi ẩn thương hiệu: $e"),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  Future<void> _deleteBrand() async {
    if (_hasConstraints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể xóa thương hiệu vì đang có ràng buộc dữ liệu!")),
      );
      return;
    }

    setState(() => _isActionInProgress = true);
    try {
      await _firestore.collection("thuonghieu").doc(widget.idThuongHieu).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xóa thương hiệu thành công!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isActionInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi xóa thương hiệu: $e"),
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
          _hasConstraints ? "Ẩn thương hiệu" : "Xóa thương hiệu",
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
                          ? "Không thể xóa thương hiệu"
                          : "Xác nhận xóa thương hiệu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasConstraints
                          ? "Thương hiệu này đang được sử dụng trong hệ thống"
                          : "Bạn có chắc chắn muốn xóa thương hiệu này?",
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
                            child: _brandData!["HinhAnh"] != null &&
                                _brandData!["HinhAnh"].toString().isNotEmpty
                                ? Image.network(
                              _brandData!["HinhAnh"].toString(),
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

                        // Thông tin thương hiệu
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
                                "ID: ${widget.idThuongHieu}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _brandData!["TenThuongHieu"] ?? "Không có tên",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Danh mục con: ${_brandData!["IdDanhMucCon"] ?? "Không xác định"}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Trạng thái: ${_brandData!["TrangThai"] ?? "Không xác định"}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _brandData!["TrangThai"] == "Hoạt Động"
                                      ? _successColor
                                      : _errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_brandData!["MoTa"] != null &&
                                  _brandData!["MoTa"].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "Mô tả: ${_brandData!["MoTa"]}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
                                  "Thương hiệu này đang chứa:",
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
                                  "Bạn chỉ có thể ẩn thương hiệu thay vì xóa.",
                                  style: TextStyle(
                                    color: _warningColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _warningColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _warningColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: _warningColor, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Khi ẩn, tất cả sản phẩm thuộc thương hiệu này cũng sẽ được ẩn",
                                          style: TextStyle(
                                            color: _textColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                    ? _hideBrand
                                    : _deleteBrand,
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
                                  _hasConstraints ? "Ẩn thương hiệu" : "Xóa",
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