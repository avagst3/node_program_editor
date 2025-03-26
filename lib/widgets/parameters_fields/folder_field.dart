import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FolderField extends StatefulWidget {
  final double height;
  final double width;
  final String label;
  final TextEditingController controller;
  const FolderField({
    super.key,
    required this.height,
    required this.width,
    required this.label,
    required this.controller,
  });

  @override
  State<FolderField> createState() => _FolderFieldState();
}

class _FolderFieldState extends State<FolderField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.height * 0.5,
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
              SizedBox(
                width: widget.width * 0.5,
                child: Text(
                  widget.controller.text,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  final String? pickedFolder =
                      await FilePicker.platform.getDirectoryPath();
                  if (pickedFolder != null) {
                    setState(() {
                      widget.controller.text = pickedFolder;
                    });
                  }
                },
                child: Text("Pick Folder"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
