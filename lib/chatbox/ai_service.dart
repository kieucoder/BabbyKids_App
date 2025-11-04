import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = "xxxxxxx";
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';


  Future<List<String>> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o", // nên dùng model mới thay cho gpt-3.5
          "messages": [
            {
              "role": "system",
              "content": "Bạn là trợ lý bán hàng. Trả về danh sách tên sản phẩm có trong cửa hàng, tối đa 5 sản phẩm."
            },
            {"role": "user", "content": message}
          ],
          "max_tokens": 200,
          "temperature": 0.7,
        }),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["choices"] == null || data["choices"].isEmpty) {
          throw Exception("Phản hồi không có nội dung từ OpenAI");
        }

        final content = data['choices'][0]['message']['content'] as String;

        // Tách danh sách sản phẩm bằng dấu phẩy hoặc xuống dòng
        List<String> products = content
            .split(RegExp(r'[,|\n|-]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        return products;
      } else {
        // Nếu API trả về lỗi thì parse message lỗi của OpenAI
        try {
          final errData = jsonDecode(response.body);
          final errMsg = errData["error"]?["message"] ?? response.body;
          throw Exception("OpenAI lỗi ${response.statusCode}: $errMsg");
        } catch (_) {
          throw Exception(
              "OpenAI lỗi ${response.statusCode}: ${response.body}");
        }
      }
    } catch (e, s) {
      print("AI Service Error: $e");
      print(s);
      // Trả về thông báo lỗi trực tiếp để hiển thị trên chat
      return ["⚠️ Lỗi: $e"];
    }
  }
}

