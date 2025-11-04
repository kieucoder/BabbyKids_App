import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> statusList = ['Tất cả', 'Chờ xác nhận', 'Đã xác nhận', 'Đang giao', 'Đã giao', 'Đã hủy'];
  String _selectedStatus = 'Tất cả';
  String _searchQuery = '';

  String _formatPrice(double price) {
    int intPrice = price.round();
    String formatted = intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return '$formattedđ';
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đã xác nhận':
        return Colors.blue;
      case 'Đang giao':
        return Colors.purple;
      case 'Đã giao':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('donhang').doc(orderId).update({
        'TrangThai': newStatus,
        'NgayCapNhat': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái đơn hàng thành $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi cập nhật trạng thái')),
      );
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết đơn hàng: ${order['MaDonHang']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Mã đơn:', order['MaDonHang']),
              _buildDetailRow('Khách hàng:', order['TenNguoiDat']),
              _buildDetailRow('SĐT:', order['SDT']),
              _buildDetailRow('Địa chỉ:', order['DiaChi']),
              _buildDetailRow('Tổng tiền:', _formatPrice(order['TongTien'])),
              _buildDetailRow('Phương thức:', order['CachThanhToan']),
              _buildDetailRow('Trạng thái:', order['TrangThai']),
              _buildDetailRow('Ngày tạo:', _formatTimestamp(order['NgayTao'])),
              if (order['GhiChu'] != null && order['GhiChu'].isNotEmpty)
                _buildDetailRow('Ghi chú:', order['GhiChu']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['MaDonHang'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(order['TrangThai']),
              ],
            ),
            const SizedBox(height: 12),

            // Customer info
            Text(
              '${order['TenNguoiDat']} • ${order['SDT']}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              order['DiaChi'],
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Order details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatPrice(order['TongTien']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  _formatTimestamp(order['NgayTao']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOrderDetails(order),
                    child: const Text('CHI TIẾT'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PopupMenuButton<String>(
                    onSelected: (newStatus) => _updateOrderStatus(order['MaDonHang'], newStatus),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Chờ xác nhận', child: Text('Chờ xác nhận')),
                      const PopupMenuItem(value: 'Đã xác nhận', child: Text('Đã xác nhận')),
                      const PopupMenuItem(value: 'Đang giao', child: Text('Đang giao')),
                      const PopupMenuItem(value: 'Đã giao', child: Text('Đã giao')),
                      const PopupMenuItem(value: 'Đã hủy', child: Text('Đã hủy')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'CẬP NHẬT',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Đơn Hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo mã đơn hàng, tên khách hàng...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Status Filter
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusList.length,
                    itemBuilder: (context, index) {
                      final status = statusList[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = selected ? status : 'Tất cả';
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue.withOpacity(0.2),
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: _selectedStatus == status ? Colors.blue : Colors.grey[700],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('donhang').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Có lỗi xảy ra'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có đơn hàng nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Filter orders based on status and search query
                var orders = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data;
                }).toList();

                // Apply status filter
                if (_selectedStatus != 'Tất cả') {
                  orders = orders.where((order) => order['TrangThai'] == _selectedStatus).toList();
                }

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  orders = orders.where((order) {
                    final maDonHang = order['MaDonHang']?.toString().toLowerCase() ?? '';
                    final tenKhachHang = order['TenNguoiDat']?.toString().toLowerCase() ?? '';
                    final query = _searchQuery.toLowerCase();
                    return maDonHang.contains(query) || tenKhachHang.contains(query);
                  }).toList();
                }

                // Sort by creation date (newest first)
                orders.sort((a, b) {
                  final timeA = a['NgayTao'] as Timestamp;
                  final timeB = b['NgayTao'] as Timestamp;
                  return timeB.compareTo(timeA);
                });

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(orders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}