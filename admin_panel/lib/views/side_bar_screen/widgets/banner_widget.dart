import 'package:admin_panel_app_web/controllers/banner_controller.dart';
import 'package:admin_panel_app_web/models/banner.dart';
import 'package:flutter/material.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final BannerController _bannerController = BannerController();
  late Future<List<BannerModel>> _bannersFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _bannersFuture = _bannerController.loadBanners();
  }

  void _refreshBanners() {
    setState(() {
      _bannersFuture = _bannerController.loadBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có banner nào'));
        }

        final banners = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2,
          ),
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final banner = banners[index];
            return Card(
              elevation: 2,
              child: Stack(
                children: [
                  Image.network(
                    banner.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: _isDeleting
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.delete, color: Colors.red),
                      onPressed: _isDeleting
                          ? null
                          : () async {
                        if (banner.id.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("ID banner không hợp lệ")),
                            );
                          }
                          return;
                        }
                        setState(() => _isDeleting = true);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xóa Banner'),
                            content: const Text('Bạn có chắc muốn xóa banner này?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await _bannerController.deleteBanner(
                              bannerId: banner.id,
                              context: context,
                            );
                            _refreshBanners();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi khi xóa banner: $e')),
                              );
                            }
                          }
                        } else {
                        }
                        setState(() => _isDeleting = false);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}