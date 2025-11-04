//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AddCategoryPage extends StatefulWidget {
//   const AddCategoryPage({super.key});
//
//   @override
//   _AddCategoryPageState createState() => _AddCategoryPageState();
// }
//
// class _AddCategoryPageState extends State<AddCategoryPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _tenController = TextEditingController();
//   final TextEditingController _hinhAnhController = TextEditingController();
//   String _trangThai = "Hoạt Động";
//
//   Future<void> _addCategory() async {
//     if (_tenController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text(" Vui lòng nhập tên danh mục")),
//       );
//       return;
//     }
//
//     try {
//       // 🔹 Lấy danh sách danh mục hiện có, sắp xếp giảm dần theo IdDanhMuc
//       final snapshot = await _firestore
//           .collection("danhmuc")
//           .orderBy("IdDanhMuc", descending: true)
//           .limit(1)
//           .get();
//
//       // 🔹 Tạo mã mới (DM01, DM02, …)
//       String newId = "DM01";
//       if (snapshot.docs.isNotEmpty) {
//         final lastId = snapshot.docs.first["IdDanhMuc"]; // ví dụ: DM03
//         final number = int.tryParse(lastId.substring(2)) ?? 0;
//         final nextNumber = number + 1;
//         newId = "DM${nextNumber.toString().padLeft(2, '0')}";
//       }
//
//       // 🔹 Lưu vào Firestore
//       await _firestore.collection("danhmuc").doc(newId).set({
//         "IdDanhMuc": newId,
//         "Ten": _tenController.text,
//         "HinhAnh": _hinhAnhController.text,
//         "TrangThai": _trangThai,
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Đã thêm danh mục $newId thành công!")),
//       );
//
//       _tenController.clear();
//       _hinhAnhController.clear();
//       setState(() => _trangThai = "Hoạt Động");
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(" Lỗi khi thêm danh mục: $e")),
//       );
//     }
//   }
//
//   @override
//
//   Widget build(BuildContext context) {
//     final Color mainBlue = const Color(0xFF007BFF);
//     final Color lightBlue = const Color(0xFFe6f2ff);
//
//     return Scaffold(
//       backgroundColor: lightBlue,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,color: Colors.white,),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Thêm danh mục",
//           style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
//         ),
//         backgroundColor: mainBlue,
//         elevation: 3,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 600),
//           margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
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
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Text(
//                   "Thông tin danh mục",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.blueAccent,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Tên danh mục
//                 TextField(
//                   controller: _tenController,
//                   decoration: InputDecoration(
//                     labelText: "Tên danh mục",
//                     prefixIcon: const Icon(Icons.category_outlined, color: Colors.blueAccent),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(color: mainBlue, width: 2),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     filled: true,
//                     fillColor: Colors.blue.shade50.withOpacity(0.3),
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//
//                 // Hình ảnh
//                 TextField(
//                   controller: _hinhAnhController,
//                   decoration: InputDecoration(
//                     labelText: "Link hình ảnh (https...)",
//                     prefixIcon: const Icon(Icons.image_outlined, color: Colors.blueAccent),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(color: mainBlue, width: 2),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     filled: true,
//                     fillColor: Colors.blue.shade50.withOpacity(0.3),
//                   ),
//                   onChanged: (v) => setState(() {}),
//                 ),
//
//                 if (_hinhAnhController.text.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 12),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         _hinhAnhController.text,
//                         height: 140,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stack) => Container(
//                           height: 140,
//                           color: Colors.grey[200],
//                           alignment: Alignment.center,
//                           child: const Text(" Không tải được ảnh"),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                 const SizedBox(height: 18),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.shade100.withOpacity(0.4),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: DropdownButtonFormField<String>(
//                     value: _trangThai,
//                     dropdownColor: Colors.white,
//                     isExpanded: true,
//                     icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
//                     decoration: InputDecoration(
//                       labelText: "Trạng thái danh mục",
//                       prefixIcon: const Icon(Icons.toggle_on_outlined, color: Colors.blueAccent),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide(color: Colors.blueAccent, width: 2),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//                       filled: true,
//                       fillColor: Colors.transparent,
//                     ),
//                     items: [
//                       DropdownMenuItem(
//                         value: "Hoạt Động",
//                         child: Row(
//                           children: const [
//                             // Icon(Icons.check_circle, color: Colors.green, size: 20),
//                             SizedBox(width: 8),
//                             Text("Hoạt Động", style: TextStyle(color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                       DropdownMenuItem(
//                         value: "Ngưng Hoạt Động",
//                         child: Row(
//                           children: const [
//                             // Icon(Icons.pause_circle_filled, color: Colors.redAccent, size: 20),
//                             SizedBox(width: 8),
//                             Text("Ngưng Hoạt Động", style: TextStyle(color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                     ],
//                     onChanged: (v) => setState(() => _trangThai = v!),
//                   ),
//                 ),
//
//                 const SizedBox(height: 28),
//
//                 // Nút lưu
//                 ElevatedButton.icon(
//                   onPressed: _addCategory,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: mainBlue,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     elevation: 4,
//                     shadowColor: Colors.blueAccent.withOpacity(0.4),
//                   ),
//                   icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
//                   label: const Text(
//                     "Lưu danh mục",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       letterSpacing: 0.5,
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
//
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _tenController = TextEditingController();
  final TextEditingController _hinhAnhController = TextEditingController();
  String _trangThai = "Hoạt Động";

  // Colors
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _textColor = const Color(0xFF212529);
  final Color _borderColor = const Color(0xFFDEE2E6);
  final Color _successColor = const Color(0xFF28A745);
  final Color _errorColor = const Color(0xFFDC3545);
  final Color _hintColor = const Color(0xFF6C757D);

  Future<void> _addCategory() async {
    if (_tenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên danh mục")),
      );
      return;
    }

    try {
      final snapshot = await _firestore
          .collection("danhmuc")
          .orderBy("IdDanhMuc", descending: true)
          .limit(1)
          .get();

      String newId = "DM01";
      if (snapshot.docs.isNotEmpty) {
        final lastId = snapshot.docs.first["IdDanhMuc"];
        final number = int.tryParse(lastId.substring(2)) ?? 0;
        final nextNumber = number + 1;
        newId = "DM${nextNumber.toString().padLeft(2, '0')}";
      }

      await _firestore.collection("danhmuc").doc(newId).set({
        "IdDanhMuc": newId,
        "Ten": _tenController.text,
        "HinhAnh": _hinhAnhController.text,
        "TrangThai": _trangThai,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm danh mục $newId thành công!"),
          backgroundColor: _successColor,
        ),
      );




      _tenController.clear();
      _hinhAnhController.clear();
      Navigator.pop(context, true);
      setState(() => _trangThai = "Hoạt Động");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi thêm danh mục: $e"),
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
          "Thêm danh mục",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                      "Thông tin danh mục",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nhập thông tin cơ bản cho danh mục mới",
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
                        // Tên danh mục
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tên danh mục *",
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
                                    hintText: "Nhập tên danh mục",
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
                                  padding: const EdgeInsets.only(top: 18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Xem trước",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          _hinhAnhController.text,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stack) => Container(
                                            height: 200,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: _backgroundColor,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: _borderColor),
                                            ),
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error_outline, color: _hintColor, size: 32),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Không tải được ảnh",
                                                  style: TextStyle(color: _hintColor),
                                                ),
                                              ],
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
                            onPressed: _addCategory,
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
                              "Lưu danh mục",
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