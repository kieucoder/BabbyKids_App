// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class EditBrandPage extends StatefulWidget {
//   final String idThuongHieu;
//
//   const EditBrandPage({Key? key, required this.idThuongHieu}) : super(key: key);
//
//   @override
//   State<EditBrandPage> createState() => _EditBrandPageState();
// }
//
// class _EditBrandPageState extends State<EditBrandPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Color scheme - Đồng bộ với ListBrand
//   final Color _primaryColor = const Color(0xFF007BFF);
//   final Color _secondaryColor = const Color(0xFFE6F2FF);
//   final Color _backgroundColor = const Color(0xFFF8FAFC);
//   final Color _surfaceColor = Colors.white;
//   final Color _textColor = const Color(0xFF01579B);
//   final Color _hintColor = const Color(0xFF64748B);
//   final Color _successColor = const Color(0xFF10B981);
//   final Color _errorColor = const Color(0xFFEF4444);
//   final Color _borderColor = const Color(0xFFE2E8F0);
//
//   // Controllers
//   final _tenThuongHieuController = TextEditingController();
//   final _hinhAnhController = TextEditingController();
//   final _moTaController = TextEditingController();
//
//   // Dropdown
//   String? _selectedDanhMucCon;
//   String _trangThai = "Hoạt Động";
//
//   List<Map<String, dynamic>> _danhMucConList = [];
//   bool _loading = true;
//   bool _updating = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDanhMucCon();
//     _loadBrandData();
//   }
//
//   Future<void> _loadDanhMucCon() async {
//     try {
//       final snapshot = await _firestore.collection("danhmuccon").get();
//       setState(() {
//         _danhMucConList = snapshot.docs.map((doc) {
//           return {
//             "id": doc["IdDanhMucCon"].toString(),
//             "ten": doc["TenDanhMucCon"].toString(),
//           };
//         }).toList();
//       });
//     } catch (e) {
//       print("Lỗi khi load danh mục con: $e");
//     }
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
//       final data = doc.data()!;
//       _tenThuongHieuController.text = data["TenThuongHieu"] ?? "";
//       _hinhAnhController.text = data["HinhAnh"] ?? "";
//       _moTaController.text = data["MoTa"] ?? "";
//       _selectedDanhMucCon = data["IdDanhMucCon"];
//       _trangThai = data["TrangThai"] ?? "Hoạt Động";
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ Lỗi khi tải dữ liệu: $e")),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _updateBrand() async {
//     if (_tenThuongHieuController.text.isEmpty || _selectedDanhMucCon == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("⚠️ Vui lòng điền đầy đủ thông tin bắt buộc"),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _updating = true);
//
//     try {
//       await _firestore.collection("thuonghieu").doc(widget.idThuongHieu).update({
//         "TenThuongHieu": _tenThuongHieuController.text,
//         "HinhAnh": _hinhAnhController.text,
//         "MoTa": _moTaController.text,
//         "IdDanhMucCon": _selectedDanhMucCon,
//         "TrangThai": _trangThai,
//         "UpdatedAt": FieldValue.serverTimestamp(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("✅ Cập nhật thương hiệu thành công"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Lỗi khi cập nhật: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _updating = false);
//     }
//   }
//
//   // Widget cho input field
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     int? maxLines,
//     bool isRequired = false,
//     Function(String)? onChanged,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: _textColor,
//                   fontSize: 14,
//                 ),
//               ),
//               if (isRequired)
//                 Text(
//                   " *",
//                   style: TextStyle(
//                     color: _errorColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Container(
//             decoration: BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: _borderColor),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 6,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: controller,
//               maxLines: maxLines,
//               onChanged: onChanged,
//               decoration: InputDecoration(
//                 hintText: "Nhập $label",
//                 hintStyle: TextStyle(color: _hintColor),
//                 border: InputBorder.none,
//                 prefixIcon: Icon(icon, color: _primaryColor),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget cho dropdown field
//   Widget _buildDropdownField({
//     required String? value,
//     required List<Map<String, dynamic>> items,
//     required Function(String?) onChanged,
//     required String label,
//     required IconData icon,
//     bool isRequired = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: _textColor,
//                   fontSize: 14,
//                 ),
//               ),
//               if (isRequired)
//                 Text(
//                   " *",
//                   style: TextStyle(
//                     color: _errorColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Container(
//             decoration: BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: _borderColor),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 6,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: DropdownButtonFormField<String>(
//               value: value,
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 prefixIcon: Icon(icon, color: _primaryColor),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               ),
//               hint: Text("Chọn $label", style: TextStyle(color: _hintColor)),
//               items: items.map((item) {
//                 return DropdownMenuItem<String>(
//                   value: item["id"].toString(),
//                   child: Text(
//                     item["ten"].toString(),
//                     style: TextStyle(color: _textColor),
//                   ),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget cho image preview
//   Widget _buildImagePreview() {
//     if (_hinhAnhController.text.isEmpty) {
//       return Container(
//         height: 150,
//         decoration: BoxDecoration(
//           color: _secondaryColor,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _borderColor),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.image_outlined, size: 48, color: _hintColor),
//             const SizedBox(height: 8),
//             Text(
//               "Chưa có hình ảnh",
//               style: TextStyle(color: _hintColor),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Column(
//       children: [
//         Container(
//           height: 200,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: _primaryColor.withOpacity(0.3)),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               _hinhAnhController.text,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: _secondaryColor,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.broken_image_outlined, size: 48, color: _errorColor),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Không thể tải ảnh",
//                         style: TextStyle(color: _errorColor),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Container(
//                   color: _secondaryColor,
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                           : null,
//                       color: _primaryColor,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "Xem trước hình ảnh",
//           style: TextStyle(
//             color: _hintColor,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Widget cho section header
//   Widget _buildSectionHeader(String title, String subtitle) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: _textColor,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           subtitle,
//           style: TextStyle(
//             color: _hintColor,
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Scaffold(
//         backgroundColor: _secondaryColor,
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
//       backgroundColor: _secondaryColor,
//       appBar: AppBar(
//         title: const Text(
//           "Chỉnh sửa thương hiệu",
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
//           if (_updating)
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
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Thông tin cơ bản
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: _surfaceColor,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSectionHeader(
//                     "Thông tin cơ bản",
//                     "Thông tin chính của thương hiệu",
//                   ),
//                   _buildInputField(
//                     controller: _tenThuongHieuController,
//                     label: "Tên thương hiệu",
//                     icon: Icons.branding_watermark_rounded,
//                     isRequired: true,
//                   ),
//                   _buildDropdownField(
//                     value: _selectedDanhMucCon,
//                     items: _danhMucConList,
//                     onChanged: (value) => setState(() => _selectedDanhMucCon = value),
//                     label: "Danh mục con",
//                     icon: Icons.category_rounded,
//                     isRequired: true,
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Trạng thái",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: _textColor,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: _surfaceColor,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: _borderColor),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: DropdownButtonFormField<String>(
//                             value: _trangThai,
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               prefixIcon: Icon(Icons.circle_rounded, color: _primaryColor),
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                             ),
//                             items: [
//                               DropdownMenuItem(
//                                 value: "Hoạt Động",
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.check_circle, color: _successColor, size: 18),
//                                     const SizedBox(width: 8),
//                                     Text("Hoạt Động", style: TextStyle(color: _textColor)),
//                                   ],
//                                 ),
//                               ),
//                               DropdownMenuItem(
//                                 value: "Ngưng Hoạt Động",
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.pause_circle, color: _errorColor, size: 18),
//                                     const SizedBox(width: 8),
//                                     Text("Ngưng Hoạt Động", style: TextStyle(color: _textColor)),
//                                   ],
//                                 ),
//                               ),
//                             ].toList(),
//                             onChanged: (val) => setState(() => _trangThai = val!),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Hình ảnh thương hiệu
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: _surfaceColor,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSectionHeader(
//                     "Hình ảnh thương hiệu",
//                     "URL hình ảnh và xem trước",
//                   ),
//                   _buildInputField(
//                     controller: _hinhAnhController,
//                     label: "URL hình ảnh",
//                     icon: Icons.link_rounded,
//                     onChanged: (value) => setState(() {}),
//                   ),
//                   _buildImagePreview(),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Mô tả thương hiệu
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: _surfaceColor,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSectionHeader(
//                     "Mô tả thương hiệu",
//                     "Thông tin mô tả về thương hiệu",
//                   ),
//                   _buildInputField(
//                     controller: _moTaController,
//                     label: "Mô tả",
//                     icon: Icons.description_rounded,
//                     maxLines: 4,
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             // Nút cập nhật
//             Container(
//               width: double.infinity,
//               height: 56,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [_primaryColor, Color(0xFF0056CC)],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _primaryColor.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ElevatedButton(
//                 onPressed: _updating ? null : _updateBrand,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 ),
//                 child: _updating
//                     ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       "ĐANG CẬP NHẬT...",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 )
//                     : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.save_rounded, color: Colors.white, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "CẬP NHẬT THƯƠNG HIỆU",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
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
//     _tenThuongHieuController.dispose();
//     _hinhAnhController.dispose();
//     _moTaController.dispose();
//     super.dispose();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditBrandPage extends StatefulWidget {
  final String idThuongHieu;

  const EditBrandPage({Key? key, required this.idThuongHieu}) : super(key: key);

  @override
  State<EditBrandPage> createState() => _EditBrandPageState();
}

class _EditBrandPageState extends State<EditBrandPage> {
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

  // Controllers
  final _tenThuongHieuController = TextEditingController();
  final _hinhAnhController = TextEditingController();
  final _moTaController = TextEditingController();

  // Dropdown
  String? _selectedIdDanhMucCon;
  String _trangThai = "Hoạt Động";
  String? _oldTrangThai; // Lưu trạng thái cũ để so sánh

  List<Map<String, dynamic>> _danhMucConList = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadBrandData();
    _loadDanhMucConList();
  }

  Future<void> _loadDanhMucConList() async {
    try {
      final snapshot = await _firestore
          .collection("danhmuccon")
          .where("TrangThai", isEqualTo: "Hoạt Động")
          .get();

      setState(() {
        _danhMucConList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "id": doc.id,
            "ten": data["TenDanhMucCon"] ?? "Không có tên",
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi tải danh mục con: $e"),
          backgroundColor: _errorColor,
        ),
      );
    }
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

      final data = doc.data()!;
      _tenThuongHieuController.text = data["TenThuongHieu"] ?? "";
      _hinhAnhController.text = data["HinhAnh"] ?? "";
      _moTaController.text = data["MoTa"] ?? "";
      _selectedIdDanhMucCon = data["IdDanhMucCon"];
      _trangThai = data["TrangThai"] ?? "Hoạt Động";
      _oldTrangThai = _trangThai;

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

  Future<void> _updateBrand() async {
    if (_tenThuongHieuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên thương hiệu")),
      );
      return;
    }

    if (_selectedIdDanhMucCon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn danh mục con")),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final batch = _firestore.batch();

      // Cập nhật thương hiệu
      final brandRef = _firestore.collection("thuonghieu").doc(widget.idThuongHieu);
      batch.update(brandRef, {
        "TenThuongHieu": _tenThuongHieuController.text.trim(),
        "HinhAnh": _hinhAnhController.text.trim(),
        "MoTa": _moTaController.text.trim(),
        "IdDanhMucCon": _selectedIdDanhMucCon,
        "TrangThai": _trangThai,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // Nếu chuyển từ Hoạt Động sang Ngưng Hoạt Động, ẩn tất cả sản phẩm
      if (_oldTrangThai == "Hoạt Động" && _trangThai == "Ngưng Hoạt Động") {
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
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Cập nhật thương hiệu thành công"),
          backgroundColor: _successColor,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi cập nhật: $e"),
          backgroundColor: _errorColor,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
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
          "Chỉnh sửa thương hiệu",
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
                      "Chỉnh sửa thương hiệu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Cập nhật thông tin cho thương hiệu",
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
                        // Tên thương hiệu
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tên thương hiệu *",
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
                                  controller: _tenThuongHieuController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Nhập tên thương hiệu",
                                    hintStyle: TextStyle(color: _hintColor),
                                    prefixIcon: Icon(Icons.store_mall_directory, color: _primaryColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  style: TextStyle(color: _textColor, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Danh mục con
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Danh mục con *",
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
                                  value: _selectedIdDanhMucCon,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Chọn danh mục con",
                                    hintStyle: TextStyle(color: _hintColor),
                                    prefixIcon: Icon(Icons.category, color: _primaryColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  dropdownColor: _surfaceColor,
                                  style: TextStyle(color: _textColor, fontSize: 14),
                                  items: _danhMucConList
                                      .map((dm) => DropdownMenuItem(
                                    value: dm["id"].toString(),
                                    child: Text(dm["ten"]),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedIdDanhMucCon = value;
                                    });
                                  },
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
                                      color: _warningColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _warningColor),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: _warningColor, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Tất cả sản phẩm thuộc thương hiệu này sẽ được ẩn",
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
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Nút cập nhật
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _updateBrand,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isUpdating
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              "Cập nhật thương hiệu",
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

  @override
  void dispose() {
    _tenThuongHieuController.dispose();
    _hinhAnhController.dispose();

    super.dispose();
  }
}