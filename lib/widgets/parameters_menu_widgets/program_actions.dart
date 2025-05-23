import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/program/program_cubit.dart';
import '../../models/result.dart';
import '../../policy/builder_set_policy.dart';
import '../../providers/builder_style.dart';
import '../../providers/program_data_provider.dart';
import '../../providers/text_provider.dart';
import '../parameters_fields/file_field.dart';
import '../parameters_fields/folder_field.dart';
import '../parameters_fields/str_field.dart';

class ProgramActions extends StatelessWidget {
  const ProgramActions({
    super.key,
    required this.policy,
    required this.provider,
    required this.width,
    required this.styleProvider,
  });

  final BuilderSetPolicy policy;
  final ProgramDataProvider provider;
  final double width;
  final BuilderStyle styleProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<TextProvider>(builder: (context, textProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              onPressed: () {
                Result<Map<String, dynamic>, bool> program = policy.toProgram();

                if (program is Success) {
                  context
                      .read<ProgramCubit>()
                      .emitProgram((program as Success).value);
                }
              },
              icon: Icon(Icons.upload_rounded),
              tooltip: textProvider.text.exportProgramLabel,
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
                        title: Text(textProvider.text.saveProgramLabel),
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
              tooltip: textProvider.text.saveProgramLabel,
            ),
            IconButton.filledTonal(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController _fileController =
                          TextEditingController();
                      return AlertDialog(
                        title: Text(textProvider.text.importProgramLabel),
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
                                    policy.importDiagramFromJson(
                                        context, contentAsJson, styleProvider);
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
              tooltip: textProvider.text.importProgramLabel,
            ),
          ],
        );
      }),
    );
  }
}
