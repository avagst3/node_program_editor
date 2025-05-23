import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../policy/builder_set_policy.dart';
import '../../providers/builder_style.dart';
import '../../providers/text_provider.dart';
import '../parameters_fields/color_picker_dialog.dart';

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
    context.watch<BuilderStyle>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Consumer<TextProvider>(
            builder: (context, textProvider, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${textProvider.text.entryTypesSettingsCoLors} :",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
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
                                var pickedColor = showPickColorDialog(
                                  context,
                                  entry.color,
                                  Provider.of<TextProvider>(context,
                                      listen: false),
                                );
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
