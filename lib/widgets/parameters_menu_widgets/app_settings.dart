import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/program/program_cubit.dart';
import '../../models/result.dart';
import '../../policy/builder_set_policy.dart';
import '../../providers/builder_style.dart';
import '../parameters_fields/color_picker_dialog.dart';
import '../../widgets/parameters_fields/file_field.dart';
import '../../widgets/parameters_fields/folder_field.dart';
import '../../widgets/parameters_fields/str_field.dart';
import '../../providers/program_data_provider.dart';

class AppSettings extends StatelessWidget {
  final BuilderStyle properties;
  final BuilderSetPolicy policy;
  final double height;
  final double width;
  const AppSettings({
    super.key,
    required this.properties,
    required this.policy,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramDataProvider>();
    final styleProvider = context.watch<BuilderStyle>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  Result<Map<String, dynamic>, bool> program =
                      policy.toProgram();
                  if (program is Success) {
                    context
                        .read<ProgramCubit>()
                        .emitProgram((program as Success).value);
                  }
                },
                icon: Icon(Icons.upload_rounded),
                tooltip: "Export program",
              ),
              IconButton.filledTonal(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController _fileController =
                            TextEditingController();
                        final TextEditingController _programName =
                            TextEditingController();

                        _programName.text = provider.programName ?? "";
                        return AlertDialog(
                          title: Text("Load a program"),
                          content: SizedBox(
                            height: 350,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FolderField(
                                  height: 100,
                                  width: width,
                                  label: "Select save directory",
                                  controller: _fileController,
                                ),
                                Divider(),
                                StrField(
                                  height: 100,
                                  width: width,
                                  label: 'Program Name',
                                  controller: _programName,
                                ),
                                Divider(),
                                FilledButton(
                                  onPressed: () async {
                                    if (_fileController.text != "" &&
                                        _programName.text != "") {
                                      File file = File(
                                          '${_fileController.text}/${_programName.text}.egp');
                                      var content =
                                          policy.serialize(styleProvider);
                                      styleProvider.toJson();
                                      await file
                                          .writeAsString(jsonEncode(content));
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text("Save"),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
                icon: Icon(Icons.save),
                tooltip: "Save program",
              ),
              IconButton.filledTonal(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController _fileController =
                            TextEditingController();
                        return AlertDialog(
                          title: Text("Load a program"),
                          content: SizedBox(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FileField(
                                  height: 100,
                                  width: width,
                                  label: "Select program file",
                                  controller: _fileController,
                                  allowedExtensions: ["egp"],
                                  allowMultiple: false,
                                ),
                                Divider(),
                                FilledButton(
                                  onPressed: () async {
                                    if (_fileController.text != "") {
                                      final file = File(_fileController.text);
                                      final content = await file.readAsString();
                                      final contentAsJson = jsonDecode(content)
                                          as Map<String, dynamic>;
                                      policy.importDiagramFromJson(context,
                                          contentAsJson, styleProvider);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text("Load"),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
                icon: Icon(Icons.download),
                tooltip: "Load program",
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Ports colors :",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            height: height * 0.4,
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(4),
            child: SingleChildScrollView(
              child: Column(
                children: properties.entriesColors.map<Widget>((entry) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.name),
                            GestureDetector(
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: entry.color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onTap: () async {
                                var pickedColor = showPickColorDialog(context,
                                    entry.color, 'Pick a component color');
                                context
                                    .read<BuilderStyle>()
                                    .updateEntryColor(entry, await pickedColor);
                              },
                            )
                          ],
                        ),
                        Divider(),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
