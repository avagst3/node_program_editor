import 'package:flutter/material.dart';

/// The DeleteNodeIntent class is a Dart class that represents an intent to delete a node.
class DeleteNodeIntent extends Intent {
  /// The `const DeleteNodeIntent();` statement is creating an instance of the `DeleteNodeIntent` class
  /// using a const constructor. This means that the instance of `DeleteNodeIntent` is a compile-time
  /// constant.
  const DeleteNodeIntent();
}

/// The `CopyNodeIntent` class is a Dart class that represents an intent to copy a node.
class CopyNodeIntent extends Intent {
  /// The `const CopyNodeIntent();` statement is creating an instance of the `CopyNodeIntent` class
  /// using a const constructor. This means that the instance of `CopyNodeIntent` is a compile-time
  /// constant, which can help with performance optimizations and memory efficiency.
  const CopyNodeIntent();
}

/// The `PasteNodeIntent` class is a Dart class that represents an intent to paste a node.
class PasteNodeIntent extends Intent {
  /// The `const PasteNodeIntent();` statement is creating an instance of the `PasteNodeIntent` class
  /// using a const constructor. This means that the instance of `PasteNodeIntent` is a compile-time
  /// constant, which can help with performance optimizations and memory efficiency. By using `const`,
  /// Dart ensures that only one instance of `PasteNodeIntent` is created and reused whenever needed,
  /// rather than creating a new instance every time it is referenced. This can be beneficial in terms
  /// of reducing memory usage and improving performance in your Dart code.
  const PasteNodeIntent();
}
