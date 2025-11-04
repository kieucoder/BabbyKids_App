// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
//
//
//
// class AddProductPage extends StatefulWidget {
//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }
//
// class _AddProductPageState extends State<AddProductPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Controllers
//   final _tenSPController = TextEditingController();
//   final _giaController = TextEditingController();
//   final _soLuongController = TextEditingController();
//   final _hinhAnhController = TextEditingController();
//   final _moTaController = TextEditingController();
//   final _doTuoiController = TextEditingController();
//   final _trongLuongController = TextEditingController();
//   final _sanXuatController = TextEditingController();
//   final _phanTramGiamController = TextEditingController();
//
//
//   // Dropdown
//   String? _selectedDanhMuc;
//   String? _selectedDanhMucCon;
//   String? _selectedThuongHieu;
//   List<Map<String, dynamic>> _thuongHieuList = [];
//   List<Map<String, dynamic>> _danhMucList = [];
//   List<Map<String, dynamic>> _danhMucConList = [];
//   String _trangThai = "Hoạt Động";
//
//  // chương trình khuyến mãi nếu có
//  //  String? _selectedKhuyenMai;
//   // List<Map<String, dynamic>> _khuyenMaiList = [];
//
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDanhMuc();
//   }
//
//   Future<void> _loadDanhMuc() async {
//     final snapshot = await _firestore.collection("danhmuc").get();
//     setState(() {
//       _danhMucList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdDanhMuc"].toString(),
//           "ten": doc["Ten"].toString(),
//         };
//       }).toList();
//     });
//   }
//
//   Future<void> _loadDanhMucCon(String idDanhMuc) async {
//     final snapshot = await _firestore
//         .collection("danhmuccon")
//         .where("IdDanhMuc", isEqualTo: idDanhMuc) //kết hợp với bảng danh mục nữa
//         .get();
//     setState(() {
//       _danhMucConList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdDanhMucCon"].toString(),
//           "ten": doc["TenDanhMucCon"].toString(),
//         };
//       }).toList();
//       _selectedDanhMucCon = null;
//     });
//   }
//
//   Future<void> _loadThuongHieu(String idDanhMucCon) async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('thuonghieu')
//         .where('IdDanhMucCon', isEqualTo: idDanhMucCon)
//         .get();
//
//     setState(() {
//       _thuongHieuList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdThuongHieu"].toString(),
//           "ten": doc["TenThuongHieu"].toString(), // đổi lại nếu khác
//         };
//       }).toList();
//       _selectedThuongHieu = null;
//     });
//   }
//
//   // Future<void> _loadKhuyenMai() async {
//   //   final snapshot = await _firestore.collection("khuyenmai").get();
//   //   setState(() {
//   //     _khuyenMaiList = snapshot.docs.map((doc) {
//   //       return {
//   //         "id": doc["IdKhuyenMai"].toString(),
//   //         "ten": doc["TenKhuyenMai"].toString(),
//   //       };
//   //     }).toList();
//   //   });
//   // }
//
//   Future<void> _addProduct() async {
//     if (_tenSPController.text.isEmpty || _selectedDanhMuc == null || _selectedDanhMucCon == null
//     ||_selectedThuongHieu == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(" Vui lòng nhập đầy đủ thông tin")),
//       );
//       return;
//     }
//
//
//     final snapshot = await _firestore.collection("sanpham").get();
//     int newIndex = snapshot.size + 1;
//     String newId = "SP${newIndex.toString().padLeft(2, '0')}";
//
//
//     await _firestore.collection("sanpham").doc(newId).set({
//       "IdSanPham": newId,
//       "TenSanPham": _tenSPController.text,
//       "Gia": int.tryParse(_giaController.text.replaceAll('.', '')) ?? 0,
//       "SoLuong": int.tryParse(_soLuongController.text) ?? 0,
//       "HinhAnh": _hinhAnhController.text,
//       "MoTa": _moTaController.text,
//       "DoTuoi": _doTuoiController.text,
//       "TrongLuong": _trongLuongController.text,
//       "SanXuat": _sanXuatController.text,
//       "PhanTramGiam": int.tryParse(_phanTramGiamController.text) ?? 0,
//       "IdDanhMuc": _selectedDanhMuc,
//       "IdDanhMucCon": _selectedDanhMucCon,
//       "IdThuongHieu": _selectedThuongHieu,
//       // "IdKhuyenMai": _selectedKhuyenMai,
//       "TrangThai": _trangThai,
//     });
//
//     // await counterRef.set({"lastIndex": newIndex});
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("✅ Đã thêm sản phẩm $newId")),
//     );
//
//     Navigator.pop(context,true); //Chuyển hướng về trang list product
//
//     // Clear form
//     _tenSPController.clear();
//     _giaController.clear();
//     _soLuongController.clear();
//     _hinhAnhController.clear();
//     _moTaController.clear();
//     _doTuoiController.clear();
//     _trongLuongController.clear();
//     _sanXuatController.clear();
//     setState(() {
//       _selectedDanhMuc = null;
//       _selectedDanhMucCon = null;
//       _selectedThuongHieu = null;
//       _trangThai = "Hoạt Động";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Thêm sản phẩm"), backgroundColor: Colors.teal),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Dropdown chọn danh mục
//             DropdownButtonFormField<String>(
//               value: _selectedDanhMuc,
//               hint: Text("Chọn danh mục"),
//               items: _danhMucList.map((dm) {
//                 return DropdownMenuItem(
//                   value: dm["id"].toString(),
//                   child: Text("${dm["ten"].toString()} "),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedDanhMuc = value;
//                 });
//                 if (value != null) _loadDanhMucCon(value);
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.category),
//               ),
//             ),
//             SizedBox(height: 12),
//
//             // Dropdown chọn danh mục con
//             DropdownButtonFormField<String>(
//               value: _selectedDanhMucCon,
//               hint: Text("Chọn danh mục con"),
//               items: _danhMucConList.map((dm) {
//                 return DropdownMenuItem(
//                   value: dm["id"].toString(),
//                   child: Text("${dm["ten"].toString()} "),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedDanhMucCon = value;
//                 });
//                 if (value != null) {
//                   _loadThuongHieu(value); // 👈 GỌI LOAD THƯƠNG HIỆU Ở ĐÂY
//                 }
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.subdirectory_arrow_right),
//               ),
//             ),
//             SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _selectedThuongHieu,
//               hint: const Text("Chọn thương hiệu"),
//               items: _thuongHieuList.map((th) {
//                 return DropdownMenuItem(
//                   value: th["id"].toString(),
//                   child: Text(th["ten"].toString()),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedThuongHieu = value;
//                 });
//                 print("Đã chọn thương hiệu: $value");
//               },
//
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.subdirectory_arrow_right),
//               ),
//             ),
//             SizedBox(height: 12),
//             //khuyến mãi
//             // DropdownButtonFormField<String>(
//             //   value: _selectedKhuyenMai,
//             //   hint: const Text("Chọn khuyến mãi (nếu có)"),
//             //   items: _khuyenMaiList.map((km) {
//             //     return DropdownMenuItem(
//             //       value: km["id"].toString(),
//             //       child: Text(km["ten"].toString()),
//             //     );
//             //   }).toList(),
//             //   onChanged: (value) {
//             //     setState(() {
//             //       _selectedKhuyenMai = value;
//             //     });
//             //   },
//             //   decoration: const InputDecoration(
//             //     border: OutlineInputBorder(),
//             //     prefixIcon: Icon(Icons.discount),
//             //   ),
//             // ),
//
//
//             SizedBox(height: 12),
//             TextField(
//               controller: _tenSPController,
//               decoration: InputDecoration(labelText: "Tên sản phẩm", border: OutlineInputBorder()),
//             ),
//             SizedBox(height: 12),
//
//             TextField(
//               controller: _giaController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(labelText: "Giá", border: OutlineInputBorder()),
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly, // chỉ cho nhập số
//                 TextInputFormatter.withFunction((oldValue, newValue) {
//                   if (newValue.text.isEmpty) return newValue;
//
//                   // Chuyển text sang số
//                   final value = int.parse(newValue.text.replaceAll('.', ''));
//                   final newText = NumberFormat.decimalPattern('vi').format(value);
//
//                   return TextEditingValue(
//                     text: newText,
//                     selection: TextSelection.collapsed(offset: newText.length),
//                   );
//                 }),
//               ],
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: _phanTramGiamController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: "Phần trăm giảm (%)",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.percent),
//               ),
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly, // chỉ cho nhập số
//               ],
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: _soLuongController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(labelText: "Số lượng", border: OutlineInputBorder()),
//             ),
//             SizedBox(height: 12),
//
//             TextField(
//               controller: _hinhAnhController,
//               decoration: InputDecoration(labelText: "Link hình ảnh", border: OutlineInputBorder()),
//               onChanged: (val) => setState(() {}),
//             ),
//             SizedBox(height: 10),
//
//             if (_hinhAnhController.text.isNotEmpty)
//               Image.network(_hinhAnhController.text, height: 120, fit: BoxFit.cover),
//
//             SizedBox(height: 12),
//             TextField(
//               controller: _moTaController,
//               maxLines: 3,
//               decoration: InputDecoration(labelText: "Mô tả", border: OutlineInputBorder()),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: _doTuoiController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(labelText: "Độ tuổi ",border: OutlineInputBorder()),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: _trongLuongController,
//               keyboardType: TextInputType.text,
//               decoration: InputDecoration(labelText: "Trọng Lượng", border: OutlineInputBorder()),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: _sanXuatController,
//               keyboardType: TextInputType.text,
//               decoration: InputDecoration(labelText: "Sản Xuất", border: OutlineInputBorder()),
//             ),
//             SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _trangThai,
//               items: ["Hoạt Động", "Ngưng Hoạt Động"].map((status) {
//                 return DropdownMenuItem(value: status, child: Text(status));
//               }).toList(),
//               onChanged: (val) => setState(() => _trangThai = val!),
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.toggle_on),
//               ),
//             ),
//             SizedBox(height: 20),
//
//             ElevatedButton.icon(
//               onPressed: _addProduct,
//               icon: Icon(Icons.save),
//               label: Text("Lưu sản phẩm"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 minimumSize: Size(double.infinity, 50),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// class AddProductPage extends StatefulWidget {
//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }
//
// class _AddProductPageState extends State<AddProductPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Controllers
//   final _tenSPController = TextEditingController();
//   final _giaController = TextEditingController();
//   final _soLuongController = TextEditingController();
//   final _hinhAnhController = TextEditingController();
//   final _moTaController = TextEditingController();
//   final _doTuoiController = TextEditingController();
//   final _trongLuongController = TextEditingController();
//   final _sanXuatController = TextEditingController();
//   final _phanTramGiamController = TextEditingController();
//
//   // Dropdown
//   String? _selectedDanhMuc;
//   String? _selectedDanhMucCon;
//   String? _selectedThuongHieu;
//   List<Map<String, dynamic>> _thuongHieuList = [];
//   List<Map<String, dynamic>> _danhMucList = [];
//   List<Map<String, dynamic>> _danhMucConList = [];
//   String _trangThai = "Hoạt Động";
//
//   // Màu sắc theo theme DeepSeek
//   final Color _primaryColor = Color(0xFF0d6efd); // Xanh dương đậm DeepSeek
//   final Color _secondaryColor = Color(0xFF6ea8fe); // Xanh dương nhạt
//   final Color _backgroundColor = Color(0xFFf8f9fa); // Màu nền nhẹ
//   final Color _surfaceColor = Colors.white;
//   final Color _errorColor = Color(0xFFdc3545);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDanhMuc();
//   }
//
//   Future<void> _loadDanhMuc() async {
//     final snapshot = await _firestore.collection("danhmuc").get();
//     setState(() {
//       _danhMucList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdDanhMuc"].toString(),
//           "ten": doc["Ten"].toString(),
//         };
//       }).toList();
//     });
//   }
//
//   Future<void> _loadDanhMucCon(String idDanhMuc) async {
//     final snapshot = await _firestore
//         .collection("danhmuccon")
//         .where("IdDanhMuc", isEqualTo: idDanhMuc)
//         .get();
//     setState(() {
//       _danhMucConList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdDanhMucCon"].toString(),
//           "ten": doc["TenDanhMucCon"].toString(),
//         };
//       }).toList();
//       _selectedDanhMucCon = null;
//     });
//   }
//
//   Future<void> _loadThuongHieu(String idDanhMucCon) async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('thuonghieu')
//         .where('IdDanhMucCon', isEqualTo: idDanhMucCon)
//         .get();
//
//     setState(() {
//       _thuongHieuList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdThuongHieu"].toString(),
//           "ten": doc["TenThuongHieu"].toString(),
//         };
//       }).toList();
//       _selectedThuongHieu = null;
//     });
//   }
//
//   Future<void> _addProduct() async {
//     if (_tenSPController.text.isEmpty ||
//         _selectedDanhMuc == null ||
//         _selectedDanhMucCon == null ||
//         _selectedThuongHieu == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Vui lòng nhập đầy đủ thông tin"),
//           backgroundColor: _errorColor,
//         ),
//       );
//       return;
//     }
//
//     final snapshot = await _firestore.collection("sanpham").get();
//     int newIndex = snapshot.size + 1;
//     String newId = "SP${newIndex.toString().padLeft(2, '0')}";
//
//     await _firestore.collection("sanpham").doc(newId).set({
//       "IdSanPham": newId,
//       "TenSanPham": _tenSPController.text,
//       "Gia": int.tryParse(_giaController.text.replaceAll('.', '')) ?? 0,
//       "SoLuong": int.tryParse(_soLuongController.text) ?? 0,
//       "HinhAnh": _hinhAnhController.text,
//       "MoTa": _moTaController.text,
//       "DoTuoi": _doTuoiController.text,
//       "TrongLuong": _trongLuongController.text,
//       "SanXuat": _sanXuatController.text,
//       "PhanTramGiam": int.tryParse(_phanTramGiamController.text) ?? 0,
//       "IdDanhMuc": _selectedDanhMuc,
//       "IdDanhMucCon": _selectedDanhMucCon,
//       "IdThuongHieu": _selectedThuongHieu,
//       "TrangThai": _trangThai,
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("✅ Đã thêm sản phẩm $newId"),
//         backgroundColor: Colors.green,
//       ),
//     );
//
//     Navigator.pop(context, true);
//   }
//
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String labelText,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     Widget? prefixIcon,
//     int? maxLines,
//     ValueChanged<String>? onChanged,
//   }) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         maxLines: maxLines,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: labelText,
//           labelStyle: TextStyle(color: Colors.grey[700]),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey[400]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: _primaryColor, width: 2),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey[400]!),
//           ),
//           filled: true,
//           fillColor: _surfaceColor,
//           prefixIcon: prefixIcon != null ? IconTheme(
//             data: IconThemeData(color: _primaryColor),
//             child: prefixIcon,
//           ) : null,
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//         style: TextStyle(fontSize: 16),
//       ),
//     );
//   }
//
//   Widget _buildDropdown({
//     required String? value,
//     required String hintText,
//     required List<Map<String, dynamic>> items,
//     required ValueChanged<String?> onChanged,
//     required IconData icon,
//   }) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         hint: Text(
//           hintText,
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//         items: items.map((item) {
//           return DropdownMenuItem(
//             value: item["id"].toString(),
//             child: Text(
//               item["ten"].toString(),
//               style: TextStyle(fontSize: 16),
//             ),
//           );
//         }).toList(),
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey[400]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: _primaryColor, width: 2),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey[400]!),
//           ),
//           filled: true,
//           fillColor: _surfaceColor,
//           prefixIcon: Icon(icon, color: _primaryColor),
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//         dropdownColor: _surfaceColor,
//         style: TextStyle(color: Colors.black87),
//         icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Thêm sản phẩm mới",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: _primaryColor,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//         centerTitle: true,
//       ),
//       backgroundColor: _backgroundColor,
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Card chứa form
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     // Danh mục
//                     _buildDropdown(
//                       value: _selectedDanhMuc,
//                       hintText: "Chọn danh mục",
//                       items: _danhMucList,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedDanhMuc = value;
//                         });
//                         if (value != null) _loadDanhMucCon(value);
//                       },
//                       icon: Icons.category,
//                     ),
//
//                     // Danh mục con
//                     _buildDropdown(
//                       value: _selectedDanhMucCon,
//                       hintText: "Chọn danh mục con",
//                       items: _danhMucConList,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedDanhMucCon = value;
//                         });
//                         if (value != null) _loadThuongHieu(value);
//                       },
//                       icon: Icons.category_outlined,
//                     ),
//
//                     // Thương hiệu
//                     _buildDropdown(
//                       value: _selectedThuongHieu,
//                       hintText: "Chọn thương hiệu",
//                       items: _thuongHieuList,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedThuongHieu = value;
//                         });
//                       },
//                       icon: Icons.branding_watermark,
//                     ),
//
//                     // Tên sản phẩm
//                     _buildInputField(
//                       controller: _tenSPController,
//                       labelText: "Tên sản phẩm",
//                       prefixIcon: Icon(Icons.shopping_bag),
//                     ),
//
//                     // Giá
//                     _buildInputField(
//                       controller: _giaController,
//                       labelText: "Giá",
//                       keyboardType: TextInputType.number,
//                       prefixIcon: Icon(Icons.attach_money),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         TextInputFormatter.withFunction((oldValue, newValue) {
//                           if (newValue.text.isEmpty) return newValue;
//                           final value = int.parse(newValue.text.replaceAll('.', ''));
//                           final newText = NumberFormat.decimalPattern('vi').format(value);
//                           return TextEditingValue(
//                             text: newText,
//                             selection: TextSelection.collapsed(offset: newText.length),
//                           );
//                         }),
//                       ],
//                     ),
//
//                     // Phần trăm giảm
//                     _buildInputField(
//                       controller: _phanTramGiamController,
//                       labelText: "Phần trăm giảm (%)",
//                       keyboardType: TextInputType.number,
//                       prefixIcon: Icon(Icons.percent),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                       ],
//                     ),
//
//                     // Số lượng
//                     _buildInputField(
//                       controller: _soLuongController,
//                       labelText: "Số lượng",
//                       keyboardType: TextInputType.number,
//                       prefixIcon: Icon(Icons.inventory_2),
//                     ),
//
//                     // Link hình ảnh
//                     _buildInputField(
//                       controller: _hinhAnhController,
//                       labelText: "Link hình ảnh",
//                       prefixIcon: Icon(Icons.link),
//                       onChanged: (val) => setState(() {}),
//                     ),
//
//                     // Xem trước hình ảnh
//                     if (_hinhAnhController.text.isNotEmpty)
//                       Container(
//                         margin: EdgeInsets.only(bottom: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Xem trước:",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.network(
//                                 _hinhAnhController.text,
//                                 height: 120,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Container(
//                                     height: 120,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[200],
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Icon(Icons.error_outline, color: Colors.grey),
//                                         SizedBox(height: 8),
//                                         Text(
//                                           "Không thể tải hình ảnh",
//                                           style: TextStyle(color: Colors.grey),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     // Mô tả
//                     _buildInputField(
//                       controller: _moTaController,
//                       labelText: "Mô tả sản phẩm",
//                       maxLines: 3,
//                       prefixIcon: Icon(Icons.description),
//                     ),
//
//                     // Độ tuổi
//                     _buildInputField(
//                       controller: _doTuoiController,
//                       labelText: "Độ tuổi",
//                       keyboardType: TextInputType.number,
//                       prefixIcon: Icon(Icons.child_care),
//                     ),
//
//                     // Trọng lượng
//                     _buildInputField(
//                       controller: _trongLuongController,
//                       labelText: "Trọng lượng",
//                       prefixIcon: Icon(Icons.scale),
//                     ),
//
//                     // Sản xuất
//                     _buildInputField(
//                       controller: _sanXuatController,
//                       labelText: "Nơi sản xuất",
//                       prefixIcon: Icon(Icons.location_city),
//                     ),
//
//                     // Trạng thái
//                     _buildDropdown(
//                       value: _trangThai,
//                       hintText: "Chọn trạng thái",
//                       items: [
//                         {"id": "Hoạt Động", "ten": "Hoạt Động"},
//                         {"id": "Ngưng Hoạt Động", "ten": "Ngưng Hoạt Động"},
//                       ],
//                       onChanged: (val) => setState(() => _trangThai = val!),
//                       icon: Icons.toggle_on,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 24),
//
//             // Nút lưu
//             Container(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: _addProduct,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _primaryColor,
//                   foregroundColor: Colors.white,
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.save_alt, size: 24),
//                     SizedBox(width: 12),
//                     Text(
//                       "LƯU SẢN PHẨM",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 16),
//
//             // Nút hủy
//             Container(
//               width: double.infinity,
//               height: 50,
//               child: TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: TextButton.styleFrom(
//                   foregroundColor: _primaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   side: BorderSide(color: _primaryColor, width: 1),
//                 ),
//                 child: Text(
//                   "HỦY BỎ",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final _tenSPController = TextEditingController();
  final _giaController = TextEditingController();
  final _soLuongController = TextEditingController();
  final _hinhAnhController = TextEditingController();
  final _moTaController = TextEditingController();
  final _doTuoiController = TextEditingController();
  final _trongLuongController = TextEditingController();
  final _sanXuatController = TextEditingController();
  // final _phanTramGiamController = TextEditingController();


  String? _selectedKhuyenMai;
  List<Map<String, dynamic>> _khuyenMaiList = [];

  // Dropdown
  String? _selectedDanhMuc;
  String? _selectedDanhMucCon;
  String? _selectedThuongHieu;
  List<Map<String, dynamic>> _thuongHieuList = [];
  List<Map<String, dynamic>> _danhMucList = [];
  List<Map<String, dynamic>> _danhMucConList = [];
  String _trangThai = "Hoạt Động";

  // Màu sắc tinh tế
  final Color _primaryColor = Color(0xFF2563EB); // Xanh dương tinh tế
  final Color _secondaryColor = Color(0xFF60A5FA); // Xanh dương nhạt
  final Color _accentColor = Color(0xFF10B981); // Xanh lá nhẹ
  final Color _backgroundColor = Color(0xFFF8FAFC); // Màu nền nhẹ
  final Color _surfaceColor = Colors.white;
  final Color _borderColor = Color(0xFFE2E8F0);
  final Color _textColor = Color(0xFF1E293B);
  final Color _hintColor = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _loadDanhMuc();
    _loadKhuyenMai(); // Thêm dòng này
  }

  Future<void> _loadDanhMuc() async {
    final snapshot = await _firestore.collection("danhmuc").get();
    setState(() {
      _danhMucList = snapshot.docs.map((doc) {
        return {
          "id": doc["IdDanhMuc"].toString(),
          "ten": doc["Ten"].toString(),
        };
      }).toList();
    });
  }

  Future<void> _loadDanhMucCon(String idDanhMuc) async {
    final snapshot = await _firestore
        .collection("danhmuccon")
        .where("IdDanhMuc", isEqualTo: idDanhMuc)
        .get();
    setState(() {
      _danhMucConList = snapshot.docs.map((doc) {
        return {
          "id": doc["IdDanhMucCon"].toString(),
          "ten": doc["TenDanhMucCon"].toString(),
        };
      }).toList();
      _selectedDanhMucCon = null;
    });
  }

  Future<void> _loadThuongHieu(String idDanhMucCon) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('thuonghieu')
        .where('IdDanhMucCon', isEqualTo: idDanhMucCon)
        .get();

    setState(() {
      _thuongHieuList = snapshot.docs.map((doc) {
        return {
          "id": doc["IdThuongHieu"].toString(),
          "ten": doc["TenThuongHieu"].toString(),
        };
      }).toList();
      _selectedThuongHieu = null;
    });
  }

  Future<void> _loadKhuyenMai() async {
    try {
      final snapshot = await _firestore
          .collection("khuyenmai")
          .where("TrangThai", isEqualTo: "Đang hoạt động") // Chỉ load khuyến mãi đang hoạt động
          .get();

      setState(() {
        _khuyenMaiList = snapshot.docs.map((doc) {
          return {
            "id": doc["IdKhuyenMai"].toString(),
            "ten": "${doc["TenKhuyenMai"]} - ${doc["PhanTramGiam"]}%",
            "phanTramGiam": doc["PhanTramGiam"],
          };
        }).toList();
      });
    } catch (e) {
      print("Lỗi load khuyến mãi: $e");
    }
  }
  Future<void> _addProduct() async {
    if (_tenSPController.text.isEmpty ||
        _selectedDanhMuc == null ||
        _selectedDanhMucCon == null ||
        _selectedThuongHieu == null) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin bắt buộc", false);
      return;
    }

    try {
      final snapshot = await _firestore.collection("sanpham").get();
      int newIndex = snapshot.size + 1;
      String newId = "SP${newIndex.toString().padLeft(3, '0')}";

      await _firestore.collection("sanpham").doc(newId).set({
        "IdSanPham": newId,
        "TenSanPham": _tenSPController.text,
        "Gia": int.tryParse(_giaController.text.replaceAll('.', '')) ?? 0,
        "SoLuong": int.tryParse(_soLuongController.text) ?? 0,
        "HinhAnh": _hinhAnhController.text,
        "MoTa": _moTaController.text,
        "DoTuoi": _doTuoiController.text,
        "TrongLuong": _trongLuongController.text,
        "SanXuat": _sanXuatController.text,
        // "PhanTramGiam": int.tryParse(_phanTramGiamController.text) ?? 0,
        "IdDanhMuc": _selectedDanhMuc,
        "IdDanhMucCon": _selectedDanhMucCon,
        "IdThuongHieu": _selectedThuongHieu,
        "IdKhuyenMai": _selectedKhuyenMai,
        "TrangThai": _trangThai,
        "NgayTao": FieldValue.serverTimestamp(),
      });

      _showSnackBar("✅ Đã thêm sản phẩm $newId thành công", true);
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar("❌ Lỗi khi thêm sản phẩm: $e", false);
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? _accentColor : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
    Widget? suffixIcon,
    int? maxLines = 1,
    bool isRequired = false,
    ValueChanged<String>? onChanged, // THÊM DÒNG NÀY
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                labelText,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                  fontSize: 14,
                ),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              onChanged: onChanged, // THÊM DÒNG NÀY
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: _hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: _surfaceColor,
                prefixIcon: prefixIcon != null
                    ? Icon(prefixIcon, color: _primaryColor, size: 20)
                    : null,
                suffixIcon: suffixIcon,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(fontSize: 15, color: _textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String labelText,
    required String hintText,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
    bool isRequired = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                labelText,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                  fontSize: 14,
                ),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              hint: Text(
                hintText,
                style: TextStyle(color: _hintColor),
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item["id"].toString(),
                  child: Text(
                    item["ten"].toString(),
                    style: TextStyle(fontSize: 15, color: _textColor),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: _surfaceColor,
                prefixIcon: icon != null
                    ? Icon(icon, color: _primaryColor, size: 20)
                    : null,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              dropdownColor: _surfaceColor,
              style: TextStyle(color: _textColor),
              icon: Icon(Icons.arrow_drop_down_rounded, color: _primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_hinhAnhController.text.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Xem trước hình ảnh",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _textColor,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _hinhAnhController.text,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_rounded, color: _hintColor, size: 40),
                        SizedBox(height: 8),
                        Text(
                          "Không thể tải hình ảnh",
                          style: TextStyle(color: _hintColor),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: _primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thêm sản phẩm mới",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Card chính chứa form
            Container(
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Section 1: Thông tin danh mục
                    _buildSection("Thông tin danh mục", [
                      _buildDropdown(
                        value: _selectedDanhMuc,
                        labelText: "Danh mục",
                        hintText: "Chọn danh mục",
                        items: _danhMucList,
                        onChanged: (value) {
                          setState(() {
                            _selectedDanhMuc = value;
                          });
                          if (value != null) _loadDanhMucCon(value);
                        },
                        icon: Icons.category_rounded,
                        isRequired: true,
                      ),

                      _buildDropdown(
                        value: _selectedDanhMucCon,
                        labelText: "Danh mục con",
                        hintText: "Chọn danh mục con",
                        items: _danhMucConList,
                        onChanged: (value) {
                          setState(() {
                            _selectedDanhMucCon = value;
                          });
                          if (value != null) _loadThuongHieu(value);
                        },
                        icon: Icons.category_outlined,
                        isRequired: true,
                      ),

                      _buildDropdown(
                        value: _selectedThuongHieu,
                        labelText: "Thương hiệu",
                        hintText: "Chọn thương hiệu",
                        items: _thuongHieuList,
                        onChanged: (value) {
                          setState(() {
                            _selectedThuongHieu = value;
                          });
                        },
                        icon: Icons.branding_watermark_rounded,
                        isRequired: true,
                      ),
                    ]),

                    // Section 2: Thông tin cơ bản
                    _buildSection("Thông tin cơ bản", [
                      _buildInputField(
                        controller: _tenSPController,
                        labelText: "Tên sản phẩm",
                        hintText: "Nhập tên sản phẩm",
                        prefixIcon: Icons.shopping_bag_rounded,
                        isRequired: true,
                      ),

                      _buildInputField(
                        controller: _giaController,
                        labelText: "Giá bán",
                        hintText: "Nhập giá bán",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money_rounded,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.isEmpty) return newValue;
                            final value = int.tryParse(newValue.text.replaceAll('.', '')) ?? 0;
                            final newText = NumberFormat.decimalPattern('vi').format(value);
                            return TextEditingValue(
                              text: newText,
                              selection: TextSelection.collapsed(offset: newText.length),
                            );
                          }),
                        ],
                        isRequired: true,
                      ),

                      // Trong Section 2: Thông tin cơ bản, thêm sau phần trăm giảm


                      ///phần trăm giảm
                      // _buildDropdown(
                      //   value: _selectedKhuyenMai,
                      //   labelText: "Chương trình khuyến mãi",
                      //   hintText: "Chọn khuyến mãi (nếu có)",
                      //   items: [
                      //     {"id": null, "ten": "Không có khuyến mãi"}, // Option không chọn
                      //     ..._khuyenMaiList,
                      //   ],
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _selectedKhuyenMai = value;
                      //
                      //       // Tự động điền phần trăm giảm nếu chọn khuyến mãi
                      //       if (value != null) {
                      //         final selectedKM = _khuyenMaiList.firstWhere(
                      //               (km) => km["id"] == value,
                      //           orElse: () => {},
                      //         );
                      //         if (selectedKM.isNotEmpty) {
                      //           _phanTramGiamController.text = selectedKM["phanTramGiam"].toString();
                      //         }
                      //       } else {
                      //         _phanTramGiamController.clear();
                      //       }
                      //     });
                      //   },
                      //   icon: Icons.discount_rounded,
                      // ),

                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _soLuongController,
                              labelText: "Số lượng",
                              hintText: "0",
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.inventory_2_rounded,
                            ),
                          ),
                          SizedBox(width: 16),
                          // Expanded(
                          //   child: _buildInputField(
                          //     controller: _phanTramGiamController,
                          //     labelText: "Giảm giá (%)",
                          //     hintText: "0",
                          //     keyboardType: TextInputType.number,
                          //     prefixIcon: Icons.percent_rounded,
                          //   ),
                          // ),
                        ],
                      ),
                    ]),

                    // Section 3: Hình ảnh
                    _buildSection("Hình ảnh sản phẩm", [
                      _buildInputField(
                        controller: _hinhAnhController,
                        labelText: "URL hình ảnh",
                        hintText: "https://example.com/image.jpg",
                        prefixIcon: Icons.link_rounded,
                        onChanged: (val) => setState(() {}),
                      ),
                      _buildImagePreview(),
                    ]),



                    // Section 4: Mô tả
                    _buildSection("Mô tả sản phẩm", [
                      _buildInputField(
                        controller: _moTaController,
                        labelText: "Mô tả chi tiết",
                        hintText: "Nhập mô tả về sản phẩm...",
                        prefixIcon: Icons.description_rounded,
                        maxLines: 3,
                      ),
                    ]),

                    // Section 5: Thông tin bổ sung
                    _buildSection("Thông tin bổ sung", [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _doTuoiController,
                              labelText: "Độ tuổi",
                              hintText: "0-12 tháng",
                              prefixIcon: Icons.child_care_rounded,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              controller: _trongLuongController,
                              labelText: "Trọng lượng",
                              hintText: "500g",
                              prefixIcon: Icons.scale_rounded,
                            ),
                          ),
                        ],
                      ),
                      _buildInputField(
                        controller: _sanXuatController,
                        labelText: "Xuất xứ",
                        hintText: "Nhập nơi sản xuất",
                        prefixIcon: Icons.location_city_rounded,
                      ),
                    ]),

                    // Section 6: Trạng thái
                    _buildSection("Trạng thái", [
                      _buildDropdown(
                        value: _trangThai,
                        labelText: "Trạng thái sản phẩm",
                        hintText: "Chọn trạng thái",
                        items: [
                          {"id": "Hoạt Động", "ten": "🟢 Hoạt Động"},
                          {"id": "Ngưng Hoạt Động", "ten": "🔴 Ngưng Hoạt Động"},
                        ],
                        onChanged: (val) => setState(() => _trangThai = val!),
                        icon: Icons.toggle_on_rounded,
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Nút hành động
            Row(
              children: [
                // Nút hủy
                Expanded(
                  child: Container(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryColor,
                        side: BorderSide(color: _primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "HỦY",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Nút lưu
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_alt_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "LƯU SẢN PHẨM",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}