import 'package:appshopsua/admin/brand/listbrand.dart';
import 'package:appshopsua/admin/category/dsdanhmuc_page.dart';
import 'package:appshopsua/admin/employee/listemployee.dart';
import 'package:appshopsua/admin/khuyenmai/list_promotion.dart';
import 'package:appshopsua/admin/order/adminorderpage.dart';
import 'package:appshopsua/admin/product/listproduct.dart';
import 'package:appshopsua/admin/revenue/thongke_page.dart';
import 'package:appshopsua/admin/thongke.dart';
import 'package:appshopsua/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'subcategory/listsubcategory.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final Color mainBlue = const Color(0xFF007BFF);
  final Color lightBlue = const Color(0xFFE6F2FF);
  final Color backgroundColor = const Color(0xFFF8FAFC);

  int _selectedDrawerIndex = 0; // Để theo dõi mục đang chọn trong drawer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: mainBlue,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kiểm tra thông báo mới!')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    mainBlue,
                    Color(mainBlue.value).withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Quản trị hệ thống',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Tổng quan',
              index: 0,
            ),
            _buildDrawerItem(
              icon: Icons.people_outline,
              title: 'Quản lý Người dùng',
              index: 1,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListEmployeePage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.inventory_2_outlined,
              title: 'Quản lý Danh Mục',
              index: 2,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryListPage()),
                    // ListProductPage
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.shopping_cart_outlined,
              title: 'Quản lý Danh Mục Con',
              index: 3,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListSubCattegory()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.analytics_outlined,
              title: 'Quản lý Thương Hiệu ',
              index: 4,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListBrand()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Quản lý Sản Phẩm',
              index: 5,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListProductPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Quản lý Đơn Hàng',
              index: 6,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminOrdersPage()),
                );
              },
            ),
            const Divider(height: 32),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Quản lý khuyến mãi',
              index: 7,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ListKhuyenMaiPage()),
                      (route) => false,
                );
              },

            ),
            _buildDrawerItem(
              icon: Icons.bar_chart,
              title: 'Thống kê',
              index: 8,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThongKePage()),
                );
              },
            ),

            // _buildDrawerItem(
            //   icon: Icons.logout,
            //   title: 'Thống kê',
            //   index: 8,
            //   onTap: () async {
            //     await FirebaseAuth.instance.signOut();
            //     Navigator.pushAndRemoveUntil(
            //       context,
            //       MaterialPageRoute(builder: (context) => const ThongKePage()),
            //           (route) => false,
            //     );
            //   },
            //
            // ),
            const Divider(height: 32),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              index: 9,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DangNhapPage()),
                      (route) => false,
                );
              },

            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Welcome
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    mainBlue,
                    Color(mainBlue.value).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: mainBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xin chào, Admin!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chúc bạn một ngày làm việc hiệu quả',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Grid
            const Text(
              'Thống kê nhanh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  icon: Icons.people_alt_outlined,
                  title: 'Người dùng',
                  value: '1,234',
                  color: const Color(0xFF10B981),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                ),
                _buildStatCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Sản phẩm',
                  value: '567',
                  color: const Color(0xFF3B82F6),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  ),
                ),
                _buildStatCard(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Đơn hàng',
                  value: '890',
                  color: const Color(0xFFF59E0B),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  ),
                ),
                _buildStatCard(
                  icon: Icons.attach_money_outlined,
                  title: 'Doanh thu',
                  value: '\$12,345',
                  color: const Color(0xFF8B5CF6),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Revenue Chart Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thống kê Doanh thu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: mainBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tháng 10/2024',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mainBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Placeholder for chart
                  // Container(
                  //   height: 200,
                  //   decoration: BoxDecoration(
                  //     color: lightBlue,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: mainBlue.withOpacity(0.2)),
                  //   ),
                  //   child: Center(
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(
                  //           Icons.bar_chart_outlined,
                  //           size: 48,
                  //           color: mainBlue.withOpacity(0.5),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Text(
                  //           'Biểu đồ doanh thu',
                  //           style: TextStyle(
                  //             color: mainBlue.withOpacity(0.7),
                  //             fontSize: 14,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: mainBlue.withOpacity(0.2)),
                    ),
                    child: const ThongKePage(),
                  ),

                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ChartLegend(color: Color(0xFF10B981), label: 'Doanh thu'),
                      _ChartLegend(color: Color(0xFF3B82F6), label: 'Lợi nhuận'),
                      _ChartLegend(color: Color(0xFFF59E0B), label: 'Chi phí'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoạt động gần đây',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityItem(
                    icon: Icons.person_add,
                    title: 'Người dùng mới đăng ký',
                    subtitle: '5 phút trước',
                    color: const Color(0xFF10B981),
                  ),
                  _buildActivityItem(
                    icon: Icons.shopping_cart_checkout,
                    title: 'Đơn hàng mới #ORD-001',
                    subtitle: '15 phút trước',
                    color: const Color(0xFF3B82F6),
                  ),
                  _buildActivityItem(
                    icon: Icons.inventory_2,
                    title: 'Sản phẩm sắp hết hàng',
                    subtitle: '1 giờ trước',
                    color: const Color(0xFFF59E0B),
                  ),
                  _buildActivityItem(
                    icon: Icons.payment,
                    title: 'Thanh toán thành công',
                    subtitle: '2 giờ trước',
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm sản phẩm mới!')),
          );
        },
        backgroundColor: mainBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    bool isSelected = _selectedDrawerIndex == index;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? mainBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? mainBlue : const Color(0xFF64748B),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? mainBlue : const Color(0xFF334155),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedDrawerIndex = index;
        });
        if (onTap != null) {
          onTap();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mainBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
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
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF64748B).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

