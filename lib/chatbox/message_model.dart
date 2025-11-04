
class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl; // ảnh sản phẩm (nếu có)\
  final List<Map<String, dynamic>>? products;
  final bool isProductMessage;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.products,
    this.isProductMessage = false,
  });
}
