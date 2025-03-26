import 'package:auto_size_text/auto_size_text.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

import '../../models/builder_component_data.dart';
import '../../models/components_parameters_types.dart';
import '../parameters_fields/color_field.dart';
import '../parameters_fields/dropdown.dart';
import '../parameters_fields/file_field.dart';
import '../parameters_fields/float_field.dart';
import '../parameters_fields/folder_field.dart';
import '../parameters_fields/int_field.dart';
import '../parameters_fields/str_field.dart';

class BuilderComponentSettings extends StatefulWidget {
  ComponentData data;
  final double width;
  final double height;
  final TextEditingController _controller = TextEditingController();

  /// Provide Field to change components parameters from the component datas
  BuilderComponentSettings(
      {super.key,
      required this.data,
      required this.width,
      required this.height});

  @override
  State<BuilderComponentSettings> createState() =>
      _BuilderComponentSettingsState();
}

class _BuilderComponentSettingsState extends State<BuilderComponentSettings> {
  @override
  Widget build(BuildContext context) {
    widget._controller.text = widget.data.data.name;
    final Map<String, TextEditingController> controllers = {};
    final BuilderComponentData builderComponentData = widget.data.data;
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                  width: widget.width * 0.5,
                  child: AutoSizeText(
                    "Edit parameters",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                    maxLines: 1,
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      widget.data.data.name = widget._controller.text;
                      for (var param in builderComponentData.parameters) {
                        param.value = controllers[param.name]?.text;
                      }
                      widget.data.updateComponent();
                    });
                  },
                  child: Text("Update"),
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  height: widget.height * 0.8,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 30,
                      children: [
                        StrField(
                          height: 100,
                          width: widget.width,
                          label: "Block name",
                          controller: widget._controller,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: builderComponentData.parameters
                              .map<Widget>((param) {
                            controllers[param.name] = TextEditingController();

                            switch (param.types) {
                              case ComponentsParametersTypes.COLOR_FIELD:
                                controllers[param.name]!.text =
                                    param.value ?? "255,255,255";
                                return ColorField(
                                  height: 100,
                                  width: widget.width,
                                  label: param.name,
                                  controller: controllers[param.name]
                                      as TextEditingController,
                                );
                              case ComponentsParametersTypes.INT_FIELD:
                                controllers[param.name]!.text =
                                    param.value ?? "0";
                                return IntField(
                                  height: 100,
                                  width: widget.width,
                                  label: param.name,
                                  controller: controllers[param.name]
                                      as TextEditingController,
                                );
                              case ComponentsParametersTypes.STRING_FIELD:
                                controllers[param.name]!.text =
                                    param.value ?? "";
                                return StrField(
                                  height: 100,
                                  width: widget.width,
                                  label: param.name,
                                  controller: controllers[param.name]
                                      as TextEditingController,
                                );
                              case ComponentsParametersTypes.FILE_FIELD:
                                controllers[param.name]!.text =
                                    param.value ?? "";
                                return FileField(
                                  height: 100,
                                  width: widget.width,
                                  label: param.name,
                                  controller: controllers[param.name]
                                      as TextEditingController,
                                  allowedExtensions:
                                      param.option["allowed_extensions"] ??
                                          ["*."],
                                  allowMultiple:
                                      param.option['allow_multiple'] ?? false,
                                );
                              case ComponentsParametersTypes.FOLDER_FIELD:
                                controllers[param.name]!.text =
                                    param.value ?? "";
                                return FolderField(
                                  height: 100,
                                  width: widget.width,
                                  label: param.name,
                                  controller: controllers[param.name]
                                      as TextEditingController,
                                );
                              case ComponentsParametersTypes.DROPDOWN:
                                return DropDown(
                                  height: 40,
                                  width: widget.width,
                                  items: param.option.map<ComboItem>(
                                    (opt) {
                                      return ComboItem(opt, opt);
                                    },
                                  ).toList(),
                                  controller: controllers[param.name]
                                      as TextEditingController,
                                );
                              case ComponentsParametersTypes.FLOAT_FIELD:
                                controllers[param.name]!.text =
                                    param.value ?? "0.0";
                                return FloatField(
                                  height: 100,
                                  width: widget.width,
                                  label: param.name,
                                  controller: controllers[param.name]
                                      as TextEditingController,
                                );
                            }
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
