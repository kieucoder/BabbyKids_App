import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditProductPage extends StatefulWidget {
  final String productId;

  const EditProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Color scheme - Đồng bộ với theme chung
  final Color _primaryColor = const Color(0xFF007BFF);
  final Color _secondaryColor = const Color(0xFF0056CC);
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF1E293B);
  final Color _hintColor = const Color(0xFF64748B);
  final Color _successColor = const Color(0xFF10B981);
  final Color _errorColor = const Color(0xFFEF4444);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _borderColor = const Color(0xFFE2E8F0);

  // Controllers
  final _tenSPController = TextEditingController();
  final _giaController = TextEditingController();
  final _soLuongController = TextEditingController();
  final _hinhAnhController = TextEditingController();
  final _moTaController = TextEditingController();
  final _doTuoiController = TextEditingController();
  final _trongLuongController = TextEditingController();
  final _sanXuatController = TextEditingController();

  // Dropdown
  String? _selectedDanhMuc;
  String? _selectedDanhMucCon;
  String? _selectedThuongHieu;
  List<Map<String, dynamic>> _danhMucList = [];
  List<Map<String, dynamic>> _danhMucConList = [];
  List<Map<String, dynamic>> _thuongHieuList = [];

  String _trangThai = "Hoạt Động";
  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _loadDanhMuc();
    _loadProductData();
  }

  Future<void> _loadDanhMuc() async {
    final snapshot = await _firestore.collection("danhmuc").get();
    setState(() {
      _danhMucList = snapshot.docs.map((doc) {
        return {
          "id": doc["IdDanhMuc"].toString(),
          "ten": doc["Ten"].toString(),
        };
      }).toList();
    });
  }

  Future<void> _loadDanhMucCon(String idDanhMuc) async {
    final snapshot = await _firestore
        .collection("danhmuccon")
        .where("IdDanhMuc", isEqualTo: idDanhMuc)
        .get();

    var newDanhMucConList = snapshot.docs.map((doc) {
      return {
        "id": doc["IdDanhMucCon"].toString(),
        "ten": doc["TenDanhMucCon"].toString(),
      };
    }).toList();

    // Kiểm tra nếu _selectedDanhMucCon không nằm trong newDanhMucConList thì set null
    if (_selectedDanhMucCon != null) {
      bool exists = newDanhMucConList.any((item) => item["id"] == _selectedDanhMucCon);
      if (!exists) {
        _selectedDanhMucCon = null;
        // Khi danh mục con bị set null, thì thương hiệu cũng phải set null
        _selectedThuongHieu = null;
        _thuongHieuList = [];
      }
    }

    setState(() {
      _danhMucConList = newDanhMucConList;
    });
  }

  Future<void> _loadThuongHieu(String idDanhMucCon) async {
    final snapshot = await _firestore
        .collection("thuonghieu")
        .where("IdDanhMucCon", isEqualTo: idDanhMucCon)
        .get();

    var newThuongHieuList = snapshot.docs.map((doc) {
      return {
        "id": doc["IdThuongHieu"].toString(),
        "ten": doc["TenThuongHieu"].toString(),
      };
    }).toList();

    // Kiểm tra nếu _selectedThuongHieu không nằm trong newThuongHieuList thì set null
    if (_selectedThuongHieu != null) {
      bool exists = newThuongHieuList.any((item) => item["id"] == _selectedThuongHieu);
      if (!exists) {
        _selectedThuongHieu = null;
      }
    }

    setState(() {
      _thuongHieuList = newThuongHieuList;
    });
  }

  Future<void> _loadProductData() async {
    try {
      final doc = await _firestore.collection("sanpham").doc(widget.productId).get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Không tìm thấy sản phẩm")),
        );
        Navigator.pop(context);
        return;
      }

      final data = doc.data()!;
      _tenSPController.text = data["TenSanPham"] ?? "";
      _giaController.text = NumberFormat.decimalPattern('vi').format(data["Gia"] ?? 0);
      _soLuongController.text = data["SoLuong"].toString();
      _hinhAnhController.text = data["HinhAnh"] ?? "";
      _moTaController.text = data["MoTa"] ?? "";
      _doTuoiController.text = data["DoTuoi"] ?? "";
      _trongLuongController.text = data["TrongLuong"] ?? "";
      _sanXuatController.text = data["SanXuat"] ?? "";
      _selectedDanhMuc = data["IdDanhMuc"];
      _selectedDanhMucCon = data["IdDanhMucCon"];
      _selectedThuongHieu = data["IdThuongHieu"];
      _trangThai = data["TrangThai"] ?? "Hoạt Động";

      await _loadDanhMucCon(_selectedDanhMuc!);
      await _loadThuongHieu(_selectedDanhMucCon!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi khi tải dữ liệu: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProduct() async {
    // Validate required fields
    if (_tenSPController.text.isEmpty ||
        _giaController.text.isEmpty ||
        _soLuongController.text.isEmpty ||
        _selectedDanhMuc == null ||
        _selectedDanhMucCon == null ||
        _selectedThuongHieu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Vui lòng điền đầy đủ thông tin bắt buộc"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _updating = true);

    try {
      await _firestore.collection("sanpham").doc(widget.productId).update({
        "TenSanPham": _tenSPController.text,
        "Gia": int.tryParse(_giaController.text.replaceAll('.', '')) ?? 0,
        "SoLuong": int.tryParse(_soLuongController.text) ?? 0,
        "HinhAnh": _hinhAnhController.text,
        "MoTa": _moTaController.text,
        "DoTuoi": _doTuoiController.text,
        "TrongLuong": _trongLuongController.text,
        "SanXuat": _sanXuatController.text,
        "IdDanhMuc": _selectedDanhMuc,
        "IdDanhMucCon": _selectedDanhMucCon,
        "IdThuongHieu": _selectedThuongHieu,
        "TrangThai": _trangThai,
        "UpdatedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Cập nhật sản phẩm thành công"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Lỗi khi cập nhật: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _updating = false);
    }
  }

  // Widget cho input field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines,
    bool isRequired = false,
    Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                  fontSize: 14,
                ),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    color: _errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Nhập $label",
                hintStyle: TextStyle(color: _hintColor),
                border: InputBorder.none,
                prefixIcon: Icon(icon, color: _primaryColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho dropdown field
  Widget _buildDropdownField({
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
    required String label,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                  fontSize: 14,
                ),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    color: _errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(icon, color: _primaryColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              hint: Text("Chọn $label", style: TextStyle(color: _hintColor)),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item["id"].toString(),
                  child: Text(
                    item["ten"].toString(),
                    style: TextStyle(color: _textColor),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho image preview
  Widget _buildImagePreview() {
    if (_hinhAnhController.text.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: _hintColor),
            const SizedBox(height: 8),
            Text(
              "Chưa có hình ảnh",
              style: TextStyle(color: _hintColor),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primaryColor.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _hinhAnhController.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _backgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined, size: 48, color: _errorColor),
                      const SizedBox(height: 8),
                      Text(
                        "Không thể tải ảnh",
                        style: TextStyle(color: _errorColor),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: _backgroundColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: _primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Xem trước hình ảnh",
          style: TextStyle(
            color: _hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Widget cho section header
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: _hintColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _primaryColor),
              const SizedBox(height: 16),
              Text(
                "Đang tải thông tin sản phẩm...",
                style: TextStyle(
                  color: _textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa sản phẩm",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_updating)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin phân loại
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    "Phân loại sản phẩm",
                    "Chọn danh mục và thương hiệu cho sản phẩm",
                  ),
                  _buildDropdownField(
                    value: _selectedDanhMuc,
                    items: _danhMucList,
                    onChanged: (value) {
                      setState(() => _selectedDanhMuc = value);
                      if (value != null) _loadDanhMucCon(value);
                    },
                    label: "Danh mục",
                    icon: Icons.category_rounded,
                    isRequired: true,
                  ),
                  _buildDropdownField(
                    value: _selectedDanhMucCon,
                    items: _danhMucConList,
                    onChanged: (value) {
                      setState(() => _selectedDanhMucCon = value);
                      if (value != null) _loadThuongHieu(value);
                    },
                    label: "Danh mục con",
                    icon: Icons.category_outlined,
                    isRequired: true,
                  ),
                  _buildDropdownField(
                    value: _selectedThuongHieu,
                    items: _thuongHieuList,
                    onChanged: (value) => setState(() => _selectedThuongHieu = value),
                    label: "Thương hiệu",
                    icon: Icons.branding_watermark_rounded,
                    isRequired: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Thông tin cơ bản
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    "Thông tin cơ bản",
                    "Thông tin chính của sản phẩm",
                  ),
                  _buildInputField(
                    controller: _tenSPController,
                    label: "Tên sản phẩm",
                    icon: Icons.shopping_bag_rounded,
                    isRequired: true,
                  ),
                  _buildInputField(
                    controller: _giaController,
                    label: "Giá sản phẩm",
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isEmpty) return newValue;
                        final value = int.tryParse(newValue.text.replaceAll('.', ''));
                        if (value == null) return oldValue;
                        final newText = NumberFormat.decimalPattern('vi').format(value);
                        return TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(offset: newText.length),
                        );
                      }),
                    ],
                    isRequired: true,
                  ),
                  _buildInputField(
                    controller: _soLuongController,
                    label: "Số lượng",
                    icon: Icons.inventory_2_rounded,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trạng thái",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _textColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: _surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _trangThai,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.circle_rounded, color: _primaryColor),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: "Hoạt Động",
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: _successColor, size: 18),
                                    const SizedBox(width: 8),
                                    Text("Hoạt Động", style: TextStyle(color: _textColor)),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Ngưng Hoạt Động",
                                child: Row(
                                  children: [
                                    Icon(Icons.pause_circle, color: _errorColor, size: 18),
                                    const SizedBox(width: 8),
                                    Text("Ngưng Hoạt Động", style: TextStyle(color: _textColor)),
                                  ],
                                ),
                              ),
                            ].toList(),
                            onChanged: (val) => setState(() => _trangThai = val!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hình ảnh sản phẩm
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    "Hình ảnh sản phẩm",
                    "URL hình ảnh và xem trước",
                  ),
                  _buildInputField(
                    controller: _hinhAnhController,
                    label: "URL hình ảnh",
                    icon: Icons.link_rounded,
                    onChanged: (value) => setState(() {}),
                  ),
                  _buildImagePreview(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Thông tin bổ sung
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    "Thông tin bổ sung",
                    "Thông tin chi tiết về sản phẩm",
                  ),
                  _buildInputField(
                    controller: _moTaController,
                    label: "Mô tả sản phẩm",
                    icon: Icons.description_rounded,
                    maxLines: 3,
                  ),
                  _buildInputField(
                    controller: _doTuoiController,
                    label: "Độ tuổi sử dụng",
                    icon: Icons.child_care_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInputField(
                    controller: _trongLuongController,
                    label: "Trọng lượng",
                    icon: Icons.scale_rounded,
                  ),
                  _buildInputField(
                    controller: _sanXuatController,
                    label: "Xuất xứ",
                    icon: Icons.flag_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Nút cập nhật
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _updating ? null : _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _updating
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "ĐANG CẬP NHẬT...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "CẬP NHẬT SẢN PHẨM",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tenSPController.dispose();
    _giaController.dispose();
    _soLuongController.dispose();
    _hinhAnhController.dispose();
    _moTaController.dispose();
    _doTuoiController.dispose();
    _trongLuongController.dispose();
    _sanXuatController.dispose();
    super.dispose();
  }
}

//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// class EditProductPage extends StatefulWidget {
//   final String productId;
//
//   const EditProductPage({Key? key, required this.productId}) : super(key: key);
//
//   @override
//   State<EditProductPage> createState() => _EditProductPageState();
// }
//
// class _EditProductPageState extends State<EditProductPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Color scheme
//   final Color _primaryColor = const Color(0xFF007BFF);
//   final Color _secondaryColor = const Color(0xFF0056CC);
//   final Color _backgroundColor = const Color(0xFFF8FAFC);
//   final Color _surfaceColor = Colors.white;
//   final Color _textColor = const Color(0xFF1E293B);
//   final Color _hintColor = const Color(0xFF64748B);
//   final Color _successColor = const Color(0xFF10B981);
//   final Color _errorColor = const Color(0xFFEF4444);
//   final Color _warningColor = const Color(0xFFF59E0B);
//
//   // Controllers
//   final _tenSPController = TextEditingController();
//   final _giaController = TextEditingController();
//   final _soLuongController = TextEditingController();
//   final _hinhAnhController = TextEditingController();
//   final _moTaController = TextEditingController();
//   final _doTuoiController = TextEditingController();
//   final _trongLuongController = TextEditingController();
//   final _sanXuatController = TextEditingController();
//
//   // Dropdown
//   String? _selectedDanhMuc;
//   String? _selectedDanhMucCon;
//   String? _selectedThuongHieu;
//   List<Map<String, dynamic>> _danhMucList = [];
//   List<Map<String, dynamic>> _danhMucConList = [];
//   List<Map<String, dynamic>> _thuongHieuList = [];
//
//   String _trangThai = "Hoạt Động";
//   bool _loading = true;
//   bool _updating = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDanhMuc();
//     _loadProductData();
//   }
//
//   Future<void> _loadDanhMuc() async {
//     final snapshot = await _firestore.collection("danhmuc").get();
//     setState(() {
//       _danhMucList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdDanhMuc"].toString(),
//           "ten": doc["Ten"].toString(),
//         };
//       }).toList();
//     });
//   }
//
//   Future<void> _loadDanhMucCon(String idDanhMuc) async {
//     final snapshot = await _firestore
//         .collection("danhmuccon")
//         .where("IdDanhMuc", isEqualTo: idDanhMuc)
//         .get();
//
//     setState(() {
//       _danhMucConList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdDanhMucCon"].toString(),
//           "ten": doc["TenDanhMucCon"].toString(),
//         };
//       }).toList();
//       _selectedDanhMucCon = null;
//       _selectedThuongHieu = null;
//       _thuongHieuList = [];
//     });
//   }
//
//   Future<void> _loadThuongHieu(String idDanhMucCon) async {
//     final snapshot = await _firestore
//         .collection("thuonghieu")
//         .where("IdDanhMucCon", isEqualTo: idDanhMucCon)
//         .get();
//
//     setState(() {
//       _thuongHieuList = snapshot.docs.map((doc) {
//         return {
//           "id": doc["IdThuongHieu"].toString(),
//           "ten": doc["TenThuongHieu"].toString(),
//         };
//       }).toList();
//       _selectedThuongHieu = null;
//     });
//   }
//
//   Future<void> _loadProductData() async {
//     try {
//       final doc = await _firestore.collection("sanpham").doc(widget.productId).get();
//       if (!doc.exists) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❌ Không tìm thấy sản phẩm")),
//         );
//         Navigator.pop(context);
//         return;
//       }
//
//       final data = doc.data()!;
//       _tenSPController.text = data["TenSanPham"] ?? "";
//       _giaController.text = NumberFormat.decimalPattern('vi').format(data["Gia"] ?? 0);
//       _soLuongController.text = data["SoLuong"].toString();
//       _hinhAnhController.text = data["HinhAnh"] ?? "";
//       _moTaController.text = data["MoTa"] ?? "";
//       _doTuoiController.text = data["DoTuoi"] ?? "";
//       _trongLuongController.text = data["TrongLuong"] ?? "";
//       _sanXuatController.text = data["SanXuat"] ?? "";
//       _selectedDanhMuc = data["IdDanhMuc"];
//       _selectedDanhMucCon = data["IdDanhMucCon"];
//       _selectedThuongHieu = data["IdThuongHieu"];
//       _trangThai = data["TrangThai"] ?? "Hoạt Động";
//
//       await _loadDanhMucCon(_selectedDanhMuc!);
//       await _loadThuongHieu(_selectedDanhMucCon!);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ Lỗi khi tải dữ liệu: $e")),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _updateProduct() async {
//     if (_tenSPController.text.isEmpty ||
//         _giaController.text.isEmpty ||
//         _soLuongController.text.isEmpty ||
//         _selectedDanhMuc == null ||
//         _selectedDanhMucCon == null ||
//         _selectedThuongHieu == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("⚠️ Vui lòng điền đầy đủ thông tin bắt buộc")),
//       );
//       return;
//     }
//
//     setState(() => _updating = true);
//
//     try {
//       await _firestore.collection("sanpham").doc(widget.productId).update({
//         "TenSanPham": _tenSPController.text,
//         "Gia": int.tryParse(_giaController.text.replaceAll('.', '')) ?? 0,
//         "SoLuong": int.tryParse(_soLuongController.text) ?? 0,
//         "HinhAnh": _hinhAnhController.text,
//         "MoTa": _moTaController.text,
//         "DoTuoi": _doTuoiController.text,
//         "TrongLuong": _trongLuongController.text,
//         "SanXuat": _sanXuatController.text,
//         "IdDanhMuc": _selectedDanhMuc,
//         "IdDanhMucCon": _selectedDanhMucCon,
//         "IdThuongHieu": _selectedThuongHieu,
//         "TrangThai": _trangThai,
//         "UpdatedAt": FieldValue.serverTimestamp(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("✅ Cập nhật sản phẩm thành công"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Lỗi khi cập nhật: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _updating = false);
//     }
//   }
//
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     Function(String)? onChanged, // Thêm dòng này chỗ hình ảnh
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     int? maxLines,
//     bool isRequired = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: _textColor,
//                   fontSize: 14,
//                 ),
//               ),
//               if (isRequired)
//                 Text(
//                   " *",
//                   style: TextStyle(
//                     color: _errorColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Container(
//             decoration: BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 6,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: controller,
//               keyboardType: keyboardType,
//               inputFormatters: inputFormatters,
//               maxLines: maxLines,
//               decoration: InputDecoration(
//                 hintText: "Nhập $label",
//                 hintStyle: TextStyle(color: _hintColor),
//                 border: InputBorder.none,
//                 prefixIcon: Icon(icon, color: _primaryColor),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdownField({
//     required String value,
//     required List<Map<String, dynamic>> items,
//     required Function(String?) onChanged,
//     required String label,
//     required IconData icon,
//     bool isRequired = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: _textColor,
//                   fontSize: 14,
//                 ),
//               ),
//               if (isRequired)
//                 Text(
//                   " *",
//                   style: TextStyle(
//                     color: _errorColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Container(
//             decoration: BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 6,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: DropdownButtonFormField<String>(
//               value: value.isEmpty ? null : value,
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 prefixIcon: Icon(icon, color: _primaryColor),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               ),
//               hint: Text("Chọn $label", style: TextStyle(color: _hintColor)),
//               items: items.map((item) {
//                 return DropdownMenuItem<String>(
//                   value: item["id"].toString(),
//                   child: Text(
//                     item["ten"].toString(),
//                     style: TextStyle(color: _textColor),
//                   ),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImagePreview() {
//     if (_hinhAnhController.text.isEmpty) {
//       return Container(
//         height: 150,
//         decoration: BoxDecoration(
//           color: _backgroundColor,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _hintColor.withOpacity(0.3)),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.image, size: 48, color: _hintColor),
//             const SizedBox(height: 8),
//             Text(
//               "Chưa có hình ảnh",
//               style: TextStyle(color: _hintColor),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Column(
//       children: [
//         Container(
//           height: 200,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: _primaryColor.withOpacity(0.3)),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               _hinhAnhController.text,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: _backgroundColor,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.broken_image, size: 48, color: _errorColor),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Không thể tải ảnh",
//                         style: TextStyle(color: _errorColor),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Container(
//                   color: _backgroundColor,
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                           : null,
//                       color: _primaryColor,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "Xem trước hình ảnh",
//           style: TextStyle(
//             color: _hintColor,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Scaffold(
//         backgroundColor: _backgroundColor,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: _primaryColor),
//               const SizedBox(height: 16),
//               Text(
//                 "Đang tải thông tin sản phẩm...",
//                 style: TextStyle(
//                   color: _textColor,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           "Chỉnh sửa sản phẩm",
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: _primaryColor,
//         centerTitle: true,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           if (_updating)
//             Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Thông tin phân loại
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Phân loại sản phẩm",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: _textColor,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Chọn danh mục và thương hiệu cho sản phẩm",
//                       style: TextStyle(
//                         color: _hintColor,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildDropdownField(
//                       value: _selectedDanhMuc ?? "",
//                       items: _danhMucList,
//                       onChanged: (value) {
//                         setState(() => _selectedDanhMuc = value);
//                         if (value != null) _loadDanhMucCon(value);
//                       },
//                       label: "Danh mục",
//                       icon: Icons.category_rounded,
//                       isRequired: true,
//                     ),
//                     _buildDropdownField(
//                       value: _selectedDanhMucCon ?? "",
//                       items: _danhMucConList,
//                       onChanged: (value) {
//                         setState(() => _selectedDanhMucCon = value);
//                         if (value != null) _loadThuongHieu(value);
//                       },
//                       label: "Danh mục con",
//                       icon: Icons.category_outlined,
//                       isRequired: true,
//                     ),
//                     _buildDropdownField(
//                       value: _selectedThuongHieu ?? "",
//                       items: _thuongHieuList,
//                       onChanged: (value) => setState(() => _selectedThuongHieu = value),
//                       label: "Thương hiệu",
//                       icon: Icons.branding_watermark_rounded,
//                       isRequired: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Thông tin cơ bản
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Thông tin cơ bản",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: _textColor,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Thông tin chính của sản phẩm",
//                       style: TextStyle(
//                         color: _hintColor,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildInputField(
//                       controller: _tenSPController,
//                       label: "Tên sản phẩm",
//                       icon: Icons.shopping_bag_rounded,
//                       isRequired: true,
//                     ),
//                     _buildInputField(
//                       controller: _giaController,
//                       label: "Giá sản phẩm",
//                       icon: Icons.attach_money_rounded,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         TextInputFormatter.withFunction((oldValue, newValue) {
//                           if (newValue.text.isEmpty) return newValue;
//                           final value = int.tryParse(newValue.text.replaceAll('.', ''));
//                           if (value == null) return oldValue;
//                           final newText = NumberFormat.decimalPattern('vi').format(value);
//                           return TextEditingValue(
//                             text: newText,
//                             selection: TextSelection.collapsed(offset: newText.length),
//                           );
//                         }),
//                       ],
//                       isRequired: true,
//                     ),
//                     _buildInputField(
//                       controller: _soLuongController,
//                       label: "Số lượng",
//                       icon: Icons.inventory_2_rounded,
//                       keyboardType: TextInputType.number,
//                       isRequired: true,
//                     ),
//                     Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Trạng thái",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: _textColor,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: _surfaceColor,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.05),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: DropdownButtonFormField<String>(
//                               value: _trangThai,
//                               decoration: InputDecoration(
//                                 border: InputBorder.none,
//                                 prefixIcon: Icon(Icons.circle_rounded, color: _primaryColor),
//                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                               ),
//                               items: [
//                                 DropdownMenuItem(
//                                   value: "Hoạt Động",
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.check_circle, color: _successColor, size: 18),
//                                       const SizedBox(width: 8),
//                                       Text("Hoạt Động", style: TextStyle(color: _textColor)),
//                                     ],
//                                   ),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: "Ngưng Hoạt Động",
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.pause_circle, color: _errorColor, size: 18),
//                                       const SizedBox(width: 8),
//                                       Text("Ngưng Hoạt Động", style: TextStyle(color: _textColor)),
//                                     ],
//                                   ),
//                                 ),
//                               ].toList(),
//                               onChanged: (val) => setState(() => _trangThai = val!),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Hình ảnh sản phẩm
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Hình ảnh sản phẩm",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: _textColor,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "URL hình ảnh và xem trước",
//                       style: TextStyle(
//                         color: _hintColor,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildInputField(
//                       controller: _hinhAnhController,
//                       label: "URL hình ảnh",
//                       icon: Icons.link_rounded,
//                       onChanged: (val) => setState(() {}),
//                     ),
//                     _buildImagePreview(),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Thông tin bổ sung
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Thông tin bổ sung",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: _textColor,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Thông tin chi tiết về sản phẩm",
//                       style: TextStyle(
//                         color: _hintColor,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildInputField(
//                       controller: _moTaController,
//                       label: "Mô tả sản phẩm",
//                       icon: Icons.description_rounded,
//                       maxLines: 3,
//                     ),
//                     _buildInputField(
//                       controller: _doTuoiController,
//                       label: "Độ tuổi sử dụng",
//                       icon: Icons.child_care_rounded,
//                       keyboardType: TextInputType.number,
//                     ),
//                     _buildInputField(
//                       controller: _trongLuongController,
//                       label: "Trọng lượng",
//                       icon: Icons.scale_rounded,
//                     ),
//                     _buildInputField(
//                       controller: _sanXuatController,
//                       label: "Xuất xứ",
//                       icon: Icons.flag_rounded,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             // Nút cập nhật
//             Container(
//               width: double.infinity,
//               height: 56,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [_primaryColor, _secondaryColor],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _primaryColor.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ElevatedButton(
//                 onPressed: _updating ? null : _updateProduct,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 ),
//                 child: _updating
//                     ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       "ĐANG CẬP NHẬT...",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 )
//                     : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.save_rounded, color: Colors.white),
//                     const SizedBox(width: 8),
//                     Text(
//                       "CẬP NHẬT SẢN PHẨM",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _tenSPController.dispose();
//     _giaController.dispose();
//     _soLuongController.dispose();
//     _hinhAnhController.dispose();
//     _moTaController.dispose();
//     _doTuoiController.dispose();
//     _trongLuongController.dispose();
//     _sanXuatController.dispose();
//     super.dispose();
//   }
// }