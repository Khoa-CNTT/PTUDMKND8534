import 'package:admin_panel_app_web/views/side_bar_screen/widgets/vendor_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorsScreen extends StatelessWidget {
  static const String id = '\vendorScreen';
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              'Danh sách nhà cung cấp',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        const  VendorWidget(),
        ],
      ),
    );
  }
}
