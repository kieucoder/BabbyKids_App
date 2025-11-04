// import 'package:appshopsua/admin/subcategory/addsubcategory_page.dart';
// import 'package:appshopsua/admin/subcategory/deletesubcategory.dart';
// import 'package:appshopsua/admin/subcategory/editsubcategory.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class ListSubCattegory extends StatefulWidget {
//
//   const ListSubCattegory({super.key});
//
//   @override
//   State<ListSubCattegory> createState() => _ListSubCattegoryState();
// }
//
// class _ListSubCattegoryState extends State<ListSubCattegory> {
//   final Color mainBlue = const Color(0xFF007BFF);
//   final Color lightBlue = const Color(0xFFE6F2FF);
//   String _searchText = "";
//   final TextEditingController _searchController = TextEditingController();
// // Thêm dòng này
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       Scaffold(
//         backgroundColor: lightBlue,
//         appBar: AppBar(
//           title: const Text(
//             "Danh sách danh mục",
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           backgroundColor: mainBlue,
//           centerTitle: true,
//           elevation: 3,
//         ),
//         body: Column(
//           children: [
//             // Thanh tìm kiếm
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: "Tìm kiếm danh mục con...",
//                   filled: true,
//                   fillColor: Colors.white,
//                   prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 onChanged: (value) => setState(() => _searchText = value.trim().toLowerCase()),
//               ),
//             ),
//
//             // Danh sách danh mục con
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance.collection("danhmuccon").snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(
//                       child: Text("Chưa có danh mục nào được thêm."),
//                     );
//                   }
//
//                   final docs = snapshot.data!.docs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final ten = data["TenDanhMucCon"]?.toString().toLowerCase() ?? "";
//                     return ten.contains(_searchText);
//                   }).toList();
//
//                   if (docs.isEmpty) {
//                     return const Center(child: Text(" Không tìm thấy danh mục nào."));
//                   }
//
//                   return ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final data = docs[index].data() as Map<String, dynamic>;
//
//                       return
//                         Card(
//                           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                           elevation: 2,
//                           shadowColor: Colors.blueAccent.withOpacity(0.2),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16),
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Colors.white,
//                                   Colors.blue.shade50.withOpacity(0.6),
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                             ),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.all(12),
//
//                               // 🔹 Ảnh danh mục
//                               leading: ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Container(
//                                   width: 65,
//                                   height: 65,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
//                                     borderRadius: BorderRadius.circular(14),
//                                   ),
//                                   child: Image.network(
//                                     data["HinhAnh"] ?? "",
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stack) => Container(
//                                       color: Colors.blue.shade50,
//                                       alignment: Alignment.center,
//                                       child: const Icon(Icons.image_not_supported,
//                                           color: Colors.grey, size: 28),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//
//                               // 🔹 Tiêu đề & trạng thái
//                               title: Text(
//                                 data["TenDanhMucCon"] ?? "Không có tên",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 17,
//                                   color: Color(0xFF01579B),
//                                 ),
//                               ),
//                               subtitle: Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Text(
//                                   "Trạng thái: ${data["TrangThai"] ?? "Không xác định"}",
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: (data["TrangThai"] == "Hoạt Động")
//                                         ? Colors.green.shade700
//                                         : Colors.red.shade400,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//
//                               // 🔹 Nút sửa & xóa
//                               trailing: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   // Nút sửa
//                                   InkWell(
//                                     borderRadius: BorderRadius.circular(12),
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => EditSubCategoryPage(
//                                             idDanhMucCon: data["IdDanhMucCon"],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: BoxDecoration(
//                                         color: Colors.blue.shade100.withOpacity(0.4),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: const Icon(Icons.edit, color: Colors.blue, size: 22),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//
//                                   // Nút xóa
//                                   InkWell(
//                                     borderRadius: BorderRadius.circular(12),
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => DeleteSubCategoryPage(
//                                             idDanhMucCon: data["IdDanhMucCon"],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: BoxDecoration(
//                                         color: Colors.red.shade100.withOpacity(0.4),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: const Icon(Icons.delete, color: Colors.red, size: 22),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//
//         // Nút thêm danh mục
//         // floatingActionButton: FloatingActionButton.extended(
//         //   onPressed: () {
//         //     Navigator.push(
//         //       context,
//         //       MaterialPageRoute(
//         //         builder: (context) => AddSubCategory(), // không truyền gì cả
//         //       ),
//         //     );
//         //   },
//         //   backgroundColor: mainBlue,
//         //   icon: const Icon(Icons.add, color: Colors.white),
//         //   label: const Text(
//         //     "Thêm sản phẩm",
//         //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         //   ),
//         // ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () async {
//             final result = await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => AddSubCategory()),
//             );
//
//             // Nếu trang thêm trả về true => reload danh sách
//             if (result == true) {
//               setState(() {});
//             }
//           },
//           backgroundColor: mainBlue,
//           icon: const Icon(Icons.add, color: Colors.white),
//           label: const Text(
//             "Thêm danh mục con",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         ),
//
//
//
//       );
//
//   }
// }
//


import 'package:appshopsua/admin/subcategory/addsubcategory_page.dart';
import 'package:appshopsua/admin/subcategory/deletesubcategory.dart';
import 'package:appshopsua/admin/subcategory/editsubcategory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListSubCattegory extends StatefulWidget {
  const ListSubCattegory({super.key});

  @override
  State<ListSubCattegory> createState() => _ListSubCattegoryState();
}

class _ListSubCattegoryState extends State<ListSubCattegory> {
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _textColor = const Color(0xFF212529);
  final Color _borderColor = const Color(0xFFDEE2E6);
  final Color _successColor = const Color(0xFF28A745);
  final Color _errorColor = const Color(0xFFDC3545);
  final Color _hintColor = const Color(0xFF6C757D);

  String _searchText = "";
  String _filterStatus = "Tất cả";
  final TextEditingController _searchController = TextEditingController();

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
          "Danh sách danh mục con",
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
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
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
                  "Quản lý danh mục con",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Danh sách tất cả danh mục con trong hệ thống",
                  style: TextStyle(
                    fontSize: 14,
                    color: _hintColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search and Filter Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Field
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tìm kiếm",
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
                            controller: _searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Nhập tên danh mục con...",
                              hintStyle: TextStyle(color: _hintColor),
                              prefixIcon: Icon(Icons.search, color: _primaryColor),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            style: TextStyle(color: _textColor, fontSize: 14),
                            onChanged: (value) => setState(() => _searchText = value.trim().toLowerCase()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Field
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lọc trạng thái",
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
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterStatus,
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryColor),
                              items: [
                                DropdownMenuItem(
                                  value: "Tất cả",
                                  child: Row(
                                    children: [
                                      Icon(Icons.all_inclusive, color: _primaryColor, size: 20),
                                      const SizedBox(width: 12),
                                      Text("Tất cả trạng thái", style: TextStyle(color: _textColor)),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "Hoạt Động",
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: _successColor, size: 20),
                                      const SizedBox(width: 12),
                                      Text("Hoạt Động", style: TextStyle(color: _textColor)),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "Ngưng Hoạt Động",
                                  child: Row(
                                    children: [
                                      Icon(Icons.pause_circle, color: _errorColor, size: 20),
                                      const SizedBox(width: 12),
                                      Text("Ngưng Hoạt Động", style: TextStyle(color: _textColor)),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) => setState(() => _filterStatus = value!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("danhmuccon").orderBy("IdDanhMucCon",descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category_outlined, color: _borderColor, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              "Chưa có danh mục con nào",
                              style: TextStyle(
                                fontSize: 16,
                                color: _textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Hãy thêm danh mục con đầu tiên",
                              style: TextStyle(
                                fontSize: 14,
                                color: _hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final ten = data["TenDanhMucCon"]?.toString().toLowerCase() ?? "";
                    final trangThai = data["TrangThai"]?.toString() ?? "";

                    final matchSearch = ten.contains(_searchText);
                    final matchStatus = _filterStatus == "Tất cả" || trangThai == _filterStatus;

                    return matchSearch && matchStatus;
                  }).toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, color: _borderColor, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              "Không tìm thấy danh mục con",
                              style: TextStyle(
                                fontSize: 16,
                                color: _textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Thử điều chỉnh từ khóa tìm kiếm hoặc bộ lọc",
                              style: TextStyle(
                                fontSize: 14,
                                color: _hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final isActive = data["TrangThai"] == "Hoạt Động";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderColor),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                data["HinhAnh"] ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(
                                  color: _backgroundColor,
                                  alignment: Alignment.center,
                                  child: Icon(Icons.image_not_supported,
                                      color: _borderColor, size: 24),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: _primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            data["TenDanhMucCon"] ?? "Không có tên",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: _textColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? _successColor.withOpacity(0.1) : _errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isActive ? _successColor : _errorColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  data["TrangThai"] ?? "Không xác định",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isActive ? _successColor : _errorColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit Button
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditSubCategoryPage(
                                        idDanhMucCon: data["IdDanhMucCon"],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.edit, color: _primaryColor, size: 20),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Delete Button
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DeleteSubCategoryPage(
                                        idDanhMucCon: data["IdDanhMucCon"],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.delete, color: _errorColor, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSubCategory()),
          );

          if (result == true) {
            setState(() {});
          }
        },
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Thêm danh mục con",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


