import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ThongKePage extends StatefulWidget {
  const ThongKePage({super.key});

  @override
  State<ThongKePage> createState() => _ThongKePageState();
}

class _ThongKePageState extends State<ThongKePage> {
  Map<String, double> doanhThuThang = {};
  Map<String, double> doanhThuNgay = {};
  bool _isLoading = true;
  int _selectedFilter = 0; // 0: Ngày, 1: Tháng
  final List<String> _filters = ['Theo Ngày', 'Theo Tháng'];
  DateTime _selectedDate = DateTime.now();
  Map<String, int> thongKeTrangThai = {};

  @override
  void initState() {
    super.initState();
    _layDuLieuDoanhThu();
  }

  Future<void> _layDuLieuDoanhThu() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('donhang').get();

      Map<String, double> tamThang = {};
      Map<String, double> tamNgay = {};
      Map<String, int> tamTrangThai = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final double tongTien = (data['TongTien'] as num?)?.toDouble() ?? 0;
        final Timestamp? ngayTao = data['NgayTao'] as Timestamp?;
        final String trangThai = data['TrangThai'] ?? 'Khác';


        // Đếm trạng thái
        tamTrangThai[trangThai] = (tamTrangThai[trangThai] ?? 0) + 1;

        if (ngayTao != null) {
          final date = ngayTao.toDate();

          // Dữ liệu theo tháng
          final thang = DateFormat('MM/yyyy').format(date);
          tamThang[thang] = (tamThang[thang] ?? 0) + tongTien;

          // Dữ liệu theo ngày
          final ngay = DateFormat('dd/MM/yyyy').format(date);
          tamNgay[ngay] = (tamNgay[ngay] ?? 0) + tongTien;
        }
      }

      setState(() {
        doanhThuThang = tamThang;
        doanhThuNgay = tamNgay;
        thongKeTrangThai = tamTrangThai;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi lấy dữ liệu: $e');
      setState(() => _isLoading = false);
    }
  }

  Map<String, double> get _currentData {
    return _selectedFilter == 0 ? doanhThuNgay : doanhThuThang;
  }

  double _getTongDoanhThu() {
    return _currentData.values.fold<double>(0.0, (a, b) => a + b);
  }

  double _getDoanhThuCaoNhat() {
    if (_currentData.isEmpty) return 0;
    return _currentData.values.reduce((a, b) => a > b ? a : b);
  }

  double _getDoanhThuThapNhat() {
    if (_currentData.isEmpty) return 0;
    return _currentData.values.reduce((a, b) => a < b ? a : b);
  }

  int _getSoDonHang() {
    return _currentData.length;
  }

  Widget _buildStatsCards() {
    final tongDoanhThu = _getTongDoanhThu();
    final doanhThuCaoNhat = _getDoanhThuCaoNhat();
    final doanhThuThapNhat = _getDoanhThuThapNhat();
    final soDonHang = _getSoDonHang();

    return Column(
      children: [
        // Card tổng doanh thu
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF007BFF), Color(0xFF0056CC)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.attach_money, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedFilter == 0 ? 'Tổng Doanh Thu (Ngày)' : 'Tổng Doanh Thu (Tháng)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${NumberFormat("#,###").format(tongDoanhThu)} VNĐ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$soDonHang đơn hàng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Card thống kê phụ
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.trending_up, color: Colors.green, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Cao nhất',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat("#,###").format(doanhThuCaoNhat)} VNĐ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.trending_down, color: Colors.orange, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Thấp nhất',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat("#,###").format(doanhThuThapNhat)} VNĐ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chế độ xem:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_filters[index]),
                  selected: _selectedFilter == index,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = index;
                    });
                  },
                  selectedColor: const Color(0xFF007BFF),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedFilter == index ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (_currentData.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Không có dữ liệu',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final sortedEntries = _currentData.entries.toList()
      ..sort((a, b) {
        if (_selectedFilter == 0) {
          final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
          final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
          return dateA.compareTo(dateB);
        } else {
          final dateA = DateFormat('MM/yyyy').parse(a.key);
          final dateB = DateFormat('MM/yyyy').parse(b.key);
          return dateA.compareTo(dateB);
        }
      });

    final displayEntries = sortedEntries.length > 30
        ? sortedEntries.sublist(sortedEntries.length - 30)
        : sortedEntries;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📈 ', style: TextStyle(fontSize: 20)),
              Text(
                _selectedFilter == 0
                    ? 'Biểu Đồ Doanh Thu Theo Ngày'
                    : 'Biểu Đồ Doanh Thu Theo Tháng',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hiển thị ${displayEntries.length} ${_selectedFilter == 0 ? 'ngày' : 'tháng'} gần nhất',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 380,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center, // căn giữa cột
                groupsSpace: 18, // tăng khoảng cách giữa các cột
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue() / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 0.6,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: _getMaxValue() / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${(value / 1000000).toStringAsFixed(1)}M',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < displayEntries.length) {
                          final key = displayEntries[value.toInt()].key;
                          String displayText;
                          if (_selectedFilter == 0) {
                            final parts = key.split('/');
                            displayText = '${parts[0]}/${parts[1]}';
                          } else {
                            displayText = key;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.3,
                              child: Text(
                                displayText,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blue[800]!.withOpacity(0.9),
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.all(12),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${displayEntries[groupIndex].key}\n💰 ${NumberFormat("#,###").format(displayEntries[groupIndex].value)} VNĐ',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(displayEntries.length, (index) {
                  final value = displayEntries[index].value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: _selectedFilter == 0 ? 18 : 26, // 🌟 tăng độ rộng cột
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF007BFF), Color(0xFF00BFFF)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _getMaxValue(),
                          color: Colors.grey[100]!.withOpacity(0.5),
                        ),
                      ),
                    ],
                  );
                }),
                maxY: _getMaxValue() * 1.1,
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPieChart() {
    if (thongKeTrangThai.isEmpty) {
      return const SizedBox();
    }

    final colors = {
      'Chờ xác nhận': Colors.orangeAccent,
      'Đã xác nhận': Colors.blueAccent,
      'Đang giao hàng': Colors.amber,
      'Đã giao': Colors.green,
      'Đã hủy': Colors.redAccent,
    };

    final sections = thongKeTrangThai.entries.map((entry) {
      final color = colors[entry.key] ?? Colors.grey;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📦 Biểu Đồ Trạng Thái Đơn Hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: thongKeTrangThai.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[entry.key] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  double _getMaxValue() {
    if (_currentData.isEmpty) return 1000000;
    final values = _currentData.values.toList();
    values.sort((a, b) => b.compareTo(a));
    // Lấy giá trị lớn nhất, nhưng làm tròn lên để đẹp hơn
    final maxValue = values.first;
    return (maxValue * 1.2).roundToDouble(); // Thêm 20% padding
  }

  Widget _buildDataTable() {
    if (_currentData.isEmpty) return const SizedBox();

    final sortedEntries = _currentData.entries.toList()
      ..sort((a, b) {
        if (_selectedFilter == 0) {
          final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
          final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
          return dateB.compareTo(dateA); // Mới nhất lên đầu
        } else {
          final dateA = DateFormat('MM/yyyy').parse(a.key);
          final dateB = DateFormat('MM/yyyy').parse(b.key);
          return dateB.compareTo(dateA);
        }
      });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedFilter == 0 ? 'Chi Tiết Doanh Thu Theo Ngày' : 'Chi Tiết Doanh Thu Theo Tháng',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: sortedEntries.length,
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${NumberFormat("#,###").format(entry.value)} VNĐ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF007BFF),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
        title: const Text(
          '📊 Thống Kê Doanh Thu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF007BFF),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007BFF)),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildChart(),
            const SizedBox(height: 20),
            _buildDataTable(),
            const SizedBox(height: 20),
            _buildPieChart(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}