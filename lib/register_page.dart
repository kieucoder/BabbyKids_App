import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _tenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sdtController = TextEditingController();
  final TextEditingController _matkhauController = TextEditingController();
  final TextEditingController _diachiController = TextEditingController();
  String? _gioiTinh; // giá trị: "Nam" hoặc "Nữ"

  bool _isObscure = true;
  Future<void> register() async {
    if (_tenController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _sdtController.text.trim().isEmpty ||
        _matkhauController.text.trim().isEmpty ||
        _diachiController.text.trim().isEmpty ||
        _gioiTinh == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin bao gồm giới tính')),
      );
      return;
    }

    try {
      final khachHangRef = FirebaseFirestore.instance.collection('khachhang');

      // 🔹 Kiểm tra trùng email
      final emailCheck = await khachHangRef
          .where('email', isEqualTo: _emailController.text.trim())
          .get();
      if (emailCheck.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email này đã được đăng ký')),
        );
        return;
      }

      // 🔹 Kiểm tra trùng số điện thoại
      final phoneCheck = await khachHangRef
          .where('sdt', isEqualTo: _sdtController.text.trim())
          .get();
      if (phoneCheck.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số điện thoại này đã được đăng ký')),
        );
        return;
      }

      // 🔹 Lấy khách hàng cuối cùng (có mã lớn nhất)
      final querySnapshot = await khachHangRef
          .orderBy('idkhachhang', descending: true)
          .limit(1)
          .get();

      String newMaKH;

      if (querySnapshot.docs.isEmpty) {
        // Nếu chưa có khách hàng nào
        newMaKH = 'KH01';
      } else {
        // Lấy mã KH cuối cùng (ví dụ KH07)
        final lastMaKH = querySnapshot.docs.first['idkhachhang'];
        // Cắt lấy phần số và +1
        final lastNumber = int.parse(lastMaKH.substring(2));
        final nextNumber = lastNumber + 1;
        // Gắn lại thành dạng KH01, KH02,...
        newMaKH = 'KH${nextNumber.toString().padLeft(2, '0')}';
      }

      // 🔹 Tạo document mới (đặt id là mã KH luôn)
      final newDocRef = khachHangRef.doc(newMaKH);

      await newDocRef.set({
        'idkhachhang': newMaKH,
        'ten': _tenController.text.trim(),
        'email': _emailController.text.trim(),
        'sdt': _sdtController.text.trim(),
        'matkhau': _matkhauController.text.trim(),
        'diachi': _diachiController.text.trim(),
        'gioitinh': _gioiTinh,

      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thành công! Mã KH: $newMaKH')),
      );

      // 🔹 Reset form
      _tenController.clear();
      _emailController.clear();
      _sdtController.clear();
      _matkhauController.clear();
      _diachiController.clear();
      setState(() {
        _gioiTinh = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng ký: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE6EB), Color(0xFFFFC1E3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Logo tròn
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC1E3), Color(0xFFFF80AB)], // hồng nhạt chuyển hồng đậm
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4), // tạo viền mỏng tinh tế
                    child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white, // nền trắng để viền nổi bật
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),



                const SizedBox(height: 25),
                Text(
                  'ĐĂNG KÝ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tạo tài khoản Bobby Home ',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 35),
                _buildTextField(_tenController, 'Họ Tên', Icons.person),

                const SizedBox(height: 15),
                _buildTextField(
                    _sdtController, 'Số điện thoại', Icons.phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 15),
                // 🔹 Chọn giới tính
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giới tính',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Nam',
                                    style: TextStyle(color: Colors.black87)),
                                value: 'Nam',
                                activeColor: Colors.pinkAccent,
                                groupValue: _gioiTinh,
                                onChanged: (value) {
                                  setState(() {
                                    _gioiTinh = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Nữ',
                                    style: TextStyle(color: Colors.black87)),
                                value: 'Nữ',
                                activeColor: Colors.pinkAccent,
                                groupValue: _gioiTinh,
                                onChanged: (value) {
                                  setState(() {
                                    _gioiTinh = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                _buildTextField(
                    _emailController, 'Email', Icons.email,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                _buildTextField(
                    _diachiController, 'Địa chỉ', Icons.location_on),
                const SizedBox(height: 15),
                _buildTextField(
                  _matkhauController,
                  'Mật khẩu',
                  Icons.lock,
                  obscureText: _isObscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.pinkAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 30),
                // 🔸 Nút đăng ký gradient
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF80AB), Color(0xFFF50057)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Đăng Ký',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã có tài khoản? ',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DangNhapPage()),
                        );
                      },
                      child: const Text(
                        'Đăng Nhập',
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 40),
                Text(
                  'Cảm ơn bạn đã chọn Bobby Home 💗',
                  style: TextStyle(
                    color: Colors.pinkAccent.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
        Widget? suffixIcon,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.pinkAccent),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.pinkAccent),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
        ),
      ),
    );
  }
}


