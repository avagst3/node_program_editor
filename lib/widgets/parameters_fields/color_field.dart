import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'color_picker_dialog.dart';

class ColorField extends StatefulWidget {
  final double height;
  final double width;
  final String label;
  final TextEditingController controller;
  const ColorField({
    super.key,
    required this.height,
    required this.width,
    required this.label,
    required this.controller,
  });

  @override
  State<ColorField> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<ColorField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.height * 0.25,
            child: AutoSizeText(
              widget.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.controller.text),
              GestureDetector(
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      int.parse(widget.controller.text.split(',')[0]),
                      int.parse(widget.controller.text.split(',')[1]),
                      int.parse(widget.controller.text.split(',')[2]),
                      1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black38),
                  ),
                ),
                onTap: () async {
                  Future<Color> pickedColor = showPickColorDialog(
                      context,
                      Color.fromRGBO(
                        int.parse(widget.controller.text.split(',')[0]),
                        int.parse(widget.controller.text.split(',')[1]),
                        int.parse(widget.controller.text.split(',')[2]),
                        1,
                      ),
                      'Pick a component color');
                  Color cl = await pickedColor;
                  print("${cl.r * 255}, ${cl.g * 255}, ${cl.b * 255}");
                  setState(() {
                    widget.controller.text =
                        "${(cl.r * 255).toInt()}, ${(cl.g * 255).toInt()}, ${(cl.b * 255).toInt()}";
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
