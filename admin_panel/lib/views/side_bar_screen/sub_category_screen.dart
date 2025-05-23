import 'package:admin_panel_app_web/controllers/category_controller.dart';
import 'package:admin_panel_app_web/controllers/subcategory_controller.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/widgets/subcategory_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../models/category.dart';

class SubCategoryScreen extends StatefulWidget {
  static const String id = 'subcategoryScreen';

  const SubCategoryScreen({super.key});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late Future<List<Category>> futureCategories;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SubcategoryController subcategoryController = SubcategoryController();
  Category? selectedCategory;
  dynamic _image;
  late String name;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.purple.shade700],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    "Quản lý Danh mục con",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phần tải lên danh mục con
                          Text(
                            "Thêm Danh mục con mới",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Chọn danh mục cha
                          FutureBuilder<List<Category>>(
                            future: futureCategories,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Lỗi: ${snapshot.error}',
                                  style: TextStyle(color: Colors.red.shade700),
                                );
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text(
                                  "Không có danh mục nào",
                                  style: TextStyle(color: Colors.grey),
                                );
                              } else {
                                return SizedBox(
                                  width: 350,
                                  child: DropdownButtonFormField<Category>(
                                    decoration: InputDecoration(
                                      labelText: "Chọn danh mục",
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    value: selectedCategory,
                                    items: snapshot.data!.map((Category category) {
                                      return DropdownMenuItem(
                                        value: category,
                                        child: Text(category.name),
                                      );
                                    }).toList(),
                                    onChanged: (Category? value) {
                                      setState(() {
                                        selectedCategory = value;
                                      });
                                    },
                                    validator: (value) => value == null ? "Vui lòng chọn danh mục" : null,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Nhập tên danh mục con
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              onChanged: (value) => name = value,
                              validator: (value) => value!.isNotEmpty ? null : "Nhập tên danh mục con",
                              decoration: InputDecoration(
                                labelText: "Tên danh mục con",
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Chọn ảnh
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: _image != null ? Colors.white : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _image != null ? Colors.blueAccent : Colors.grey,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _image != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      _image,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                                  )
                                      : Text(
                                    "Chọn ảnh",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildGradientButton(
                                text: "Chọn ảnh",
                                icon: Icons.image,
                                onPressed: pickImage,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Nút lưu
                          _buildGradientButton(
                            text: "Lưu",
                            icon: Icons.save,
                            onPressed: _image == null || selectedCategory == null || _isUploading
                                ? null
                                : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isUploading = true);
                                await subcategoryController.uploadSubcategory(
                                  categoryId: selectedCategory!.id,
                                  categoryName: selectedCategory!.name,
                                  pickedImage: _image,
                                  subCategoryName: name,
                                  context: context,
                                );
                                setState(() {
                                  _formKey.currentState!.reset();
                                  _image = null;
                                  selectedCategory = null;
                                  _isUploading = false;
                                });
                              }
                            },
                            isLoading: _isUploading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Danh sách danh mục con
                  Text(
                    "Danh sách Danh mục con",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const SubcategoryWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget nút gradient tùy chỉnh
  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}