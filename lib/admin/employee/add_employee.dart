import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _tenNhanVienController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedVaiTro;
  bool _isSaving = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Hàm tạo mã NV tự động tăng (NV01, NV02,...)
  Future<String> _getNextMaNV() async {
    final counterRef = _firestore.collection('counters').doc('nhanvienCounter');
    final counterDoc = await counterRef.get();

    int current = 0;

    if (counterDoc.exists) {
      current = counterDoc['value'] + 1;
      await counterRef.update({'value': current});
    } else {
      current = 1;
      await counterRef.set({'value': current});
    }

    return 'NV${current.toString().padLeft(2, '0')}';
  }

  Future<void> _saveEmployee() async {
    if (_tenNhanVienController.text.isEmpty ||
        _matKhauController.text.isEmpty ||
        _selectedVaiTro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 🔹 Kiểm tra trùng tên hoặc email
      final existing = await _firestore
          .collection("nhanvien")
          .where("Email", isEqualTo: _emailController.text.trim())
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email này đã tồn tại trong hệ thống!")),
        );
        setState(() => _isSaving = false);
        return;
      }
      // 🔹 Lấy nhân viên có mã NV lớn nhất
      final snapshot = await _firestore
          .collection("nhanvien")
          .orderBy("MaNV", descending: true)
          .limit(1)
          .get();

      // 🔹 Tạo mã mới: NV01, NV02, NV03...
      String newMaNV = "NV01";
      if (snapshot.docs.isNotEmpty) {
        final lastMa = snapshot.docs.first["MaNV"]; // ví dụ: NV03
        final number = int.tryParse(lastMa.substring(2)) ?? 0;
        final nextNumber = number + 1;
        newMaNV = "NV${nextNumber.toString().padLeft(2, '0')}";
      }

      // 🔹 Lưu vào Firestore (doc theo mã nhân viên)
      await _firestore.collection("nhanvien").doc(newMaNV).set({
        "MaNV": newMaNV,
        "TenNhanVien": _tenNhanVienController.text.trim(),
        "Email": _emailController.text.trim(),
        "MatKhau": _matKhauController.text.trim(),
        "VaiTro": _selectedVaiTro,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã thêm nhân viên $newMaNV thành công")),
      );

      // 🔹 Reset form
      _tenNhanVienController.clear();
      _matKhauController.clear();
      _emailController.clear();
      setState(() {
        _selectedVaiTro = null;
      });

      Navigator.pop(context, true); // Quay lại trang danh sách
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi thêm nhân viên: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }


  /// 🔹 Hàm lưu nhân viên vào Firestore


  @override
  Widget build(BuildContext context) {

    final Color mainBlue = const Color(0xFF007BFF);
    final Color lightBlue = const Color(0xFFe6f2ff);
    bool _obscurePassword = true; //ẩn hiện mật khẩu
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thêm danh mục",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: mainBlue,
        elevation: 3,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Thông tin nhân viên",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 24),

                // Tên
                TextField(
                  controller: _tenNhanVienController,
                  decoration: InputDecoration(
                    labelText: "Tên nhân viên",
                    prefixIcon: const Icon(Icons.category_outlined, color: Colors.blueAccent),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: mainBlue, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: mainBlue, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 18),
                // ẩn mật khẩu

              TextField(
                controller: _matKhauController,
                obscureText: _obscurePassword, // ẩn/hiện ký tự khi gõ
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),

                  // 👁️ Nút hiện/ẩn mật khẩu
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: _obscurePassword ? Colors.grey : Colors.blueAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword; // Đổi trạng thái ẩn/hiện
                      });
                    },
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color (0xFF007BFF), width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50.withOpacity(0.3),
                ),
              ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: _selectedVaiTro,
                  decoration: InputDecoration(
                    labelText: "Vai trò",
                    prefixIcon: const Icon(Icons.supervised_user_circle_outlined, color: Colors.blueAccent),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: mainBlue, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50.withOpacity(0.3),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Admin',
                      child: Text('Admin'),
                    ),
                    DropdownMenuItem(
                      value: 'Nhân viên',
                      child: Text('Nhân viên'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVaiTro = value!;
                    });
                  },
                ),
                const SizedBox(height: 18),


                // Nút lưu
                ElevatedButton.icon(
                  onPressed: _saveEmployee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
                  label: const Text(
                    "Lưu danh mục",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}

