import 'package:appshopsua/cart/orderhistory.dart';
import 'package:appshopsua/favorite_page.dart';
import 'package:appshopsua/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AccountPage extends StatefulWidget {
  final String idKhachHang;
  final Map<String, dynamic> userData;

  const AccountPage({
    Key? key,
    required this.idKhachHang,
    required this.userData,
  }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> get _userData => widget.userData;
  bool _isLoading = false;

  // Màu sắc theme màu hồng
  final Color _primaryColor = Color(0xFFEC407A); // Màu hồng chính
  final Color _secondaryColor = Color(0xFFF8BBD0); // Màu hồng nhạt
  final Color _accentColor = Color(0xFFF06292); // Màu hồng accent
  final Color _backgroundColor = Color(0xFFFCE4EC); // Nền hồng rất nhạt
  final Color _surfaceColor = Colors.white;
  final Color _textColor = Color(0xFF880E4F); // Chữ màu hồng đậm
  final Color _hintColor = Color(0xFFAD1457); // Chữ gợi ý

  @override
  void initState() {
    super.initState();
    print(" AccountPage received idKhachHang: ${widget.idKhachHang}");
    print(" AccountPage received userData: ${widget.userData}");
  }



  // Hàm refresh dữ liệu nếu cần
  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc = await _firestore
          .collection('khachhang')
          .doc(widget.idKhachHang)
          .get();

      if (userDoc.exists) {
        setState(() {
          // Cập nhật dữ liệu mới
          widget.userData.clear();
          widget.userData.addAll(userDoc.data()!);
        });
      }
    } catch (e) {
      print('Lỗi refresh user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, Color(0xFFAD1457)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar với hiệu ứng
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              backgroundImage: _userData['avatarUrl'] != null && _userData['avatarUrl'].isNotEmpty
                  ? NetworkImage(_userData['avatarUrl'])
                  : null,
              child: _userData['avatarUrl'] == null || _userData['avatarUrl'].isEmpty
                  ? Icon(Icons.person, size: 50, color: _primaryColor)
                  : null,
            ),
          ),
          SizedBox(height: 20),

          Text(
            _userData['ten']?.toString() ?? 'Chưa đặt tên',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),

          Text(
            _userData['email']?.toString() ?? 'Chưa có email',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool isFavorite = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: isFavorite
                ? LinearGradient(
              colors: [Color(0xFFFF80AB), Color(0xFFF50057)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [_secondaryColor, _accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (iconColor ?? _primaryColor).withOpacity(0.3),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
              icon,
              color: Colors.white,
              size: 22
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _textColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: _hintColor,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _secondaryColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.chevron_right, color: _primaryColor, size: 18),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF80AB), Color(0xFFF50057)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF50057).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              ),
              SizedBox(width: 10),
              Text(
                'Theo dõi đơn hàng',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatusItem(
                icon: Icons.access_time,
                label: 'Chờ giao',
                count: _userData['donHangChoGiao'] ?? 0,
                color: Colors.white,
              ),
              _buildOrderStatusItem(
                icon: Icons.local_shipping,
                label: 'Đang giao',
                count: _userData['donHangDangGiao'] ?? 0,
                color: Colors.white,
              ),
              _buildOrderStatusItem(
                icon: Icons.check_circle,
                label: 'Đã giao',
                count: _userData['donHangDaGiao'] ?? 0,
                color: Colors.white,
              ),
              _buildOrderStatusItem(
                icon: Icons.cancel,
                label: 'Đã hủy',
                count: _userData['donHangDaHuy'] ?? 0,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFF50057), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : count.toString(),
                      style: TextStyle(
                        color: Color(0xFFF50057),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, _backgroundColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: _secondaryColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, color: _primaryColor, size: 20),
              ),
              SizedBox(width: 10),
              Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow('Họ tên', _userData['ten']?.toString() ?? 'Chưa cập nhật', Icons.person),
          _buildInfoRow('Email', _userData['email']?.toString() ?? 'Chưa có email', Icons.email),
          _buildInfoRow('Giới tính', _userData['gioitinh']?.toString() ?? 'Chưa cập nhật', Icons.transgender),
          _buildInfoRow('Số điện thoại', _userData['sdt']?.toString() ?? 'Chưa cập nhật', Icons.phone),
          _buildInfoRow('Địa chỉ', _userData['diachi']?.toString() ?? 'Chưa cập nhật', Icons.location_on),
          SizedBox(height: 12),
          Center(
            child: Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to edit profile page
                },
                icon: Icon(Icons.edit, size: 18),
                label: Text('Chỉnh sửa thông tin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                  shadowColor: _primaryColor.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _secondaryColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _secondaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primaryColor, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _hintColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshUserData,
                color: _primaryColor,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 10),

                      // Order Status
                      _buildOrderStatus(),

                      // Personal Info
                      _buildPersonalInfo(),

                      // Menu Options
                      Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, _backgroundColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.1),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: _secondaryColor.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            _buildMenuButton(
                              icon: Icons.favorite,
                              title: 'Sản phẩm yêu thích',
                              subtitle: 'Xem danh sách sản phẩm đã thích',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoritePage(
                                      idKhachHang: widget.idKhachHang,
                                    ),
                                  ),
                                );
                                // Navigate to favorites page

                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => OrderHistoryPage(idKhachHang: idKhachHang),
                                //   ),
                                //
                                // );
                              },
                              isFavorite: true,
                            ),
                            // _buildMenuButton(
                            //   icon: Icons.history,
                            //   title: 'Lịch sử mua hàng',
                            //   subtitle: 'Xem tất cả đơn hàng đã mua',
                            //   onTap: () {
                            //     // Navigate to order history page
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => OrderHistoryPage(idKhachHang: idKhachHang),
                            //       ),
                            //
                            //     );
                            //   },
                            // ),

                            _buildMenuButton(
                              icon: Icons.history,
                              title: 'Lịch sử mua hàng',
                              subtitle: 'Xem tất cả đơn hàng đã mua',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderHistoryPage(
                                        idKhachHang: widget.idKhachHang,
                                        userData: widget.userData,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // OrderHistoryPage

                            _buildMenuButton(
                              icon: Icons.location_on_outlined,
                              title: 'Sổ địa chỉ',
                              subtitle: 'Quản lý địa chỉ nhận hàng',
                              onTap: () {
                                // Navigate to address book page
                              },
                            ),
                            _buildMenuButton(
                              icon: Icons.store,
                              title: 'Tìm kiếm cửa hàng',
                              subtitle: 'Tìm cửa hàng gần bạn',
                              onTap: () {
                                // Navigate to store locator
                              },
                            ),
                            _buildMenuButton(
                              icon: Icons.card_giftcard,
                              title: 'Nhập mã đổi quà',
                              subtitle: 'Đổi điểm lấy quà tặng',
                              onTap: () {
                                // Navigate to gift redemption
                              },
                            ),
                          ],
                        ),
                      ),

                      // Support & Settings
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, _backgroundColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.1),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: _secondaryColor.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            _buildMenuButton(
                              icon: Icons.support_agent,
                              title: 'Liên hệ hỗ trợ',
                              subtitle: 'Hotline: 1800 1234',
                              onTap: () {
                                // Contact support
                              },
                            ),
                            _buildMenuButton(
                              icon: Icons.description_outlined,
                              title: 'Điều khoản Avakids',
                              subtitle: 'Điều khoản sử dụng',
                              onTap: () {
                                // Show terms
                              },
                            ),
                            _buildMenuButton(
                              icon: Icons.logout,
                              title: 'Đăng xuất',
                              subtitle: 'Thoát tài khoản',
                              onTap: () {
                                _showLogoutDialog();
                              },
                            ),
                          ],
                        ),
                      ),

                      // App Version
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Phiên bản 2.0.4 (d21ef3ebbf02)',
                          style: TextStyle(
                            color: _hintColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Đăng xuất',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
          style: TextStyle(color: _hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: _hintColor)),
          ),
          ElevatedButton(
            // onPressed: () async {
            //   Navigator.pop(context);
            //   await _auth.signOut();
            //   // Navigate to login page
            //   MaterialPageRoute(builder: (context) => DangNhapPage()),
            // },
            onPressed: () async {
              try {
                Navigator.pop(context); // Đóng dialog

                // Hiển thị loading (tuỳ chọn)
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                await _auth.signOut();

                // Đóng loading (nếu có)
                if (mounted) Navigator.pop(context);

                // Chuyển hướng
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DangNhapPage()),
                        (route) => false,
                  );
                }

              } catch (e) {
                // Đóng loading nếu có lỗi
                if (mounted) Navigator.pop(context);

                // Hiển thị thông báo lỗi
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Có lỗi xảy ra khi đăng xuất'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}