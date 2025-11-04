
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  final String idKhachHang;
  final Map<String, dynamic> userData;

  const OrderHistoryPage({super.key, required this.idKhachHang, required this.userData});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String _selectedFilter = 'Tất cả';
  String _errorMessage = '';

  final List<String> _filterOptions = [
    'Tất cả',
    'Chờ xác nhận',
    'Đã xác nhận',
    'Đang giao hàng',
    'Đã giao',
    'Đã hủy'
  ];

  @override
  void initState() {
    super.initState();
    print('🆔 ID Khách hàng từ widget: ${widget.idKhachHang}');
    _loadOrders();
  }
  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    final userId = widget.idKhachHang;
    print('🔍 Bắt đầu tải đơn hàng cho user: $userId');

    if (userId.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = 'User ID không tồn tại. Vui lòng đăng nhập lại.';
      });
      return;
    }

    try {
      // TẠM THỜI: Chỉ dùng where, không dùng orderBy để tránh lỗi index
      final snapshot = await FirebaseFirestore.instance
          .collection('donhang')
          .where('IdKhachHang', isEqualTo: userId)
          .get();

      print('✅ Tìm thấy ${snapshot.docs.length} đơn hàng trong database');

      if (snapshot.docs.isEmpty) {
        setState(() {
          _loading = false;
          _errorMessage = 'Không tìm thấy đơn hàng nào cho tài khoản này';
        });
        return;
      }

      // Sắp xếp thủ công bằng code (thay vì orderBy của Firestore)
      final sortedDocs = snapshot.docs;
      sortedDocs.sort((a, b) {
        final aDate = a['NgayTao'] as Timestamp?;
        final bDate = b['NgayTao'] as Timestamp?;

        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate); // Giảm dần (mới nhất lên đầu)
      });

      // Debug: In thông tin từng document
      for (var doc in sortedDocs) {
        print('📄 Document ID: ${doc.id}');
        print('📊 Document Data: ${doc.data()}');
        final data = doc.data();
        print('🔍 Field check - IdKhachHang: ${data['IdKhachHang']}');
        print('🔍 Field check - TrangThai: ${data['TrangThai']}');
        print('🔍 Field check - TongTien: ${data['TongTien']}');
        print('🔍 Field check - CachThanhToan: ${data['CachThanhToan']}');
        print('---');
      }

      List<Map<String, dynamic>> ordersWithDetails = [];

      for (var doc in sortedDocs) {
        final orderData = doc.data();
        final maDonHang = doc.id;

        print('🔍 Đang tải chi tiết cho đơn hàng: $maDonHang');

        try {
          // Load chi tiết đơn hàng từ collection chitietdonhang
          final detailSnapshot = await FirebaseFirestore.instance
              .collection('chitietdonhang')
              .where('MaDonHang', isEqualTo: maDonHang)
              .get();

          final orderDetails = detailSnapshot.docs.map((detailDoc) => detailDoc.data()).toList();
          print('✅ Đơn $maDonHang có ${orderDetails.length} sản phẩm');

          ordersWithDetails.add({
            'id': maDonHang,
            ...orderData,
            'chiTietDonHang': orderDetails,
          });
        } catch (e) {
          print('❌ Lỗi khi tải chi tiết đơn $maDonHang: $e');
          // Vẫn thêm đơn hàng nhưng không có chi tiết
          ordersWithDetails.add({
            'id': maDonHang,
            ...orderData,
            'chiTietDonHang': [],
          });
        }
      }

      setState(() {
        _orders = ordersWithDetails;
        _loading = false;
      });

      print('🎉 Đã tải xong ${_orders.length} đơn hàng với đầy đủ thông tin');

    } catch (e) {
      print('❌ Lỗi nghiêm trọng khi tải đơn hàng: $e');
      setState(() {
        _loading = false;
        _errorMessage = 'Lỗi kết nối database: $e\n\nHãy tạo index theo hướng dẫn trong log!';
      });
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
    try {
      final date = timestamp.toDate();
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    } catch (e) {
      return '--/--/---- --:--';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đang giao hàng':
        return Colors.blue;
      case 'Đã giao':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Icons.access_time;
      case 'Đã xác nhận':
        return Icons.access_time;
      case 'Đang giao hàng':
        return Icons.local_shipping;
      case 'Đã giao':
        return Icons.check_circle;
      case 'Đã hủy':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'Tất cả';
                });
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: const Color(0xFFFF6B9D),
              checkmarkColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey.shade300,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'] ?? '';
    final orderDate = order['NgayTao'] != null
        ? _formatDate(order['NgayTao'] as Timestamp)
        : '--/--/---- --:--';
    final status = order['TrangThai'] ?? 'Chờ xác nhận';
    final total = (order['TongTien'] ?? 0).toDouble();
    final products = order['chiTietDonHang'] as List<dynamic>? ?? [];
    final paymentMethod = order['CachThanhToan'] ?? 'Thanh toán khi nhận hàng';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        children: [
          // Header với mã đơn hàng và trạng thái
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getStatusIcon(status), size: 16, color: _getStatusColor(status)),
                          const SizedBox(width: 8),
                          Text(
                            'Mã đơn: ${orderId.length > 8 ? '${orderId.substring(0, 8)}...' : orderId}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thông tin đơn hàng
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phương thức thanh toán
                Row(
                  children: [
                    const Icon(Icons.payment_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        paymentMethod,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Danh sách sản phẩm
                if (products.isNotEmpty) ...[
                  Column(
                    children: products.take(2).map<Widget>((product) {
                      final productName = product['TenSanPham'] ?? 'Sản phẩm';
                      final quantity = product['SoLuong'] ?? 1;
                      final price = (product['Gia'] ?? 0).toDouble();
                      final thanhTien = (product['ThanhTien'] ?? price * quantity).toDouble();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: const Icon(Icons.shopping_bag, color: Colors.grey, size: 20),
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
                                  const SizedBox(height: 2),
                                  Text(
                                    'Số lượng: $quantity • ${_formatPrice(price)}/sản phẩm',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatPrice(thanhTien),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF6B9D),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // Hiển thị số sản phẩm còn lại nếu có nhiều hơn 2
                  if (products.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+${products.length - 2} sản phẩm khác',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.grey),

                // Tổng tiền và nút hành động
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng thanh toán',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
                      Row(
                        children: [
                          if (status == 'Chờ xác nhận')
                            OutlinedButton(
                              onPressed: () => _cancelOrder(orderId),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Hủy đơn',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _viewOrderDetail(order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF6B9D),
                              side: const BorderSide(color: Color(0xFFFF6B9D)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Chi tiết',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text(
            "Chưa có đơn hàng",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Hãy mua sắm và quay lại xem lịch sử đơn hàng của bạn",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('MUA SẮM NGAY'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng kiểm tra kết nối và thử lại',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
            ),
            child: const Text('THỬ LẠI'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'Tất cả') {
      return _orders;
    }
    return _orders.where((order) => order['TrangThai'] == _selectedFilter).toList();
  }

  void _cancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hủy đơn hàng"),
        content: const Text("Bạn có chắc chắn muốn hủy đơn hàng này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("KHÔNG"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateOrderStatus(orderId, 'Đã hủy');
            },
            child: const Text(
              "CÓ, HỦY ĐƠN",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('donhang')
          .doc(orderId)
          .update({'TrangThai': newStatus});

      // Reload danh sách đơn hàng
      _loadOrders();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'Đã hủy'
              ? 'Đã hủy đơn hàng thành công'
              : 'Cập nhật trạng thái thành công'),
          backgroundColor: newStatus == 'Đã hủy' ? Colors.red : Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái đơn hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi cập nhật đơn hàng'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewOrderDetail(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailSheet(order),
    );
  }

  Widget _buildOrderDetailSheet(Map<String, dynamic> order) {
    final products = order['chiTietDonHang'] as List<dynamic>? ?? [];
    final total = (order['TongTien'] ?? 0).toDouble();
    final status = order['TrangThai'] ?? 'Chờ xác nhận';
    final orderDate = order['NgayTao'] != null
        ? _formatDate(order['NgayTao'] as Timestamp)
        : '--/--/---- --:--';
    final paymentMethod = order['CachThanhToan'] ?? 'Thanh toán khi nhận hàng';
    final deliveryAddress = order['DiaChi'] ?? '';
    final phoneNumber = order['SDT'] ?? '';
    final recipientName = order['TenNguoiDat'] ?? '';
    final note = order['GhiChu'] ?? '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chi tiết đơn hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
          ),
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin trạng thái
                  _buildDetailSection(
                    title: 'Trạng thái đơn hàng',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(status)),
                      ),
                      child: Row(
                        children: [
                          Icon(_getStatusIcon(status), size: 24, color: _getStatusColor(status)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Thông tin đơn hàng
                  _buildDetailSection(
                    title: 'Thông tin đơn hàng',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Mã đơn hàng:', order['id']?.toString() ?? ''),
                        _buildDetailRow('Ngày đặt:', orderDate),
                        _buildDetailRow('Phương thức thanh toán:', paymentMethod),
                        _buildDetailRow('Trạng thái đơn hàng:', status),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Thông tin giao hàng
                  _buildDetailSection(
                    title: 'Thông tin giao hàng',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Người nhận:', recipientName),
                        _buildDetailRow('Số điện thoại:', phoneNumber),
                        _buildDetailRow('Địa chỉ:', deliveryAddress),
                        if (note.isNotEmpty)
                          _buildDetailRow('Ghi chú:', note),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sản phẩm
                  _buildDetailSection(
                    title: 'Sản phẩm (${products.length})',
                    child: products.isNotEmpty
                        ? Column(
                      children: products.map<Widget>((product) {
                        final productName = product['TenSanPham'] ?? 'Sản phẩm';
                        final quantity = product['SoLuong'] ?? 1;
                        final price = (product['Gia'] ?? 0).toDouble();
                        final thanhTien = (product['ThanhTien'] ?? price * quantity).toDouble();

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
                                child: const Icon(Icons.shopping_bag, color: Colors.grey, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
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
                                      '${_formatPrice(price)} x $quantity',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatPrice(thanhTien),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B9D),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                        : const Text(
                      'Không có thông tin sản phẩm',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tổng thanh toán
                  _buildDetailSection(
                    title: 'Tổng thanh toán',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildPaymentRow('Tổng tiền hàng:', _formatPrice(total)),
                          _buildPaymentRow('Phí giao hàng:', 'Miễn phí'),
                          const Divider(),
                          _buildPaymentRow(
                            'Tổng thanh toán:',
                            _formatPrice(total),
                            isBold: true,
                            isHighlighted: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút hành động
          Container(
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
                if (status == 'Chờ xác nhận')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _cancelOrder(order['id']);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('HỦY ĐƠN HÀNG'),
                    ),
                  ),
                if (status == 'Chờ xác nhận') const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('ĐÓNG'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isHighlighted ? const Color(0xFFFF6B9D) : Colors.black87,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
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
          "Lịch sử đơn hàng",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải đơn hàng...',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : _errorMessage.isNotEmpty
          ? _buildErrorView()
          : Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyOrders()
                : RefreshIndicator(
              onRefresh: _loadOrders,
              color: const Color(0xFFFF6B9D),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(_filteredOrders[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}