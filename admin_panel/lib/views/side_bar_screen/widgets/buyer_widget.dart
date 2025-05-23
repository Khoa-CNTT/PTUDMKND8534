import 'dart:io';
import 'package:admin_panel_app_web/controllers/buyer_controller.dart';
import 'package:admin_panel_app_web/models/buyer.dart';
import 'package:admin_panel_app_web/resource/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../resource/asset/app_images.dart';

class BuyerWidget extends StatefulWidget {
  const BuyerWidget({super.key});

  @override
  State<BuyerWidget> createState() => _BuyerWidgetState();
}

class _BuyerWidgetState extends State<BuyerWidget> {
  late Future<List<Buyer>> futureBuyers;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    futureBuyers = BuyerController().loadBuyer();
    debugPrint('BuyerWidget: Initialized, loading buyers');
  }

  void _refreshBuyers() {
    debugPrint('BuyerWidget: Refreshing buyers');
    setState(() {
      futureBuyers = BuyerController().loadBuyer();
    });
  }

  ImageProvider _buildUserImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return AssetImage(AppImages.imgDefaultAvatar);
    } else if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        return AssetImage(AppImages.imgDefaultAvatar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Buyer>>(
      future: futureBuyers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Buyers Found"));
        } else {
          final buyers = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.85,
              ),
              itemCount: buyers.length,
              itemBuilder: (context, index) {
                final buyer = buyers[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16), // Tăng padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 32, // Tăng kích thước avatar
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: _buildUserImage(buyer.image),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        buyer.fullName,
                        style: GoogleFonts.montserrat(
                          fontSize: 16, // Tăng font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        buyer.email,
                        style: GoogleFonts.montserrat(
                          fontSize: 14, // Tăng font size
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        buyer.phone,
                        style: GoogleFonts.montserrat(
                          fontSize: 14, // Tăng font size
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        buyer.address,
                        style: GoogleFonts.montserrat(
                          fontSize: 14, // Tăng font size
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 180, // Tăng chiều rộng nút
                        child: TextButton(
                          onPressed: _isDeleting
                              ? null
                              : () async {
                            if (buyer.id.isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("ID người dùng không hợp lệ")),
                                );
                              }
                              return;
                            }
                            setState(() => _isDeleting = true);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xóa Người dùng'),
                                content: const Text('Bạn có chắc muốn xóa tài khoản này?'),
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

                            if (confirm == true && context.mounted) {
                              await BuyerController().deleteBuyer(
                                buyerId: buyer.id,
                                context: context,
                              );
                              _refreshBuyers();
                            }
                            setState(() => _isDeleting = false);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(AppColors.bluePrimary),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Tăng padding nút
                            ),
                          ),
                          child: _isDeleting
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            "Xóa người dùng",
                            style: GoogleFonts.montserrat(
                              fontSize: 14, // Tăng font size
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}