import 'dart:convert';
import 'package:http/http.dart' as http;



Future<String?> createVNPayPayment(int amount) async {
  try {
    print("⚠️ Bắt đầu gửi POST tới server...");
    final response = await http.post(
      Uri.parse('https://vnpay-render.onrender.com/vnpay_create_payment.php'),
      body: {
        'MaDonHang': DateTime.now().millisecondsSinceEpoch.toString(),
        'TongTien': amount.toString(),
      },
    );
    print("📦 Response status: ${response.statusCode}");
    print("📦 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("📤 JSON decode result: $data");
      final url = data['url'];
      if (url != null && url is String) {
        print("🔗 URL tạo ra từ PHP: $url");
        return url.replaceAll(r'\/', '/');
      } else {
        print("❌ Không tìm thấy key 'url' trong JSON: $data");
      }
    } else {
      print("❌ VNPay API trả về lỗi: ${response.statusCode}");
    }
  } catch (e, stack) {
    print("❌ Lỗi tạo link VNPay: $e");
    print("📚 Stacktrace: $stack");
  }
  return null;
}