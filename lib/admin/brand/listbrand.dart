// import 'package:appshopsua/admin/brand/addbrand.dart';
// import 'package:appshopsua/admin/brand/deletebrand.dart';
// import 'package:appshopsua/admin/brand/editbrand.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class ListBrand extends StatefulWidget {
//   const ListBrand({super.key});
//
//   @override
//   State<ListBrand> createState() => _ListBrandState();
// }
//
// class _ListBrandState extends State<ListBrand> {
//   final Color _primaryColor = const Color(0xFF007BFF);
//   final Color _backgroundColor = const Color(0xFFF8F9FA);
//   final Color _surfaceColor = const Color(0xFFFFFFFF);
//   final Color _textColor = const Color(0xFF212529);
//   final Color _borderColor = const Color(0xFFDEE2E6);
//   final Color _successColor = const Color(0xFF28A745);
//   final Color _errorColor = const Color(0xFFDC3545);
//   final Color _hintColor = const Color(0xFF6C757D);
//
//   String _searchText = "";
//   String _filterStatus = "Tất cả";
//   final TextEditingController _searchController = TextEditingController();
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
//           "Danh sách thương hiệu",
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
//       body: Column(
//         children: [
//           // Header Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Quản lý thương hiệu",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: _textColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Danh sách tất cả thương hiệu trong hệ thống",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: _hintColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Search and Filter Card
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _surfaceColor,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   // Search Field
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Tìm kiếm",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: _textColor,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
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
//                           child: TextField(
//                             controller: _searchController,
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               hintText: "Nhập tên thương hiệu...",
//                               hintStyle: TextStyle(color: _hintColor),
//                               prefixIcon: Icon(Icons.search, color: _primaryColor),
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                             style: TextStyle(color: _textColor, fontSize: 14),
//                             onChanged: (value) => setState(() => _searchText = value.trim().toLowerCase()),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Filter Field
//                   Container(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Lọc trạng thái",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: _textColor,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
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
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               value: _filterStatus,
//                               isExpanded: true,
//                               padding: const EdgeInsets.symmetric(horizontal: 16),
//                               icon: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryColor),
//                               items: [
//                                 DropdownMenuItem(
//                                   value: "Tất cả",
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.all_inclusive, color: _primaryColor, size: 20),
//                                       const SizedBox(width: 12),
//                                       Text("Tất cả trạng thái", style: TextStyle(color: _textColor)),
//                                     ],
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: "Hoạt Động",
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.check_circle, color: _successColor, size: 20),
//                                       const SizedBox(width: 12),
//                                       Text("Hoạt Động", style: TextStyle(color: _textColor)),
//                                     ],
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: "Ngưng Hoạt Động",
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.pause_circle, color: _errorColor, size: 20),
//                                       const SizedBox(width: 12),
//                                       Text("Ngưng Hoạt Động", style: TextStyle(color: _textColor)),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                               onChanged: (value) => setState(() => _filterStatus = value!),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Content Card
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection("thuonghieu")
//                     .orderBy("createdAt", descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: _surfaceColor,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const CircularProgressIndicator(),
//                       ),
//                     );
//                   }
//
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return Center(
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: _surfaceColor,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.branding_watermark_outlined, color: _borderColor, size: 64),
//                             const SizedBox(height: 16),
//                             Text(
//                               "Chưa có thương hiệu nào",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: _textColor,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Hãy thêm thương hiệu đầu tiên",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: _hintColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }
//
//                   final filteredDocs = snapshot.data!.docs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final ten = data["TenThuongHieu"]?.toString().toLowerCase() ?? "";
//                     final trangThai = data["TrangThai"]?.toString() ?? "";
//
//                     final matchSearch = ten.contains(_searchText);
//                     final matchStatus = _filterStatus == "Tất cả" || trangThai == _filterStatus;
//
//                     return matchSearch && matchStatus;
//                   }).toList();
//
//                   if (filteredDocs.isEmpty) {
//                     return Center(
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: _surfaceColor,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.search_off, color: _borderColor, size: 64),
//                             const SizedBox(height: 16),
//                             Text(
//                               "Không tìm thấy thương hiệu",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: _textColor,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Thử điều chỉnh từ khóa tìm kiếm hoặc bộ lọc",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: _hintColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }
//
//                   return ListView.builder(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     itemCount: filteredDocs.length,
//                     itemBuilder: (context, index) {
//                       final data = filteredDocs[index].data() as Map<String, dynamic>;
//                       final isActive = data["TrangThai"] == "Hoạt Động";
//
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         decoration: BoxDecoration(
//                           color: _surfaceColor,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 6,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.all(16),
//                           leading: Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: _borderColor),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.network(
//                                 data["HinhAnh"] ?? "",
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stack) => Container(
//                                   color: _backgroundColor,
//                                   alignment: Alignment.center,
//                                   child: Icon(Icons.image_not_supported,
//                                       color: _borderColor, size: 24),
//                                 ),
//                                 loadingBuilder: (context, child, loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return Container(
//                                     alignment: Alignment.center,
//                                     child: CircularProgressIndicator(
//                                       value: loadingProgress.expectedTotalBytes != null
//                                           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                           : null,
//                                       color: _primaryColor,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           title: Text(
//                             data["TenThuongHieu"] ?? "Không có tên",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                               color: _textColor,
//                             ),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 6),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: isActive ? _successColor.withOpacity(0.1) : _errorColor.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(6),
//                                   border: Border.all(
//                                     color: isActive ? _successColor : _errorColor,
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Text(
//                                   data["TrangThai"] ?? "Không xác định",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: isActive ? _successColor : _errorColor,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               // Edit Button
//                               InkWell(
//                                 borderRadius: BorderRadius.circular(8),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => EditBrandPage(
//                                         idThuongHieu: data["IdThuongHieu"],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: _primaryColor.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Icon(Icons.edit, color: _primaryColor, size: 20),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//
//                               // Delete Button
//                               InkWell(
//                                 borderRadius: BorderRadius.circular(8),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => DeleteBrandPage(
//                                         idThuongHieu: data["IdThuongHieu"],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: _errorColor.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Icon(Icons.delete, color: _errorColor, size: 20),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AddBrandPage()),
//           );
//
//           if (result == true) {
//             setState(() {});
//           }
//         },
//         backgroundColor: _primaryColor,
//         foregroundColor: Colors.white,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           "Thêm thương hiệu",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:appshopsua/admin/brand/addbrand.dart';
import 'package:appshopsua/admin/brand/deletebrand.dart';
import 'package:appshopsua/admin/brand/editbrand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListBrand extends StatefulWidget {
  const ListBrand({super.key});

  @override
  State<ListBrand> createState() => _ListBrandState();
}

class _ListBrandState extends State<ListBrand> {
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
          "Danh sách thương hiệu",
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
                  "Quản lý thương hiệu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Danh sách tất cả thương hiệu trong hệ thống",
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
                              hintText: "Nhập tên thương hiệu...",
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
                stream: FirebaseFirestore.instance
                    .collection("thuonghieu")
                    .orderBy("IdThuongHieu", descending: true)
                    .snapshots(),
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
                            Icon(Icons.branding_watermark_outlined, color: _borderColor, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              "Chưa có thương hiệu nào",
                              style: TextStyle(
                                fontSize: 16,
                                color: _textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Hãy thêm thương hiệu đầu tiên",
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

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final ten = data["TenThuongHieu"]?.toString().toLowerCase() ?? "";
                    final trangThai = data["TrangThai"]?.toString() ?? "";

                    final matchSearch = ten.contains(_searchText);
                    final matchStatus = _filterStatus == "Tất cả" || trangThai == _filterStatus;

                    return matchSearch && matchStatus;
                  }).toList();

                  if (filteredDocs.isEmpty) {
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
                              "Không tìm thấy thương hiệu",
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
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data() as Map<String, dynamic>;
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
                            data["TenThuongHieu"] ?? "Không có tên",
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
                                      builder: (context) => EditBrandPage(
                                        idThuongHieu: data["IdThuongHieu"],
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
                                      builder: (context) => DeleteBrandPage(
                                        idThuongHieu: data["IdThuongHieu"],
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
            MaterialPageRoute(builder: (context) => AddBrandPage()),
          );

          if (result == true) {
            setState(() {});
          }
        },
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Thêm thương hiệu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}