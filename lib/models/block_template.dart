import 'package:flutter/material.dart';

import 'component_parameter.dart';
import 'io__data_template.dart';

class BlockTemplate {
  final String name;
  final Color color;
  final List<ComponentParameter> parameters;
  final String type;
  final List<IoDataTemplate> inputData;
  final List<IoDataTemplate> outputData;

  BlockTemplate(
    this.name,
    this.color,
    this.type,
    this.parameters,
    this.inputData,
    this.outputData,
  );
}
