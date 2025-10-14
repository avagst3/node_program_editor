import 'package:flutter/material.dart';

class NodeData {
  final Color portColor;
  final Color selectedPortColor;
  final Widget nodeBody; // ⚠️ Cannot be serialized directly!

  NodeData(this.portColor, this.selectedPortColor, this.nodeBody);

  /// Converts the NodeData object to a JSON-compatible Map.
  ///
  /// Note: The 'nodeBody' Widget is serialized as a placeholder
  /// (e.g., its type or an ID) since Widgets cannot be saved directly to JSON.
  Map<String, dynamic> toJson() => {
        'portColor': portColor.value,
        'selectedPortColor': selectedPortColor.value,
        'nodeBodyType': nodeBody.runtimeType.toString(),
      };

  /// Creates a NodeData object from a JSON Map.
  ///
  /// Note: This factory requires a custom way to handle the deserialization
  /// and recreation of the 'nodeBody' Widget, as it cannot be loaded from JSON.
  factory NodeData.fromJson(Map<String, dynamic> json) {
    // Deserialize colors from their integer value
    final Color portColor = Color(json['portColor'] as int);
    final Color selectedPortColor = Color(json['selectedPortColor'] as int);

    // You MUST provide the logic here to look up or reconstruct the
    // correct Widget based on the saved data (e.g., 'nodeBodyType' or a custom ID).
    // For this example, we use a simple placeholder Widget.
    final Widget reconstructedWidget =
        Text('Placeholder Widget: ${json['nodeBodyType']}'); // ⬅️ Replace this!

    return NodeData(
      portColor,
      selectedPortColor,
      reconstructedWidget,
    );
  }
}
