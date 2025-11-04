// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// class AddSubCategory extends StatefulWidget {
//   const AddSubCategory({super.key});
//
//   @override
//   State<AddSubCategory> createState() => _AddSubCategoryState();
// }
//
// class _AddSubCategoryState extends State<AddSubCategory> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _TenDanhMucController = TextEditingController();
//   final TextEditingController _HinhAnhController = TextEditingController();
//   String _TrangThai = "Hoạt Động";
//   String? _selectedIdDanhMucCha; // Lưu ID danh mục cha đã chọn
//
//
//   List<Map<String,dynamic>> _danhMucCha = [];
//
//   Future<void> _loadDanhMucCha() async{
//     final snapshot = await FirebaseFirestore.instance
//         .collection('danhmuc')
//         .get();
//     _danhMucCha = snapshot.docs.map((doc){
//       final data = doc.data();
//       data['IdDanhMuc'] = doc.id; //lưu lại id
//       return data;
//     }).toList();
//     setState(() {
//
//     });
//   }
//   Future<void> _addSubCategory() async {
//     if (_TenDanhMucController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Vui lòng nhập tên danh mục con")),
//       );
//       return;
//     }
//     if (_HinhAnhController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Vui lòng nhập link hình ảnh")),
//       );
//       return;
//     }
//     if (_selectedIdDanhMucCha == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Vui lòng chọn danh mục cha")),
//       );
//       return;
//     }
//
//
//     try{
//       // 🔹 Lấy danh sách danh mục con hiện có, sắp xếp giảm dần theo IdDanhMucCon
//       final snapshot = await _firestore
//           .collection("danhmuccon")
//           .orderBy("IdDanhMucCon", descending: true)
//           .limit(1)
//           .get();
//
//       // 🔹 Tạo Id mới cho danh mục con
//       String newId = "DMC01";
//       if (snapshot.docs.isNotEmpty) {
//         final lastId = snapshot.docs.first["IdDanhMucCon"]; // ví dụ: DMC03
//         final number = int.tryParse(lastId.substring(3)) ?? 0; // bỏ 'DMC'
//         final nextNumber = number + 1;
//         newId = "DMC${nextNumber.toString().padLeft(2, '0')}";
//       }
//
//       // 🔹 Thêm danh mục con, liên kết với danh mục cha
//       await _firestore.collection("danhmuccon").doc(newId).set({
//         "IdDanhMucCon": newId,
//         "TenDanhMucCon": _TenDanhMucController.text.trim(),
//         "HinhAnh": _HinhAnhController.text.trim(),
//         "TrangThai": _TrangThai,
//         "IdDanhMuc": _selectedIdDanhMucCha, // 🔹 Đây là ID danh mục cha đã chọn
//       });
//
//
//       _TenDanhMucController.clear();
//       _HinhAnhController.clear();
//       _selectedIdDanhMucCha = null;
//       // 🔹 Nếu bạn muốn reset trạng thái về mặc định
//       _TrangThai = "Hoạt Động";
//       // 🔹 Cập nhật lại giao diện
//       setState(() {});
//       // Hiển thị thông báo thành công
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Đã thêm danh mục con $newId thành công!")),
//       );
//       Navigator.pop(context, true); // true để ListSubCategory biết cần reload
//     }catch(e){
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi khi thêm danh mục con: $e"))
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDanhMucCha();
//   }
//
//
//
//   final Color mainBlue = const Color(0xFF007BFF);
//   final Color lightBlue = const Color(0xFFE6F2FF);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: lightBlue,
//       appBar: AppBar(
//         title: Text("Thêm danh mục con",
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),),
//         centerTitle: true ,
//         elevation: 3,
//         backgroundColor: mainBlue,
//         leading: IconButton(
//             icon: Icon(Icons.arrow_back,color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           }
//         ),
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
//                   "Thông tin danh mục con",
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
//                   controller: _TenDanhMucController,
//                   decoration: InputDecoration(
//                     labelText: "Tên danh mục con",
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
//                   controller: _HinhAnhController,
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
//                 if (_HinhAnhController.text.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 12),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         _HinhAnhController.text,
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
//                 const SizedBox(height: 18),
//                 DropdownButtonFormField<String>(
//                   value: _selectedIdDanhMucCha,
//                   decoration: InputDecoration(
//                     labelText: "Chọn danh mục cha",
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                     filled: true,
//                     fillColor: Colors.blue.shade50.withOpacity(0.3),
//                   ),
//                   items: _danhMucCha.map((dm) {
//                     return DropdownMenuItem(
//                       value: dm['IdDanhMuc'].toString(),
//                       child: Text(dm['Ten'] ?? ''),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedIdDanhMucCha = value;
//                     });
//                   },
//                 ),
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
//                     value: _TrangThai,
//                     dropdownColor: Colors.white,
//                     isExpanded: true,
//                     icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
//                     decoration: InputDecoration(
//                       labelText: "Trạng thái danh mục con",
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
//                     onChanged: (v) => setState(() => _TrangThai
//                     = v!),
//                   ),
//                 ),
//
//                 const SizedBox(height: 28),
//
//                 // Nút lưu
//                 ElevatedButton.icon(
//                   onPressed: _addSubCategory,
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
//                     "Lưu danh mục con",
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
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSubCategory extends StatefulWidget {
  const AddSubCategory({super.key});

  @override
  State<AddSubCategory> createState() => _AddSubCategoryState();
}

