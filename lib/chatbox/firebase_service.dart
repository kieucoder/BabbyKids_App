
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getSuggestedProducts(String userMessage) async {
    try {
      final productsRef = _firestore.collection('sanpham');
      final querySnapshot = await productsRef.get();

      final text = userMessage.toLowerCase();

      // B1: Tìm giá trong câu chat (vd: 200k → 200000)
      final match = RegExp(r'(\d+)(k|nghìn|ngàn)?').firstMatch(text);

      int? maxPrice;

      if (match != null) {
        maxPrice = int.parse(match.group(1)!);

        if (match.group(2) != null) {
          maxPrice = maxPrice! * 1000; // "k" → nhân 1000
        }
      }

      // B2: Nếu người dùng có nói chữ "dưới"
      if (text.contains("dưới") || text.contains("<= ") || text.contains("<")) {
        if (maxPrice != null) {
          // Lấy tất cả sản phẩm có giá <= maxPrice
          return querySnapshot.docs
              .map((doc) => doc.data())
              .where((product) =>
          (product['Gia'] is num) && product['Gia'] <= maxPrice!)
              .toList();
        }
      }

      // B3: Nếu chỉ hỏi chung, lọc theo tên không liên quan đến giá (fallback)
      final keyword = text.replaceAll(RegExp(r'\d+|k|nghìn|ngàn|vnd|vnđ|đ'), "").trim();

      return querySnapshot.docs
          .map((doc) => doc.data())
          .where((product) =>
      keyword.isEmpty ||
          (product['TenSanPham']?.toString().toLowerCase().contains(keyword) ??
              false) ||
          (product['MoTa']?.toString().toLowerCase().contains(keyword) ??
              false))
          .toList();
    } catch (e) {
      print("Lỗi khi lấy dữ liệu từ Firestore: $e");
      return [];
    }
  }

}
