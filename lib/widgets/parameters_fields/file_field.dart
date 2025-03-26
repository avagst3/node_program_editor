import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileField extends StatefulWidget {
  final double height;
  final double width;
  final String label;
  final List<String> allowedExtensions;
  final bool allowMultiple;
  final TextEditingController controller;
  const FileField({
    super.key,
    required this.height,
    required this.width,
    required this.label,
    required this.controller,
    required this.allowedExtensions,
    required this.allowMultiple,
  });

  @override
  State<FileField> createState() => _FileFieldState();
}

class _FileFieldState extends State<FileField> {
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
                  final FilePickerResult? pickedFile =
                      await FilePicker.platform.pickFiles(
                    allowedExtensions: widget.allowedExtensions,
                    allowMultiple: widget.allowMultiple,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      widget.controller.text = pickedFile.files.first.path!;
                    });
                  }
                },
                child: Text("Pick File"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
