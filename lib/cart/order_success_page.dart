// import 'package:appshopsua/home_page.dart';
// import 'package:flutter/material.dart';
//
// class OrderSuccessPage extends StatelessWidget {
//   final String idKhachHang;
//   final Map<String, dynamic> userData;
//
//   const OrderSuccessPage({
//     Key? key,
//     required this.idKhachHang,
//     required this.userData,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.pink,
//                 size: 100,
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 "Đặt hàng thành công!",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 "Cảm ơn bạn đã mua hàng tại Bobby Home.\nĐơn hàng của bạn đang được xử lý.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               ElevatedButton(
//                 onPressed: () {
//                   // Chuyển hướng về trang chủ và xóa hết stack
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => HomePage(
//                         idKhachHang: idKhachHang,
//                         userData: userData,
//                       ),
//                     ),
//                         (route) => false, // Xóa tất cả các route trước đó
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.pink,
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   "Quay về Trang Chủ ",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//



// order_success_page.dart
import 'package:appshopsua/cart/orderhistory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderSuccessPage extends StatefulWidget {
  final String orderId;
  final String idKhachHang;
  final Map<String, dynamic> userData;

  const OrderSuccessPage({
    super.key,
    required this.orderId,
    required this.idKhachHang,
    required this.userData,
  });

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  Map<String, dynamic> _orderData = {};
  List<Map<String, dynamic>> _orderDetails = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    try {
      // Load thông tin đơn hàng
      final orderDoc = await FirebaseFirestore.instance
          .collection('donhang')
          .doc(widget.orderId)
          .get();

      if (orderDoc.exists) {
        setState(() {
          _orderData = orderDoc.data() ?? {};
        });

        // Load chi tiết đơn hàng
        final detailsSnapshot = await FirebaseFirestore.instance
            .collection('chitietdonhang')
            .where('MaDonHang', isEqualTo: widget.orderId)
            .get();

        setState(() {
          _orderDetails = detailsSnapshot.docs
              .map((doc) => doc.data())
              .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Lỗi khi tải thông tin đơn hàng: $e');
      setState(() => _loading = false);
    }
  }

  String _formatPrice(double price) {
    int intPrice = price.round();
    String formatted = intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return '$formattedđ';
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.lightGreen.shade50,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Đặt hàng thành công!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mã đơn hàng: ${widget.orderId}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cảm ơn bạn đã mua sắm tại AVAKids',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    final total = (_orderData['TongTien'] ?? 0).toDouble();
    final paymentMethod = _orderData['CachThanhToan'] ?? 'Thanh toán khi nhận hàng';
    final deliveryDate = _orderData['NgayGiao'] != null
        ? _formatDate(_orderData['NgayGiao'] as Timestamp)
        : 'Đang cập nhật';
    final address = _orderData['DiaChi'] ?? '';
    final phone = _orderData['SDT'] ?? '';
    final recipient = _orderData['TenNguoiDat'] ?? '';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Người nhận:', recipient),
          _buildInfoRow('Số điện thoại:', phone),
          _buildInfoRow('Địa chỉ:', address),
          _buildInfoRow('Phương thức thanh toán:', paymentMethod),
          _buildInfoRow('Dự kiến giao hàng:', deliveryDate),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                _formatPrice(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B9D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    if (_orderDetails.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm đã đặt',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._orderDetails.map((item) {
            final productName = item['TenSanPham'] ?? 'Sản phẩm';
            final quantity = item['SoLuong'] ?? 1;
            final price = (item['Gia'] ?? 0).toDouble();
            final total = (item['ThanhTien'] ?? 0).toDouble();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(Icons.shopping_bag, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Số lượng: $quantity',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(price),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFF6B9D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatPrice(total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B9D),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bước tiếp theo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          _buildStepItem('1', 'Xác nhận đơn hàng', 'Chúng tôi sẽ gọi điện xác nhận đơn hàng trong vòng 30 phút'),
          _buildStepItem('2', 'Chuẩn bị hàng', 'Đơn hàng sẽ được đóng gói và chuẩn bị giao'),
          _buildStepItem('3', 'Giao hàng', 'Nhân viên sẽ giao hàng đến địa chỉ của bạn'),
          _buildStepItem('4', 'Nhận hàng & Thanh toán', 'Kiểm tra hàng và thanh toán khi nhận hàng'),
        ],
      ),
    );
  }

  Widget _buildStepItem(String step, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Quay về trang chủ
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home', // Thay bằng route trang chủ của bạn
                      (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B9D),
                side: const BorderSide(color: Color(0xFFFF6B9D)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'TIẾP TỤC MUA SẮM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Điều hướng đến trang lịch sử đơn hàng
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryPage(
                      idKhachHang: widget.idKhachHang,
                      userData: widget.userData,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'XEM ĐƠN HÀNG',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Đặt hàng thành công",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54, size: 20),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
                  (route) => false,
            );
          },
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSuccessHeader(),
                  const SizedBox(height: 16),
                  _buildOrderInfo(),
                  const SizedBox(height: 16),
                  _buildOrderItems(),
                  const SizedBox(height: 16),
                  _buildNextSteps(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }
}
