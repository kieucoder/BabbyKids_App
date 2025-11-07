import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class OrderDetailsBottomSheet extends StatelessWidget {
  final String maDonHang;
  final Map<String, dynamic> orderData;
  final QuerySnapshot details;
  final String status;
  final Color statusColor;
  final String Function(num?) formatPrice;
  final String Function(Timestamp?) formatDate;

  const OrderDetailsBottomSheet({
    super.key,

    required this.maDonHang,
    required this.orderData,
    required this.details,
    required this.status,
    required this.statusColor,
    required this.formatPrice,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final List<QueryDocumentSnapshot> items = details.docs;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              "Mã đơn hàng: $maDonHang",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Ngày tạo: ${formatDate(orderData['NgayTao'])}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text("Trạng thái: "),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            const Text("Chi tiết đơn hàng:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: Text(data['TenSanPham'] ?? 'Sản phẩm'),
                subtitle: Text('Số lượng: ${data['SoLuong']}'),
                trailing: Text(
                  formatPrice(data['ThanhTien']),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng tiền:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  formatPrice(orderData['TongTien']),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B14F),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text(
                "Đóng",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
