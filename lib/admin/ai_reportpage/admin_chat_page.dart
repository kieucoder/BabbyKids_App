import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// hàm xuất file pdf
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';



class AdminChatPage extends StatefulWidget {
  const AdminChatPage({Key? key}) : super(key: key);

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];

  final String apiKey = "xxxx"; // ⚠️ Thay API key thật

  bool _loading = false;

  // 🔹 Gửi câu hỏi admin và nhận phản hồi từ OpenAI
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": text});
      _loading = true;
    });

    final summary = await _getOrderSummary();
    final prompt = '''
Bạn là chuyên gia phân tích bán hàng. Dữ liệu tổng hợp:
$summary

Hãy trả lời câu hỏi admin dưới đây một cách dễ hiểu:
"$text"
''';

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "system", "content": "Bạn là chuyên gia phân tích bán hàng."},
            {"role": "user", "content": prompt},
          ],
          "max_tokens": 500,
        }),
      );

      String reply;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        reply = data['choices'][0]['message']['content'];
      } else {
        reply = "❌ Lỗi GPT: ${response.body}";
      }

      setState(() {
        messages.add({"role": "assistant", "content": reply});
        _loading = false;
      });

      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      setState(() {
        messages.add({"role": "assistant", "content": "❌ Lỗi: $e"});
        _loading = false;
      });
    }
  }


  // 🔹 Lấy dữ liệu Firestore tóm tắt
  Future<String> _getOrderSummary() async {
    // 🔹 Lấy tất cả đơn hàng
    final donHangSnapshot = await FirebaseFirestore.instance.collection('donhang').get();
    if (donHangSnapshot.docs.isEmpty) return "Không có dữ liệu đơn hàng.";

    double totalRevenue = 0;
    double todayRevenue = 0;
    Map<String, int> productQuantity = {}; // IdSanPham => tổng số lượng

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    for (var donhang in donHangSnapshot.docs) {
      final data = donhang.data();
      double tongTien = (data['TongTien'] ?? 0).toDouble();
      totalRevenue += tongTien;

      final date = (data['NgayTao'] as Timestamp?)?.toDate();
      if (date != null && formatter.format(date) == formatter.format(now)) {
        todayRevenue += tongTien;
      }

      // 🔹 Lấy chi tiết đơn hàng liên quan
      final chiTietSnapshot = await FirebaseFirestore.instance
          .collection('chitietdonhang')
          .where('MaDonHang', isEqualTo: data['MaDonHang'])
          .get();

      for (var item in chiTietSnapshot.docs) {
        final ct = item.data();
        String id = ct['IdSanPham'] ?? "unknown";
        int quantity = (ct['SoLuong'] ?? 1).toInt();
        productQuantity[id] = (productQuantity[id] ?? 0) + quantity;
      }
    }

    // 🔹 Tìm sản phẩm bán chạy / ít nhất
    String topProductId = "Chưa có";
    String leastProductId = "Chưa có";

    if (productQuantity.isNotEmpty) {
      final sorted = productQuantity.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topProductId = sorted.first.key;
      leastProductId = sorted.last.key;
    }

    return '''
- Tổng doanh thu: ${NumberFormat.decimalPattern('vi_VN').format(totalRevenue)} VND
- Doanh thu hôm nay: ${NumberFormat.decimalPattern('vi_VN').format(todayRevenue)} VND
- Sản phẩm bán chạy nhất (IdSanPham): $topProductId
- Sản phẩm bán ít nhất (IdSanPham): $leastProductId
- Số lượng từng sản phẩm: ${jsonEncode(productQuantity)}
''';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🤖 Chat AI Admin"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.pinkAccent : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['content'] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Nhập câu hỏi phân tích...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pinkAccent),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
