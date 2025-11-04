import 'package:appshopsua/admin/employee/add_employee.dart';
import 'package:appshopsua/admin/employee/edit_employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListEmployeePage extends StatefulWidget {
  const ListEmployeePage({super.key});

  @override
  State<ListEmployeePage> createState() => _ListEmployeePageState();
}

class _ListEmployeePageState extends State<ListEmployeePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchText = "";

  Future<void> _deleteEmployee(String docId) async {
    try {
      await _firestore.collection("nhanvien").doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Xóa nhân viên thành công")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xóa: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainBlue = Color(0xFF007BFF);
    const Color lightBlue = Color(0xFFE6F2FF);

    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: const Text(
          "Danh sách nhân viên",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: mainBlue,
        centerTitle: true,
        elevation: 3,
      ),

      body: Column(
        children: [
          // 🔍 Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm nhân viên...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) =>
                  setState(() => _searchText = value.trim().toLowerCase()),
            ),
          ),

          // 📋 Danh sách nhân viên (Realtime)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("nhanvien").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(" Chưa có nhân viên nào được thêm."),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ten =
                      data["TenNhanVien"]?.toString().toLowerCase() ?? "";
                  return ten.contains(_searchText);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(" Không tìm thấy nhân viên phù hợp."),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final ten = data["TenNhanVien"] ?? "Không rõ";
                    final maNV = data["MaNV"] ?? "—";
                    final vaiTro = data["VaiTro"] ?? "—";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            ten.isNotEmpty ? ten[0].toUpperCase() : "?",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          ten,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text("Mã NV: $maNV\nVai trò: $vaiTro"),
                        isThreeLine: true,

                        // 👉 Thay trailing bằng 2 nút Sửa + Xóa
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✏️ Nút sửa
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEmployeePage(docId: doc.id),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.edit, color: Colors.blue, size: 22),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 🗑️ Nút xóa
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                _showDeleteDialog(context, doc.id, ten);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete, color: Colors.red, size: 22),
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
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeePage()),
          );

          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Nhân viên mới đã được thêm!")),
            );
          }
        },
        label: const Text("Thêm nhân viên"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // 🎨 Dialog xóa đẹp mắt
  void _showDeleteDialog(BuildContext context, String docId, String tenNV) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.redAccent, size: 60),
                const SizedBox(height: 12),
                Text(
                  "Xác nhận xóa",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Bạn có chắc muốn xóa nhân viên \"$tenNV\" không?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✏️ Nút Sửa
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Sửa",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Navigator.pop(context); // Đóng dialog trước
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditEmployeePage(docId: docId),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 🗑️ Nút Xóa
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Xóa",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _deleteEmployee(docId);
                        },
                      ),
                    ),
                  ],
                ),


              ],
            ),
          ),
        );
      },
    );
  }
}
