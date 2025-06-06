import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class StrField extends StatelessWidget {
  final double height;
  final double width;
  final String label;
  final TextEditingController? controller;
  const StrField({
    super.key,
    required this.height,
    required this.width,
    required this.label,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.25,
            child: AutoSizeText(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextField(
            controller: controller,
          ),
        ],
      ),
    );
  }
}
