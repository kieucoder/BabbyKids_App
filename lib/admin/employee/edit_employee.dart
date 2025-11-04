import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditEmployeePage extends StatefulWidget {
  final String docId; // 👈 Nhận docId từ danh sách

  const EditEmployeePage({super.key, required this.docId});

  @override
  State<EditEmployeePage> createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _tenController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  String? _selectedVaiTro;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final doc =
    await _firestore.collection('nhanvien').doc(widget.docId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _tenController.text = data['TenNhanVien'] ?? '';
      _matKhauController.text = data['MatKhau'] ?? '';
      _selectedVaiTro = data['VaiTro'];
      setState(() {});
    }
  }

  Future<void> _updateEmployee() async {
    await _firestore.collection('nhanvien').doc(widget.docId).update({
      'TenNhanVien': _tenController.text.trim(),
      'MatKhau': _matKhauController.text.trim(),
      'VaiTro': _selectedVaiTro,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Cập nhật nhân viên thành công!')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa nhân viên"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tenController,
              decoration: const InputDecoration(labelText: "Tên nhân viên"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _matKhauController,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedVaiTro,
              items: const [
                DropdownMenuItem(value: "Admin", child: Text("Admin")),
                DropdownMenuItem(value: "Nhân viên", child: Text("Nhân viên")),
              ],
              onChanged: (value) => setState(() => _selectedVaiTro = value),
              decoration: const InputDecoration(labelText: "Vai trò"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 40)),
              onPressed: _updateEmployee,
              child: const Text("Lưu thay đổi",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
