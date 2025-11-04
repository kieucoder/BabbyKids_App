// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class DeleteProductPage extends StatefulWidget {
//   final String idSanPham;
//
//   const DeleteProductPage({Key? key, required this.idSanPham}) : super(key: key);
//
//   @override
//   State<DeleteProductPage> createState() => _DeleteProductPageState();
// }
//
// class _DeleteProductPageState extends State<DeleteProductPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Color scheme - Đồng bộ với theme chung
//   final Color _primaryColor = const Color(0xFF007BFF);
//   final Color _secondaryColor = const Color(0xFF0056CC);
//   final Color _backgroundColor = const Color(0xFFF8FAFC);
//   final Color _surfaceColor = Colors.white;
//   final Color _textColor = const Color(0xFF1E293B);
//   final Color _hintColor = const Color(0xFF64748B);
//   final Color _successColor = const Color(0xFF10B981);
//   final Color _errorColor = const Color(0xFFEF4444);
//   final Color _warningColor = const Color(0xFFF59E0B);
//   final Color _borderColor = const Color(0xFFE2E8F0);
//
//   // State variables
//   Map<String, dynamic>? _productData;
//   bool _loading = true;
//   bool _deleting = false;
//   bool _canDelete = true;
//   int _orderCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProductData();
//     _checkProductInOrders();
//   }
//
//   Future<void> _loadProductData() async {
//     try {
//       final doc = await _firestore.collection("sanpham").doc(widget.idSanPham).get();
//       if (!doc.exists) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❌ Không tìm thấy sản phẩm")),
//         );
//         Navigator.pop(context);
//         return;
//       }
//
//       setState(() {
//         _productData = doc.data()!;
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
//   Future<void> _checkProductInOrders() async {
//     try {
//       // Kiểm tra trong bảng chi tiết đơn hàng
//       final orderDetailsSnapshot = await _firestore
//           .collection("chitietdonhang")
//           .where("IdSanPham", isEqualTo: widget.idSanPham)
//           .get();
//
//       setState(() {
//         _orderCount = orderDetailsSnapshot.docs.length;
//         _canDelete = _orderCount == 0;
//       });
//     } catch (e) {
//       print("Lỗi khi kiểm tra đơn hàng: $e");
//     }
//   }
//
//   Future<void> _deleteProduct() async {
//     if (!_canDelete) return;
//
//     setState(() => _deleting = true);
//
//     try {
//       await _firestore.collection("sanpham").doc(widget.idSanPham).delete();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("✅ Xóa sản phẩm thành công"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Lỗi khi xóa sản phẩm: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _deleting = false);
//     }
//   }
//
//   String _formatPrice(int price) {
//     return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price);
//   }
//
//   Widget _buildProductInfo() {
//     if (_productData == null) return const SizedBox();
//
//     final price = _productData!["Gia"] ?? 0;
//     final discount = _productData!["PhanTramGiam"] ?? 0;
//     final finalPrice = discount > 0 ? price * (100 - discount) ~/ 100 : price;
//     final isActive = _productData!["TrangThai"] == "Hoạt Động";
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
//           // Header với tên và trạng thái
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Hình ảnh sản phẩm
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: _backgroundColor,
//                 ),
//                 child: _productData!["HinhAnh"] != null && _productData!["HinhAnh"].toString().isNotEmpty
//                     ? ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     _productData!["HinhAnh"].toString(),
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
//                     // Tên sản phẩm
//                     Text(
//                       _productData!["TenSanPham"] ?? "Không có tên",
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
//                     // Giá sản phẩm
//                     if (discount > 0) ...[
//                       Row(
//                         children: [
//                           Text(
//                             _formatPrice(finalPrice),
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: _primaryColor,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             _formatPrice(price),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: _hintColor,
//                               decoration: TextDecoration.lineThrough,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: _errorColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               "-$discount%",
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: _errorColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ] else ...[
//                       Text(
//                         _formatPrice(price),
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: _primaryColor,
//                         ),
//                       ),
//                     ],
//
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
//                   icon: Icons.inventory_2_rounded,
//                   label: "Số lượng tồn",
//                   value: "${_productData!["SoLuong"] ?? 0}",
//                 ),
//                 if (_productData!["DoTuoi"] != null && _productData!["DoTuoi"].toString().isNotEmpty)
//                   _buildDetailItem(
//                     icon: Icons.child_care_rounded,
//                     label: "Độ tuổi",
//                     value: _productData!["DoTuoi"].toString(),
//                   ),
//                 if (_productData!["TrongLuong"] != null && _productData!["TrongLuong"].toString().isNotEmpty)
//                   _buildDetailItem(
//                     icon: Icons.scale_rounded,
//                     label: "Trọng lượng",
//                     value: _productData!["TrongLuong"].toString(),
//                   ),
//                 _buildDetailItem(
//                   icon: Icons.qr_code_rounded,
//                   label: "Mã sản phẩm",
//                   value: _productData!["IdSanPham"] ?? "N/A",
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
//               "Xác nhận xóa sản phẩm",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: _textColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Bạn có chắc chắn muốn xóa sản phẩm này? Hành động này không thể hoàn tác và tất cả dữ liệu liên quan sẽ bị xóa vĩnh viễn.",
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
//               "Không thể xóa sản phẩm",
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
//                   const TextSpan(text: "Sản phẩm này đang được sử dụng trong "),
//                   TextSpan(
//                     text: "$_orderCount đơn hàng",
//                     style: TextStyle(
//                       color: _errorColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const TextSpan(text: ". Bạn không thể xóa sản phẩm đã có trong đơn hàng."),
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
//                       "Để xóa sản phẩm, trước tiên cần xóa/hủy tất cả đơn hàng có chứa sản phẩm này",
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
//                 "Đang tải thông tin sản phẩm...",
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
//           "Xóa sản phẩm",
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: _errorColor,
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
//             // Thông tin sản phẩm
//             _buildProductInfo(),
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
//                         onPressed: _deleting ? null : _deleteProduct,
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
//                               "XÓA SẢN PHẨM",
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
//                   color: _surfaceColor,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: _borderColor),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: TextButton.styleFrom(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.arrow_back_rounded, color: _primaryColor, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         "QUAY LẠI DANH SÁCH",
//                         style: TextStyle(
//                           color: _primaryColor,
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
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeleteProductPage extends StatefulWidget {
  final String idSanPham;

  const DeleteProductPage({Key? key, required this.idSanPham}) : super(key: key);

  @override
  State<DeleteProductPage> createState() => _DeleteProductPageState();
}

class _DeleteProductPageState extends State<DeleteProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Color scheme - Đồng bộ với theme mới
  final Color _primaryColor = Color(0xFF2563EB); // Xanh dương tinh tế
  final Color _secondaryColor = Color(0xFF60A5FA); // Xanh dương nhạt
  final Color _backgroundColor = Color(0xFFF8FAFC);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = Color(0xFF1E293B);
  final Color _hintColor = Color(0xFF64748B);
  final Color _successColor = Color(0xFF10B981);
  final Color _errorColor = Color(0xFFEF4444);
  final Color _warningColor = Color(0xFFF59E0B);
  final Color _borderColor = Color(0xFFE2E8F0);

  // State variables
  Map<String, dynamic>? _productData;
  bool _loading = true;
  bool _deleting = false;
  bool _canDelete = true;
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProductData();
    _checkProductInOrders();
  }

  Future<void> _loadProductData() async {
    try {
      final doc = await _firestore.collection("sanpham").doc(widget.idSanPham).get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Không tìm thấy sản phẩm")),
        );
        Navigator.pop(context);
        return;
      }

      setState(() {
        _productData = doc.data()!;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi khi tải dữ liệu: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkProductInOrders() async {
    try {
      // Kiểm tra trong bảng chi tiết đơn hàng
      final orderDetailsSnapshot = await _firestore
          .collection("chitietdonhang")
          .where("IdSanPham", isEqualTo: widget.idSanPham)
          .get();

      setState(() {
        _orderCount = orderDetailsSnapshot.docs.length;
        _canDelete = _orderCount == 0;
      });
    } catch (e) {
      print("Lỗi khi kiểm tra đơn hàng: $e");
    }
  }

  Future<void> _deleteProduct() async {
    if (!_canDelete) return;

    setState(() => _deleting = true);

    try {
      await _firestore.collection("sanpham").doc(widget.idSanPham).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Xóa sản phẩm thành công"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Lỗi khi xóa sản phẩm: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _deleting = false);
    }
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price);
  }

  Widget _buildProductInfo() {
    if (_productData == null) return const SizedBox();

    final price = _productData!["Gia"] ?? 0;
    final discount = _productData!["PhanTramGiam"] ?? 0;
    final finalPrice = discount > 0 ? price * (100 - discount) ~/ 100 : price;
    final isActive = _productData!["TrangThai"] == "Hoạt Động";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
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
          // Header với tên và trạng thái
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh sản phẩm
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _backgroundColor,
                ),
                child: _productData!["HinhAnh"] != null && _productData!["HinhAnh"].toString().isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _productData!["HinhAnh"].toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _backgroundColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_rounded, color: _hintColor, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              "No Image",
                              style: TextStyle(
                                fontSize: 10,
                                color: _hintColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, color: _hintColor, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      "No Image",
                      style: TextStyle(
                        fontSize: 10,
                        color: _hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sản phẩm
                    Text(
                      _productData!["TenSanPham"] ?? "Không có tên",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Giá sản phẩm
                    if (discount > 0) ...[
                      Row(
                        children: [
                          Text(
                            _formatPrice(finalPrice),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatPrice(price),
                            style: TextStyle(
                              fontSize: 12,
                              color: _hintColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "-$discount%",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        _formatPrice(price),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Trạng thái
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? _successColor.withOpacity(0.1)
                            : _errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? _successColor : _errorColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isActive ? "🟢 Hoạt động" : "🔴 Ngưng hoạt động",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive ? _successColor : _errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Thông tin chi tiết
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailItem(
                  icon: Icons.inventory_2_rounded,
                  label: "Số lượng tồn",
                  value: "${_productData!["SoLuong"] ?? 0}",
                ),
                if (_productData!["DoTuoi"] != null && _productData!["DoTuoi"].toString().isNotEmpty)
                  _buildDetailItem(
                    icon: Icons.child_care_rounded,
                    label: "Độ tuổi",
                    value: _productData!["DoTuoi"].toString(),
                  ),
                if (_productData!["TrongLuong"] != null && _productData!["TrongLuong"].toString().isNotEmpty)
                  _buildDetailItem(
                    icon: Icons.scale_rounded,
                    label: "Trọng lượng",
                    value: _productData!["TrongLuong"].toString(),
                  ),
                _buildDetailItem(
                  icon: Icons.qr_code_rounded,
                  label: "Mã sản phẩm",
                  value: _productData!["IdSanPham"] ?? "N/A",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _hintColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: _hintColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    if (_canDelete) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _warningColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _warningColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, size: 32, color: _warningColor),
            ),
            const SizedBox(height: 16),
            Text(
              "Xác nhận xóa sản phẩm",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Bạn có chắc chắn muốn xóa sản phẩm này? Hành động này không thể hoàn tác và tất cả dữ liệu liên quan sẽ bị xóa vĩnh viễn.",
              style: TextStyle(
                color: _hintColor,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _errorColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _errorColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 32, color: _errorColor),
            ),
            const SizedBox(height: 16),
            Text(
              "Không thể xóa sản phẩm",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: _hintColor,
                  fontSize: 14,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "Sản phẩm này đang được sử dụng trong "),
                  TextSpan(
                    text: "$_orderCount đơn hàng",
                    style: TextStyle(
                      color: _errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ". Bạn không thể xóa sản phẩm đã có trong đơn hàng."),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: _errorColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Để xóa sản phẩm, trước tiên cần xóa/hủy tất cả đơn hàng có chứa sản phẩm này",
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
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _primaryColor),
              const SizedBox(height: 16),
              Text(
                "Đang tải thông tin sản phẩm...",
                style: TextStyle(
                  color: _textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Xóa sản phẩm",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryColor, // Sử dụng primaryColor mới
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_deleting)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Thông tin sản phẩm
            _buildProductInfo(),

            const SizedBox(height: 24),

            // Cảnh báo hoặc thông báo không thể xóa
            _buildWarningMessage(),

            const SizedBox(height: 32),

            // Nút hành động
            if (_canDelete) ...[
              // Nút xóa và hủy khi có thể xóa
              Row(
                children: [
                  // Nút hủy
                  Expanded(
                    child: Container(
                      height: 56,
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
                      child: TextButton(
                        onPressed: _deleting ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "HỦY",
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nút xóa - Giữ màu đỏ để cảnh báo nguy hiểm
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_errorColor, Color(0xFFDC2626)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _errorColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _deleting ? null : _deleteProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _deleting
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "ĐANG XÓA...",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "XÓA SẢN PHẨM",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ] else ...[
              // Chỉ nút quay lại khi không thể xóa - Sử dụng primaryColor mới
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "QUAY LẠI DANH SÁCH",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}