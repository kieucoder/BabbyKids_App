//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class AddBrandPage extends StatefulWidget {
//   const AddBrandPage({super.key});
//
//   @override
//   State<AddBrandPage> createState() => _AddBrandPageState();
// }
//
// class _AddBrandPageState extends State<AddBrandPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _tenThuongHieuController = TextEditingController();
//   final TextEditingController _hinhAnhController = TextEditingController();
//
//   String _trangThai = "Hoạt Động";
//   String? _selectedIdDanhMucCon;
//
//   // Color scheme đồng bộ với AddSubCategory
//   final Color _primaryColor = const Color(0xFF007BFF);
//   final Color _backgroundColor = const Color(0xFFF8F9FA);
//   final Color _surfaceColor = const Color(0xFFFFFFFF);
//   final Color _textColor = const Color(0xFF212529);
//   final Color _borderColor = const Color(0xFFDEE2E6);
//   final Color _successColor = const Color(0xFF28A745);
//   final Color _errorColor = const Color(0xFFDC3545);
//   final Color _hintColor = const Color(0xFF6C757D);
//
//   List<Map<String, dynamic>> _danhMucConList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDanhMucConList();
//   }
//
//   Future<void> _loadDanhMucConList() async {
//     try {
//       final snapshot = await _firestore
//           .collection('danhmuccon')
//           .where("TrangThai", isEqualTo: "Hoạt Động") // Chỉ load danh mục con đang hoạt động
//           .get();
//
//       _danhMucConList = snapshot.docs.map((doc) {
//         final data = doc.data();
//         data['IdDanhMucCon'] = doc.id;
//         return data;
//       }).toList();
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Lỗi tải danh mục con: $e"),
//           backgroundColor: _errorColor,
//         ),
//       );
//     }
//   }
//
//   Future<String> _getNextBrandId() async {
//     final snapshot = await _firestore
//         .collection('thuonghieu')
//         .orderBy('IdThuongHieu', descending: true)
//         .limit(1)
//         .get();
//
//     String newId = "TH01";
//     if (snapshot.docs.isNotEmpty) {
//       final lastId = snapshot.docs.first["IdThuongHieu"];
//       final number = int.tryParse(lastId.substring(2)) ?? 0;
//       newId = "TH${(number + 1).toString().padLeft(2, '0')}";
//     }
//     return newId;
//   }
//
//   Future<void> _addBrand() async {
//     if (_tenThuongHieuController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Vui lòng nhập tên thương hiệu")),
//       );
//       return;
//     }
//
//     if (_selectedIdDanhMucCon == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Vui lòng chọn danh mục con")),
//       );
//       return;
//     }
//
//     try {
//       String newId = await _getNextBrandId();
//
//       await _firestore.collection("thuonghieu").doc(newId).set({
//         "IdThuongHieu": newId,
//         "TenThuongHieu": _tenThuongHieuController.text.trim(),
//         "HinhAnh": _hinhAnhController.text.trim(),
//         "TrangThai": _trangThai,
//         "IdDanhMucCon": _selectedIdDanhMucCon,
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("✅ Thêm thương hiệu $newId thành công!"),
//           backgroundColor: _successColor,
//         ),
//       );
//
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Lỗi khi thêm thương hiệu: $e"),
//           backgroundColor: _errorColor,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Thêm thương hiệu",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: _primaryColor,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 600),
//           margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//           child: Column(
//             children: [
//               // Header Card
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: _surfaceColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Thông tin thương hiệu",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: _textColor,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Nhập thông tin cơ bản cho thương hiệu mới",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: _hintColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Form Card
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: _surfaceColor,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Tên thương hiệu
//                         Container(
//                           margin: const EdgeInsets.only(bottom: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Tên thương hiệu *",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: _textColor,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: _surfaceColor,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: _borderColor),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.05),
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: TextField(
//                                   controller: _tenThuongHieuController,
//                                   decoration: InputDecoration(
//                                     border: InputBorder.none,
//                                     hintText: "Nhập tên thương hiệu",
//                                     hintStyle: TextStyle(color: _hintColor),
//                                     prefixIcon: Icon(Icons.store_mall_directory, color: _primaryColor),
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                                   ),
//                                   style: TextStyle(color: _textColor, fontSize: 14),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // Danh mục con
//                         Container(
//                           margin: const EdgeInsets.only(bottom: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Danh mục con *",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: _textColor,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: _surfaceColor,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: _borderColor),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.05),
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: DropdownButtonFormField<String>(
//                                   value: _selectedIdDanhMucCon,
//                                   isExpanded: true,
//                                   decoration: InputDecoration(
//                                     border: InputBorder.none,
//                                     hintText: "Chọn danh mục con",
//                                     hintStyle: TextStyle(color: _hintColor),
//                                     prefixIcon: Icon(Icons.category, color: _primaryColor),
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                                   ),
//                                   dropdownColor: _surfaceColor,
//                                   style: TextStyle(color: _textColor, fontSize: 14),
//                                   items: _danhMucConList
//                                       .map((dm) => DropdownMenuItem(
//                                     value: dm["IdDanhMucCon"].toString(),
//                                     child: Text(
//                                       dm["TenDanhMucCon"] ?? "Không có tên",
//                                       style: TextStyle(color: _textColor),
//                                     ),
//                                   ))
//                                       .toList(),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _selectedIdDanhMucCon = value;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // Hình ảnh
//                         Container(
//                           margin: const EdgeInsets.only(bottom: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "URL hình ảnh",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: _textColor,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: _surfaceColor,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: _borderColor),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.05),
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: TextField(
//                                   controller: _hinhAnhController,
//                                   decoration: InputDecoration(
//                                     border: InputBorder.none,
//                                     hintText: "https://...",
//                                     hintStyle: TextStyle(color: _hintColor),
//                                     prefixIcon: Icon(Icons.link, color: _primaryColor),
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                                   ),
//                                   style: TextStyle(color: _textColor, fontSize: 14),
//                                   onChanged: (v) => setState(() {}),
//                                 ),
//                               ),
//
//                               // Preview Image
//                               if (_hinhAnhController.text.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 12),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Xem trước hình ảnh",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           color: _textColor,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Container(
//                                         width: double.infinity,
//                                         height: 200,
//                                         decoration: BoxDecoration(
//                                           color: _backgroundColor,
//                                           borderRadius: BorderRadius.circular(12),
//                                           border: Border.all(color: _borderColor),
//                                         ),
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.circular(12),
//                                           child: Image.network(
//                                             _hinhAnhController.text,
//                                             width: double.infinity,
//                                             height: 200,
//                                             fit: BoxFit.contain,
//                                             loadingBuilder: (context, child, loadingProgress) {
//                                               if (loadingProgress == null) return child;
//                                               return Container(
//                                                 height: 200,
//                                                 alignment: Alignment.center,
//                                                 child: CircularProgressIndicator(
//                                                   value: loadingProgress.expectedTotalBytes != null
//                                                       ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                                       : null,
//                                                   color: _primaryColor,
//                                                 ),
//                                               );
//                                             },
//                                             errorBuilder: (context, error, stack) => Container(
//                                               height: 200,
//                                               width: double.infinity,
//                                               alignment: Alignment.center,
//                                               child: Column(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: [
//                                                   Icon(Icons.error_outline, color: _hintColor, size: 40),
//                                                   const SizedBox(height: 8),
//                                                   Text(
//                                                     "Không tải được ảnh",
//                                                     style: TextStyle(color: _hintColor),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//
//                         // Trạng thái
//                         Container(
//                           margin: const EdgeInsets.only(bottom: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Trạng thái *",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: _textColor,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: _surfaceColor,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: _borderColor),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.05),
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: DropdownButtonFormField<String>(
//                                   value: _trangThai,
//                                   isExpanded: true,
//                                   decoration: InputDecoration(
//                                     border: InputBorder.none,
//                                     prefixIcon: Container(
//                                       width: 24,
//                                       height: 24,
//                                       alignment: Alignment.center,
//                                       child: Icon(Icons.circle_rounded, color: _primaryColor, size: 18),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                                   ),
//                                   dropdownColor: _surfaceColor,
//                                   style: TextStyle(color: _textColor, fontSize: 14),
//                                   items: [
//                                     DropdownMenuItem(
//                                       value: "Hoạt Động",
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(vertical: 4),
//                                         child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.start,
//                                           children: [
//                                             Icon(Icons.check_circle, color: _successColor, size: 20),
//                                             const SizedBox(width: 12),
//                                             Expanded(
//                                               child: Text(
//                                                 "Hoạt Động",
//                                                 style: TextStyle(color: _textColor, fontSize: 14),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     DropdownMenuItem(
//                                       value: "Ngưng Hoạt Động",
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(vertical: 4),
//                                         child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.start,
//                                           children: [
//                                             Icon(Icons.pause_circle, color: _errorColor, size: 20),
//                                             const SizedBox(width: 12),
//                                             Expanded(
//                                               child: Text(
//                                                 "Ngưng Hoạt Động",
//                                                 style: TextStyle(color: _textColor, fontSize: 14),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                   onChanged: (val) => setState(() => _trangThai = val!),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 8),
//
//                         // Nút lưu
//                         Container(
//                           margin: const EdgeInsets.only(top: 16),
//                           child: ElevatedButton(
//                             onPressed: _addBrand,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _primaryColor,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 2,
//                             ),
//                             child: const Text(
//                               "Lưu thương hiệu",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBrandPage extends StatefulWidget {
  const AddBrandPage({super.key});

  @override
  State<AddBrandPage> createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _tenThuongHieuController = TextEditingController();
  final TextEditingController _hinhAnhController = TextEditingController();

  String _trangThai = "Hoạt Động";
  String? _selectedIdDanhMuc;
  String? _selectedIdDanhMucCon;

  // Color scheme đồng bộ với AddSubCategory
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _textColor = const Color(0xFF212529);
  final Color _borderColor = const Color(0xFFDEE2E6);
  final Color _successColor = const Color(0xFF28A745);
  final Color _errorColor = const Color(0xFFDC3545);
  final Color _hintColor = const Color(0xFF6C757D);

  List<Map<String, dynamic>> _danhMucList = [];
  List<Map<String, dynamic>> _danhMucConList = [];
  List<Map<String, dynamic>> _filteredDanhMucConList = [];

  @override
  void initState() {
    super.initState();
    _loadDanhMucList();
  }

  Future<void> _loadDanhMucList() async {
    try {
      final snapshot = await _firestore
          .collection('danhmuc')
          .where("TrangThai", isEqualTo: "Hoạt Động")
          .get();

      setState(() {
        _danhMucList = snapshot.docs.map((doc) {
          final data = doc.data();
          data['IdDanhMuc'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi tải danh mục: $e"),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  Future<void> _loadDanhMucConList(String idDanhMuc) async {
    try {
      final snapshot = await _firestore
          .collection('danhmuccon')
          .where("IdDanhMuc", isEqualTo: idDanhMuc)
          .where("TrangThai", isEqualTo: "Hoạt Động")
          .get();

      setState(() {
        _danhMucConList = snapshot.docs.map((doc) {
          final data = doc.data();
          data['IdDanhMucCon'] = doc.id;
          return data;
        }).toList();
        _filteredDanhMucConList = _danhMucConList;
        // Reset selected subcategory when category changes
        _selectedIdDanhMucCon = null;
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

  void _filterDanhMucCon(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredDanhMucConList = _danhMucConList;
      } else {
        _filteredDanhMucConList = _danhMucConList.where((dm) {
          final tenDanhMucCon = dm["TenDanhMucCon"]?.toString().toLowerCase() ?? "";
          return tenDanhMucCon.contains(searchText.toLowerCase());
        }).toList();
      }
    });
  }

  Future<String> _getNextBrandId() async {
    final snapshot = await _firestore
        .collection('thuonghieu')
        .orderBy('IdThuongHieu', descending: true)
        .limit(1)
        .get();

    String newId = "TH01";
    if (snapshot.docs.isNotEmpty) {
      final lastId = snapshot.docs.first["IdThuongHieu"];
      final number = int.tryParse(lastId.substring(2)) ?? 0;
      newId = "TH${(number + 1).toString().padLeft(2, '0')}";
    }
    return newId;
  }

  Future<void> _addBrand() async {
    if (_tenThuongHieuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên thương hiệu")),
      );
      return;
    }

    if (_selectedIdDanhMuc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn danh mục")),
      );
      return;
    }

    if (_selectedIdDanhMucCon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn danh mục con")),
      );
      return;
    }

    try {
      String newId = await _getNextBrandId();

      await _firestore.collection("thuonghieu").doc(newId).set({
        "IdThuongHieu": newId,
        "TenThuongHieu": _tenThuongHieuController.text.trim(),
        "HinhAnh": _hinhAnhController.text.trim(),
        "TrangThai": _trangThai,
        "IdDanhMuc": _selectedIdDanhMuc,
        "IdDanhMucCon": _selectedIdDanhMucCon,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Thêm thương hiệu $newId thành công!"),
          backgroundColor: _successColor,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi thêm thương hiệu: $e"),
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
          "Thêm thương hiệu",
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
      body: Center(
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
                      "Thông tin thương hiệu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nhập thông tin cơ bản cho thương hiệu mới",
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

                        // Danh mục
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Danh mục *",
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
                                  value: _selectedIdDanhMuc,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Chọn danh mục",
                                    hintStyle: TextStyle(color: _hintColor),
                                    prefixIcon: Icon(Icons.category, color: _primaryColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  dropdownColor: _surfaceColor,
                                  style: TextStyle(color: _textColor, fontSize: 14),
                                  items: _danhMucList
                                      .map((dm) => DropdownMenuItem(
                                    value: dm["IdDanhMuc"].toString(),
                                    child: Text(
                                      dm["Ten"] ?? "Không có tên",
                                      style: TextStyle(color: _textColor),
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedIdDanhMuc = value;
                                      _selectedIdDanhMucCon = null;
                                    });
                                    if (value != null) {
                                      _loadDanhMucConList(value);
                                    }
                                  },
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
                              Row(
                                children: [
                                  Text(
                                    "Danh mục con *",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _textColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
                                    hintText: _selectedIdDanhMuc == null
                                        ? "Vui lòng chọn danh mục trước"
                                        : "Chọn danh mục con",
                                    hintStyle: TextStyle(color: _hintColor),
                                    prefixIcon: Icon(Icons.subdirectory_arrow_right, color: _primaryColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  dropdownColor: _surfaceColor,
                                  style: TextStyle(color: _textColor, fontSize: 14),
                                  items: _selectedIdDanhMuc == null
                                      ? []
                                      : _filteredDanhMucConList
                                      .map((dm) => DropdownMenuItem(
                                    value: dm["IdDanhMucCon"].toString(),
                                    child: Text(
                                      dm["TenDanhMucCon"] ?? "Không có tên",
                                      style: TextStyle(color: _textColor),
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: _selectedIdDanhMuc == null
                                      ? null
                                      : (value) {
                                    setState(() {
                                      _selectedIdDanhMucCon = value;
                                    });
                                  },
                                ),
                              ),
                              if (_selectedIdDanhMuc != null && _filteredDanhMucConList.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Không có danh mục con nào cho danh mục này",
                                    style: TextStyle(
                                      color: _hintColor,
                                      fontSize: 12,
                                    ),
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Nút lưu
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: ElevatedButton(
                            onPressed: _addBrand,
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
                              "Lưu thương hiệu",
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