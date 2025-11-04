
import 'package:appshopsua/admin/homeadmin_page.dart';
import 'package:appshopsua/cart/cart_page.dart';
import 'package:appshopsua/cart/orderdetail.dart' show OrderDetailsBottomSheet;
import 'package:appshopsua/forgotpass_page.dart';
import 'package:appshopsua/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';

class DangNhapPage extends StatefulWidget {
  const DangNhapPage({Key? key}) : super(key: key);

  @override
  State<DangNhapPage> createState() => _DangNhapPageState();
}

class _DangNhapPageState extends State<DangNhapPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  bool _isObscure = true;


  void login() async {
    String email = _emailController.text.trim();
    String matkhau = _matKhauController.text.trim();

    if (email.isEmpty || matkhau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    try {
      // 🔹 Kiểm tra trong bảng KHÁCH HÀNG
      QuerySnapshot khachhangSnapshot = await FirebaseFirestore.instance
          .collection('khachhang')
          .where('email', isEqualTo: email)
          .where('matkhau', isEqualTo: matkhau)
          .get();

      if (khachhangSnapshot.docs.isNotEmpty) {
        var userDoc = khachhangSnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // 🔹 Lấy id khách hàng — nếu bạn có trường 'idkhachhang' trong Firestore thì dùng nó
        String idKhachHang = userData['idkhachhang'] ?? userDoc.id;

        // 🔹 Lưu thông tin vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('idKhachHang', idKhachHang);
        await prefs.setString('ten', userData['ten'] ?? '');
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setString('sdt', userData['sdt'] ?? '');
        await prefs.setString('diachi', userData['diachi'] ?? '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thành công, chào ${userData['ten']}!')),
        );

        // 🔹 Chuyển sang HomePage và truyền id + data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              idKhachHang: idKhachHang,
              userData: userData,
            ),
          ),
        );
        return;
      }

      // 🔹 Nếu không phải khách hàng, kiểm tra NHÂN VIÊN
      QuerySnapshot nhanvienSnapshot = await FirebaseFirestore.instance
          .collection('nhanvien')
          .where('Email', isEqualTo: email)
          .where('MatKhau', isEqualTo: matkhau)
          .get();

      if (nhanvienSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thành công (Admin)')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
        return;
      }

      // 🔹 Nếu không tìm thấy
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email hoặc mật khẩu không đúng')),
      );
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại sau')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
      true, // đảm bảo không bị che khi bàn phím bật lên
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE6EB), Color(0xFFFFC1E3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
              const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🌸 Logo tròn
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC1E3), Color(0xFFFF80AB)],
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
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white,
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
                    'ĐĂNG NHẬP',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Chào mừng bạn quay lại với Bobby Home 💖',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 40),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _matKhauController,
                    'Mật khẩu',
                    Icons.lock,
                    obscureText: _isObscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.pinkAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(

                      child:
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          "Quên mật khẩu?",
                          style: TextStyle(color: Colors.pinkAccent),
                        ),
                      ),

                    ),
                  ),

                  const SizedBox(height: 35),
                  // 🌸 Nút Đăng nhập Gradient
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
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Đăng Nhập',
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
                        'Chưa có tài khoản? ',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                 RegisterPage()),
                          );
                        },
                        child: const Text(
                          'Đăng Ký',
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
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscureText = false,
        Widget? suffixIcon,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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


