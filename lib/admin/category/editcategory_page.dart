// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class EditCategoryPage extends StatefulWidget {
//   final String idDanhMuc;
//
//   const EditCategoryPage({super.key, required this.idDanhMuc});
//
//   @override
//   State<EditCategoryPage> createState() => _EditCategoryPageState();
// }
//
// class _EditCategoryPageState extends State<EditCategoryPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _tenController = TextEditingController();
//   final TextEditingController _hinhAnhController = TextEditingController();
//   String _trangThai = "Hoạt Động";
//   bool _isLoading = true;
//
//   final Color mainBlue = const Color(0xFF007BFF);
//   final Color lightBlue = const Color(0xFFe6f2ff);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategoryData();
//   }
//
//   Future<void> _loadCategoryData() async {
//     try {
//       final doc = await _firestore.collection("danhmuc").doc(widget.idDanhMuc).get();
//       if (doc.exists) {
//         final data = doc.data()!;
//         _tenController.text = data["Ten"] ?? "";
//         _hinhAnhController.text = data["HinhAnh"] ?? "";
//         _trangThai = data["TrangThai"] ?? "Hoạt Động";
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu: $e")));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _updateCategory() async {
//     try {
//       await _firestore.collection("danhmuc").doc(widget.idDanhMuc).update({
//         "Ten": _tenController.text.trim(),
//         "HinhAnh": _hinhAnhController.text.trim(),
//         "TrangThai": _trangThai,
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Cập nhật danh mục thành công!")),
//       );
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi cập nhật: $e")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: lightBlue,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Chỉnh sửa danh mục",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: mainBlue,
//         elevation: 3,
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
//           : Center(
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
//                     labelText: "Tên danh mục: ",
//                     prefixIcon: const Icon(Icons.category_outlined, color: Colors.blueAccent),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(color: mainBlue, width: 2),
//                     ),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                     filled: true,
//                     fillColor: Colors.blue.shade50.withOpacity(0.3),
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//
//                 // Link hình ảnh
//                 TextField(
//                   controller: _hinhAnhController,
//                   decoration: InputDecoration(
//                     labelText: "Link hình ảnh (https...)",
//                     prefixIcon: const Icon(Icons.image_outlined, color: Colors.blueAccent),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(color: mainBlue, width: 2),
//                     ),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
//                           child: const Text("Không tải được ảnh"),
//                         ),
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 18),
//
//                 // Dropdown trạng thái
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
//                         child: Text("Hoạt Động", style: TextStyle(color: Colors.black87)),
//                       ),
//                       DropdownMenuItem(
//                         value: "Ngưng Hoạt Động",
//                         child: Text("Ngưng Hoạt Động", style: TextStyle(color: Colors.black87)),
//                       ),
//                     ],
//                     onChanged: (v) => setState(() => _trangThai = v!),
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//
//                 // Nút lưu
//                 ElevatedButton.icon(
//                   onPressed: _updateCategory,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: mainBlue,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCategoryPage extends StatefulWidget {
  final String idDanhMuc;

  const EditCategoryPage({super.key, required this.idDanhMuc});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _tenController = TextEditingController();
  final TextEditingController _hinhAnhController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();

  String _trangThai = "Hoạt Động";
  bool _isLoading = true;
  bool _updating = false;

  // Color scheme đồng bộ
  final Color _primaryColor = const Color(0xFF2563EB);
  final Color _secondaryColor = const Color(0xFF60A5FA);
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF1E293B);
  final Color _hintColor = const Color(0xFF64748B);
  final Color _successColor = const Color(0xFF10B981);
  final Color _errorColor = const Color(0xFFEF4444);
  final Color _borderColor = const Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    try {
      final doc = await _firestore.collection("danhmuc").doc(widget.idDanhMuc).get();
      if (doc.exists) {
        final data = doc.data()!;
        _tenController.text = data["Ten"] ?? "";
        _hinhAnhController.text = data["HinhAnh"] ?? "";
        _moTaController.text = data["MoTa"] ?? "";
        _trangThai = data["TrangThai"] ?? "Hoạt Động";
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Không tìm thấy danh mục")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi tải dữ liệu: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCategory() async {
    if (_tenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Vui lòng nhập tên danh mục"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _updating = true);

    try {
      await _firestore.collection("danhmuc").doc(widget.idDanhMuc).update({
        "Ten": _tenController.text.trim(),
        "HinhAnh": _hinhAnhController.text.trim(),
        "MoTa": _moTaController.text.trim(),
        "TrangThai": _trangThai,
        "UpdatedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Cập nhật danh mục thành công"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Lỗi cập nhật: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _updating = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLines,
    bool isRequired = false,
    Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                  fontSize: 14,
                ),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    color: _errorColor,
                    fontWeight: FontWeight.bold,
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
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Nhập $label",
                hintStyle: TextStyle(color: _hintColor),
                border: InputBorder.none,
                prefixIcon: Icon(icon, color: _primaryColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_hinhAnhController.text.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: _hintColor),
            const SizedBox(height: 8),
            Text(
              "Chưa có hình ảnh",
              style: TextStyle(color: _hintColor),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primaryColor.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _hinhAnhController.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _backgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined, size: 48, color: _errorColor),
                      const SizedBox(height: 8),
                      Text(
                        "Không thể tải ảnh",
                        style: TextStyle(color: _errorColor),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: _backgroundColor,
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
        const SizedBox(height: 8),
        Text(
          "Xem trước hình ảnh",
          style: TextStyle(
            color: _hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _primaryColor),
              const SizedBox(height: 16),
              Text(
                "Đang tải thông tin danh mục...",
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
          "Chỉnh sửa danh mục",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_updating)
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
            // Thông tin cơ bản
            Container(
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
                  Text(
                    "Thông tin cơ bản",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Thông tin chính của danh mục",
                    style: TextStyle(
                      color: _hintColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _tenController,
                    label: "Tên danh mục",
                    icon: Icons.category_rounded,
                    isRequired: true,
                  ),
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
                                child: Icon(
                                  Icons.circle_rounded,
                                  color: _primaryColor,
                                  size: 18,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            dropdownColor: _surfaceColor,
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 14,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: "Hoạt Động",
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: _successColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Hoạt Động",
                                          style: TextStyle(
                                            color: _textColor,
                                            fontSize: 14,
                                          ),
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
                                      Icon(
                                        Icons.pause_circle,
                                        color: _errorColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Ngưng Hoạt Động",
                                          style: TextStyle(
                                            color: _textColor,
                                            fontSize: 14,
                                          ),
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hình ảnh danh mục
            Container(
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
                  Text(
                    "Hình ảnh danh mục",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "URL hình ảnh và xem trước",
                    style: TextStyle(
                      color: _hintColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _hinhAnhController,
                    label: "URL hình ảnh",
                    icon: Icons.link_rounded,
                    onChanged: (value) => setState(() {}),
                  ),
                  _buildImagePreview(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mô tả danh mục

            // Nút cập nhật
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _updating ? null : _updateCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _updating
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
                      "ĐANG CẬP NHẬT...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "CẬP NHẬT DANH MỤC",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tenController.dispose();
    _hinhAnhController.dispose();
    _moTaController.dispose();
    super.dispose();
  }
}