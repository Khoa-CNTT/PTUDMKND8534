import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store/models/vendor.dart';
import 'dart:convert';

// StateNotifier: Quản lý trạng thái vendor
class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider()
      : super(Vendor(
    id: '',
    fullName: '',
    email: '',
    phone: '',
    address: '',
    role: '',
    password: '',
    token: '',
    storeImage: '',
    storeDescription: '',
  )) {
    _loadVendor();
  }

  // Getter lấy thông tin vendor hiện tại
  Vendor? get vendor => state;

  // Tải thông tin vendor từ SharedPreferences
  Future<void> _loadVendor({bool forceRefresh = false}) async {
    if (state != null && state!.id.isNotEmpty && !forceRefresh) {
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user') ?? '';

      if (userJson.isEmpty) {
        print("Không có thông tin vendor trong SharedPreferences");
        state = null;
        return;
      }

      state = Vendor.fromJson(jsonDecode(userJson));
    } catch (e) {
      print("Lỗi khi tải thông tin vendor: $e");
      state = null;
    }
  }

  // Phương thức cập nhật state từ JSON String
  void setVendor(String vendorJson) {
    final Map<String, dynamic> vendorMap = jsonDecode(vendorJson);
    state = Vendor.fromJson(vendorMap);
  }

  // Phương thức cập nhật state từ Object Vendor
  void setVendorFromObject(Vendor vendor) {
    state = vendor;
  }

  // Phương thức chuyển trạng thái vendor về null khi đăng xuất
  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user');
    state = null;
  }

  // Làm mới thông tin vendor
  Future<void> refreshVendor() async {
    await _loadVendor(forceRefresh: true);
  }
}

// Provider cho VendorProvider
final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});