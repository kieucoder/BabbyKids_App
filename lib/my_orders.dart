import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrdersPage extends StatelessWidget {
  final String email; // email người dùng hiện tại

  const MyOrdersPage({super.key, required this.email});

  Future<void> _cancelOrder(String docId, BuildContext context) async {
    try {
      // Cập nhật trạng thái thành "Đã hủy"
      await FirebaseFirestore.instance.collection('donhang').doc(docId).update({
        'trangthai': 'Đã hủy',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được hủy thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi hủy đơn hàng: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('donhang')
            .where('email', isEqualTo: email)
            .orderBy('ngaydat', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Bạn chưa có đơn hàng nào.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final don = docs[index];
              final data = don.data() as Map<String, dynamic>;

              final String trangthai = data['trangthai'];
              final bool coTheHuy =
                  trangthai == 'Đang xử lý' || trangthai == 'Đang giao';

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text('Mã đơn: ${data['madonhang']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trạng thái: $trangthai'),
                      Text('Tổng tiền: ${data['tongtien']}đ'),
                    ],
                  ),
                  trailing: coTheHuy
                      ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Xác nhận trước khi hủy
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Xác nhận hủy đơn'),
                          content: const Text('Bạn có chắc muốn hủy đơn hàng này không?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Không'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _cancelOrder(don.id, context);
                              },
                              child: const Text('Có'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Hủy đơn'),
                  )
                      : Text(
                    trangthai,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChiTietDonHangPage(donHang: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChiTietDonHangPage extends StatelessWidget {
  final Map<String, dynamic> donHang;

  const ChiTietDonHangPage({super.key, required this.donHang});

  @override
  Widget build(BuildContext context) {
    final chitiet = List<Map<String, dynamic>>.from(donHang['chitiet']);
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết ${donHang['madonhang']}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Khách hàng: ${donHang['tenkhachhang']}'),
            Text('Trạng thái: ${donHang['trangthai']}'),
            Text('Tổng tiền: ${donHang['tongtien']}đ'),
            const Divider(),
            const Text('Chi tiết sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...chitiet.map((sp) => ListTile(
              title: Text(sp['tensp']),
              subtitle: Text('Số lượng: ${sp['soluong']}'),
              trailing: Text('${sp['dongia']}đ'),
            )),
          ],
        ),
      ),
    );
  }
}