class _AddSubCategoryState extends State<AddSubCategory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _tenDanhMucController = TextEditingController();
  final TextEditingController _hinhAnhController = TextEditingController();
  String _trangThai = "Hoạt Động";
  String? _selectedIdDanhMucCha;

  List<Map<String, dynamic>> _danhMucCha = [];

  // Color scheme đồng bộ với AddCategory
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _textColor = const Color(0xFF212529);
  final Color _borderColor = const Color(0xFFDEE2E6);
  final Color _successColor = const Color(0xFF28A745);
  final Color _errorColor = const Color(0xFFDC3545);
  final Color _hintColor = const Color(0xFF6C757D);

  Future<void> _loadDanhMucCha() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('danhmuc')
        .where("TrangThai", isEqualTo: "Hoạt Động") // Chỉ load danh mục đang hoạt động
        .get();

    _danhMucCha = snapshot.docs.map((doc) {
      final data = doc.data();
      data['IdDanhMuc'] = doc.id;
      return data;
    }).toList();
    setState(() {});
  }

  Future<void> _addSubCategory() async {
    if (_tenDanhMucController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên danh mục con")),
      );
      return;
    }

    try {
      final snapshot = await _firestore
          .collection("danhmuccon")
          .orderBy("IdDanhMucCon", descending: true)
          .limit(1)
          .get();

      String newId = "DMC01";
      if (snapshot.docs.isNotEmpty) {
        final lastId = snapshot.docs.first["IdDanhMucCon"];
        final number = int.tryParse(lastId.substring(3)) ?? 0;
        final nextNumber = number + 1;
        newId = "DMC${nextNumber.toString().padLeft(2, '0')}";
      }

      await _firestore.collection("danhmuccon").doc(newId).set({
        "IdDanhMucCon": newId,
        "TenDanhMucCon": _tenDanhMucController.text.trim(),
        "HinhAnh": _hinhAnhController.text.trim(),
        "TrangThai": _trangThai,
        "IdDanhMuc": _selectedIdDanhMucCha,
        "createdAt": FieldValue.serverTimestamp(), // Thêm trường thời gian
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm danh mục con $newId thành công!"),
          backgroundColor: _successColor,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi thêm danh mục con: $e"),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDanhMucCha();
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
          "Thêm danh mục con",
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
                      "Thông tin danh mục con",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nhập thông tin cơ bản cho danh mục con mới",
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
                                  controller: _tenDanhMucController,
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
                                  items: _danhMucCha.map((dm) {
                                    return DropdownMenuItem(
                                      value: dm['IdDanhMuc'].toString(),
                                      child: Text(
                                        dm['Ten'] ?? 'Không có tên',
                                        style: TextStyle(color: _textColor),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedIdDanhMucCha = value;
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Nút lưu
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: ElevatedButton(
                            onPressed: _addSubCategory,
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
                              "Lưu danh mục con",
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