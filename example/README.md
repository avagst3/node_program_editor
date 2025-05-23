# example

```dart
import 'package:flutter/material.dart';
import 'package:node_program_editor/node_program_editor.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: NodeProgramEditor(
          data: DiagramData(
            [EntryTypesData("INT", Colors.black)],
            [
              BlockTemplate(
                "Image",
                Colors.white,
                "image",
                [
                  ComponentParameter(
                    "IO",
                    ComponentsParametersTypes.STRING_FIELD,
                    null,
                  )
                ],
                [IoDataTemplate("a", "INT", false)],
                [
                  IoDataTemplate("b", "INT", false),
                ],
              )
            ],
          ),
          onProgramEmitted: (data) {
            print(data);
          },
        ),
      ),
    );
  }
}

```