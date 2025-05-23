import 'package:admin_panel_app_web/resource/themes/app_colors.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/widgets/buyer_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyersScreen extends StatelessWidget {
  static const String id = '\buyer-screen';

  const BuyersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                'Danh sách người dùng',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
        const    BuyerWidget(),
          ],
        ),
      ),
    );
  }
}
