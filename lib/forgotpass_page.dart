import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _sendResetEmail() async {
    setState(() => _loading = true);

    try {
      // Gửi email reset mật khẩu qua Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📩 Email khôi phục mật khẩu đã được gửi!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Quay lại trang đăng nhập (nếu có)
    } on FirebaseAuthException catch (e) {
      String message = "Lỗi không xác định";

      if (e.code == 'user-not-found') {
        message = "Không tìm thấy người dùng với email này!";
      } else if (e.code == 'invalid-email') {
        message = "Email không hợp lệ!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$message'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quên mật khẩu"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Nhập địa chỉ email của bạn, chúng tôi sẽ gửi liên kết khôi phục mật khẩu:",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _sendResetEmail,
              icon: const Icon(Icons.send),
              label: const Text("Gửi email khôi phục"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


