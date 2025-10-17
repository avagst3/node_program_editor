import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../actions.dart';
import '../core/painter.dart';
import '../models/connection_model.dart';
import '../models/node_data_model.dart';
import '../models/node_models.dart';
import '../models/selected_port_info_model.dart';
import '../models/temp_link_model.dart';
import '../core/controller.dart';
import '../widgets/node.dart';

///
class EditorCanvas extends StatefulWidget {
  ///
  final EditorController controller;

  ///
  EditorCanvas({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _EditorCanvasState createState() => _EditorCanvasState(controller);
}

class _EditorCanvasState extends State<EditorCanvas> {
  _EditorCanvasState(EditorController controller) {
    controller.loadFromJson = loadCanvasFromJson;
    controller.saveToJson = saveCanvasToJson;
  }

  Offset offset = Offset.zero;
  double scale = 1.0;
  List<Node> nodes = [];
  List<Connection> connections = [];

  int? selectedNodeIndex;
  int? selectedConnectionId;
  TempLink? tempLink;
  bool _isLinkingMode = false;
  SelectedPortInfo? _selectedPortForLinking;

  final focusNode = FocusNode();
  Node? copiedNode;

  /// The function `saveCanvasToJson` converts canvas data into a JSON format with specified structure.
  ///
  /// Returns:
  ///   A JSON representation of the canvas data is being returned.
  String saveCanvasToJson() {
    final data = {
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'scale': scale,
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'connections': connections.map((c) => c.toJson()).toList(),
    };
    final jsonData = JsonEncoder.withIndent('  ').convert(data);
    return jsonData;
  }

  /// The function `loadCanvasFromJson` parses a JSON string to update the state of a canvas with
  /// offset, scale, nodes, and connections.
  ///
  /// Args:
  ///   jsonString (String): The `loadCanvasFromJson` function takes a `String` parameter `jsonString`,
  /// which is expected to contain JSON data representing the state of a canvas. The function then
  /// parses this JSON data to update the canvas state with the information provided in the JSON string.
  /// If the JSON string is empty,
  ///
  /// Returns:
  ///   If the `jsonString` parameter is empty, the function `loadCanvasFromJson` will return early and
  /// not execute the rest of the code block.
  void loadCanvasFromJson(String jsonString) {
    if (jsonString.isEmpty) return;
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    _updateStateAndSave(() {
      offset =
          Offset((data['offset'] as Map)['dx'], (data['offset'] as Map)['dy']);
      scale = data['scale'];
      nodes = (data['nodes'] as List)
          .map((nodeJson) => Node.fromJson(nodeJson as Map<String, dynamic>))
          .toList();
      connections = (data['connections'] as List)
          .map((connJson) =>
              Connection.fromJson(connJson as Map<String, dynamic>))
          .toList();
      selectedNodeIndex = null;
      selectedConnectionId = null;
    });
  }

  /// The function `_updateStateAndSave` updates the state and saves it by calling the provided
  /// `updateCallback` function.
  ///
  /// Args:
  ///   updateCallback (VoidCallback): The `updateCallback` parameter is a function that will be called
  /// to update the state in the `_updateStateAndSave` function.
  void _updateStateAndSave(VoidCallback updateCallback) {
    setState(updateCallback);
  }

  /// The function `_getNodeById` returns a `Node` object with a specific ID or null if not found.
  ///
  /// Args:
  ///   id (int): The `id` parameter is an integer value used to identify a specific node in the
  /// collection of nodes. The `_getNodeById` function attempts to find and return a node with the
  /// matching `id` from the list of nodes. If no node with the specified `id` is found, it returns
  ///
  /// Returns:
  ///   The function is attempting to find and return a Node object from a list of nodes based on the
  /// provided id. If a Node with the specified id is found in the list, it will be returned. If no Node
  /// with that id is found or an error occurs during the search, the function will return null.
  Node? _getNodeById(int id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  /// The `addNodeAt` function creates a new Node object at a specified global position on a canvas.
  ///
  /// Args:
  ///   globalPosition (Offset): The `globalPosition` parameter represents the position of the node in
  /// global coordinates. It is used to calculate the local position of the node on the canvas by
  /// subtracting the offset and dividing by the scale.
  ///   data (NodeData): The `data` parameter in the `addNodeAt` function represents the data associated
  /// with the node being added. This data typically includes information such as the input ports,
  /// output ports, and any other relevant properties of the node.
  ///
  /// Returns:
  ///   The `addNodeAt` function returns a new `Node` object with the specified `position`, `data`,
  /// `id`, `inputs`, and `outputs`.
  Node addNodeAt(Offset globalPosition, NodeData data) {
    final localCanvasPosition = (globalPosition - offset) / scale;
    return Node(
      position: localCanvasPosition,
      data: data,
      id: nodes.isEmpty ? 1 : nodes.map((n) => n.id).reduce(max) + 1,
      inputs: data.inputPorts,
      outputs: data.outputPorts,
    );
  }

  /// This Dart function counts the number of connections for a specific port based on the node ID, port
  /// ID, and whether it is an output port.
  ///
  /// Args:
  ///   nodeId (int): The `nodeId` parameter represents the identifier of a node in a system.
  ///   portId (int): The `portId` parameter represents the identifier of the port for which you want to
  /// count the connections.
  ///   isOutput (bool): The `isOutput` parameter is a boolean flag that indicates whether we are
  /// checking for output connections (`true`) or input connections (`false`).
  ///
  /// Returns:
  ///   The function `_countConnectionsForPort` returns the count of connections for a specific node ID
  /// and port ID, based on whether it is an output connection or not.
  int _countConnectionsForPort(int nodeId, int portId, bool isOutput) {
    int count = 0;
    for (final connection in connections) {
      if (isOutput) {
        if (connection.fromNodeId == nodeId &&
            connection.fromPortId == portId) {
          count++;
        }
      } else {
        if (connection.toNodeId == nodeId && connection.toPortId == portId) {
          count++;
        }
      }
    }
    return count;
  }

  /// This function handles the start of a port pan operation by updating the state and setting up
  /// temporary link information.
  ///
  /// Args:
  ///   nodeIndex (int): The `nodeIndex` parameter represents the index of the node in a list or array.
  /// It is used to identify a specific node within a collection of nodes.
  ///   portIndex (int): The `portIndex` parameter represents the index of the port within a node. It is
  /// used to identify a specific port within a node when handling port-related actions or events.
  ///   isOutput (bool): The `isOutput` parameter in the `_handlePortPanStart` function is a boolean
  /// value that indicates whether the port being interacted with is an output port or not. It is used
  /// to determine the direction of the port (input or output) during the drag operation.
  ///   details (DragStartDetails): The `details` parameter in the `_handlePortPanStart` function is of
  /// type `DragStartDetails`. This parameter likely contains information about the starting position of
  /// a drag operation, such as the global position where the drag started and any additional details
  /// related to the drag gesture.
  void _handlePortPanStart(
      int nodeIndex, int portIndex, bool isOutput, DragStartDetails details) {
    final portPos = nodes[nodeIndex].getPortCenterAbsolute(portIndex, isOutput);
    _updateStateAndSave(() {
      _isLinkingMode = true;
      _selectedPortForLinking = SelectedPortInfo(
          nodeIndex: nodeIndex, portIndex: portIndex, isOutput: isOutput);
      tempLink = TempLink(
          nodeIndex: nodeIndex,
          portIndex: portIndex,
          isOutput: isOutput,
          currentDragPosition: portPos);
      selectedNodeIndex = null;
      selectedConnectionId = null;
    });
  }

  /// The `_handlePortPanUpdate` function updates the current drag position if linking mode is active.
  ///
  /// Args:
  ///   details (DragUpdateDetails): The `details` parameter is of type `DragUpdateDetails`, which
  /// contains information about the ongoing drag gesture, such as the position and delta of the drag.
  void _handlePortPanUpdate(DragUpdateDetails details) {
    if (_isLinkingMode) {
      _updateStateAndSave(
          () => tempLink!.currentDragPosition += details.delta / scale);
    }
  }

  /// The `_handlePortPanEnd` function in Dart handles creating connections between nodes based on drag
  /// end details.
  ///
  /// Args:
  ///   details (DragEndDetails): The `_handlePortPanEnd` function you provided is responsible for
  /// handling the end of a drag operation on a port. The `details` parameter of type `DragEndDetails`
  /// contains information about the drag gesture that has ended, such as the velocity at which the drag
  /// was moving when it stopped.
  ///
  /// Returns:
  ///   If `_isLinkingMode` is false, the function will return early and nothing will be executed.
  void _handlePortPanEnd(DragEndDetails details) {
    if (!_isLinkingMode) return;

    final from = tempLink!;
    final fromNode = nodes[from.nodeIndex];
    final dragPos = from.currentDragPosition;
    bool linkCreated = false;

    for (int i = 0; i < nodes.length; i++) {
      if (i == from.nodeIndex) continue;

      final targetNode = nodes[i];
      final bool isTargetAnInput = from.isOutput;
      final targetPorts =
          isTargetAnInput ? targetNode.inputPorts : targetNode.outputPorts;

      for (int j = 0; j < targetPorts.length; j++) {
        final portLogicalPosition =
            targetNode.getPortCenterAbsolute(j, !isTargetAnInput);

        if ((portLogicalPosition - dragPos).distance <= 20 * scale) {
          final targetPort = targetPorts[j];
          final currentLinks = _countConnectionsForPort(
              targetNode.id, targetPort.id, !isTargetAnInput);

          if (targetPort.maxLinks != -1 &&
              currentLinks >= targetPort.maxLinks) {
            continue;
          }

          final fromPort = from.isOutput
              ? fromNode.outputPorts[from.portIndex]
              : fromNode.inputPorts[from.portIndex];

          _updateStateAndSave(() {
            connections.add(Connection(
              fromNodeId: from.isOutput ? fromNode.id : targetNode.id,
              fromPortId: from.isOutput ? fromPort.id : targetPort.id,
              toNodeId: from.isOutput ? targetNode.id : fromNode.id,
              toPortId: from.isOutput ? targetPort.id : fromPort.id,
              id: connections.isEmpty
                  ? 1
                  : connections.map((c) => c.id).reduce(max) + 1,
            ));
            linkCreated = true;
          });
          break;
        }
      }
      if (linkCreated) break;
    }

    _updateStateAndSave(() {
      tempLink = null;
      _isLinkingMode = false;
      _selectedPortForLinking = null;
    });
  }

  void _onCanvasPanUpdate(DragUpdateDetails details) {
    if (selectedNodeIndex != null) {
      _updateStateAndSave(
          () => nodes[selectedNodeIndex!].position += details.delta / scale);
    } else {
      _updateStateAndSave(() => offset += details.delta);
    }
  }

  /// The `_getBezierPoint` function calculates a point on a cubic Bezier curve given control points and
  /// a parameter `t`.
  ///
  /// Args:
  ///   p1 (Offset): p1 is the starting point of the Bezier curve.
  ///   c1 (Offset): The parameter `c1` represents the first control point of the Bezier curve. It is a
  /// point that influences the shape of the curve between the start point `p1` and the next control
  /// point `c2`.
  ///   c2 (Offset): The parameter `c2` in the `_getBezierPoint` function represents the second control
  /// point of a cubic Bezier curve. In a cubic Bezier curve, there are four points involved: the start
  /// point `p1`, the first control point `c1`, the second control point `c
  ///   p2 (Offset): The `p2` parameter in the `_getBezierPoint` function represents the end point of
  /// the Bezier curve. It is the final destination point towards which the curve is being drawn.
  ///   t (double): The parameter `t` in the `_getBezierPoint` function represents the position along
  /// the Bezier curve. It is a value between 0 and 1 where 0 corresponds to the starting point of the
  /// curve and 1 corresponds to the ending point of the curve. Values between 0 and
  ///
  /// Returns:
  ///   The `_getBezierPoint` function returns an `Offset` object that represents a point on a Bezier
  /// curve calculated based on the input control points `p1`, `c1`, `c2`, `p2`, and the parameter `t`.
  Offset _getBezierPoint(Offset p1, Offset c1, Offset c2, Offset p2, double t) {
    final double mt = 1 - t;
    return Offset(
      pow(mt, 3) * p1.dx +
          3 * pow(mt, 2) * t * c1.dx +
          3 * mt * pow(t, 2) * c2.dx +
          pow(t, 3) * p2.dx,
      pow(mt, 3) * p1.dy +
          3 * pow(mt, 2) * t * c1.dy +
          3 * mt * pow(t, 2) * c2.dy +
          pow(t, 3) * p2.dy,
    );
  }

  /// The function `_hitTestConnections` checks if a tap position is within a certain distance of a
  /// bezier curve connecting two nodes in a canvas.
  ///
  /// Args:
  ///   tapPositionLocalToCanvas (Offset): `Offset` representing the position of a tap event relative to
  /// the canvas.
  ///
  /// Returns:
  ///   The function `_hitTestConnections` is returning an `int` value, which is the `id` of the link
  /// that is being hit by the tap position within the hit tolerance range. If no link is hit within the
  /// tolerance, it returns `null`.
  int? _hitTestConnections(Offset tapPositionLocalToCanvas) {
    const double hitTolerance = 20.0;
    for (var link in connections) {
      final fromNode = _getNodeById(link.fromNodeId);
      final toNode = _getNodeById(link.toNodeId);
      if (fromNode == null || toNode == null) continue;

      final fromPortIndex =
          fromNode.outputPorts.indexWhere((p) => p.id == link.fromPortId);
      final toPortIndex =
          toNode.inputPorts.indexWhere((p) => p.id == link.toPortId);
      if (fromPortIndex == -1 || toPortIndex == -1) continue;

      final p1 = fromNode.getPortCenterAbsolute(fromPortIndex, true);
      final p2 = toNode.getPortCenterAbsolute(toPortIndex, false);

      final c1 = Offset(p1.dx + 100, p1.dy);
      final c2 = Offset(p2.dx - 100, p2.dy);

      for (int i = 0; i <= 10; i++) {
        final t = i / 10;
        final pointOnCurve = _getBezierPoint(p1, c1, c2, p2, t);
        if ((pointOnCurve - tapPositionLocalToCanvas).distance <=
            hitTolerance / scale) {
          return link.id;
        }
      }
    }
    return null;
  }

  /// The `_handleCanvasClick` function in Dart handles canvas click events by updating the state based
  /// on the click position and interactions with nodes and connections.
  ///
  /// Args:
  ///   clickPosition (Offset): The `clickPosition` parameter represents the position where the user
  /// clicked on the canvas. This position is typically provided as an `Offset` object, which contains
  /// the x and y coordinates of the click relative to the canvas. The `_handleCanvasClick` function
  /// processes this click position to determine the action to
  ///
  /// Returns:
  ///   If the `_isLinkingMode` is true, the function will return early after updating the state and
  /// saving it. Otherwise, it will check if there is a hit on any connection in the canvas. If a
  /// connection is hit, the function will update the selected connection ID and clear the selected node
  /// index before returning. If no connection is hit, the function will iterate through the nodes to
  /// find the
  void _handleCanvasClick(Offset clickPosition) {
    if (_isLinkingMode) {
      _updateStateAndSave(() {
        tempLink = null;
        _isLinkingMode = false;
        _selectedPortForLinking = null;
      });
      return;
    }
    final canvasPos = (clickPosition - offset) / scale;
    final hitLinkId = _hitTestConnections(canvasPos);
    if (hitLinkId != null) {
      _updateStateAndSave(() {
        selectedConnectionId = hitLinkId;
        selectedNodeIndex = null;
      });
      return;
    }
    int? newSelectedNodeIndex;
    for (int i = nodes.length - 1; i >= 0; i--) {
      if ((nodes[i].position & nodes[i].size).contains(canvasPos)) {
        newSelectedNodeIndex = i;
        break;
      }
    }
    _updateStateAndSave(() {
      selectedNodeIndex = newSelectedNodeIndex;
      selectedConnectionId = null;
    });
  }

  void _deleteNode() {
    if (_isLinkingMode || selectedNodeIndex == null) return;
    _updateStateAndSave(() {
      final nodeToDeleteId = nodes[selectedNodeIndex!].id;
      nodes.removeAt(selectedNodeIndex!);
      connections.removeWhere((link) =>
          link.fromNodeId == nodeToDeleteId || link.toNodeId == nodeToDeleteId);
      selectedNodeIndex = null;
      selectedConnectionId = null;
    });
  }

  /// The `_deleteConnection` function removes a connection from a list if it is not in linking mode and
  /// a connection ID is selected.
  ///
  /// Returns:
  ///   If `_isLinkingMode` is true or `selectedConnectionId` is null, the function will return early
  /// and nothing will be deleted.
  void _deleteConnection() {
    if (_isLinkingMode || selectedConnectionId == null) return;
    _updateStateAndSave(() {
      connections.removeWhere((link) => link.id == selectedConnectionId);
      selectedConnectionId = null;
    });
  }

  /// The `_copyNode` function creates a copy of a selected node with updated ID and copies of input and
  /// output ports.
  ///
  /// Returns:
  ///   If `_isLinkingMode` is true or `selectedNodeIndex` is null, the function will return early and
  /// nothing will be copied.
  void _copyNode() {
    if (_isLinkingMode || selectedNodeIndex == null) return;
    final original = nodes[selectedNodeIndex!];
    copiedNode = Node(
      data: original.data,
      position: original.position,
      size: original.size,
      id: -1,
      inputs: original.inputPorts.map((p) => p.copyWith()).toList(),
      outputs: original.outputPorts.map((p) => p.copyWith()).toList(),
    );
  }

  /// The `_pasteNode` function creates a new node by copying the properties of a previously copied node
  /// and adds it to a list of nodes.
  ///
  /// Returns:
  ///   If `_isLinkingMode` is true or `copiedNode` is null, the function will return early without
  /// executing the rest of the code block.
  void _pasteNode() {
    if (_isLinkingMode || copiedNode == null) return;
    _updateStateAndSave(() {
      final newNode = Node(
        position: copiedNode!.position + Offset(20, 20),
        data: copiedNode!.data,
        size: copiedNode!.size,
        id: nodes.isEmpty ? 1 : nodes.map((n) => n.id).reduce(max) + 1,
        inputs: copiedNode!.inputPorts.map((p) => p.copyWith()).toList(),
        outputs: copiedNode!.outputPorts.map((p) => p.copyWith()).toList(),
      );
      nodes.add(newNode);
      selectedNodeIndex = nodes.length - 1;
      selectedConnectionId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DragTarget<NodeData>(
        onAcceptWithDetails: (details) {
          if (_isLinkingMode) return;
          _updateStateAndSave(() {
            nodes.add(addNodeAt(details.offset, details.data));
            selectedNodeIndex = nodes.length - 1;
          });
        },
        builder: (context, _, __) => Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.delete): const DeleteNodeIntent(),
            LogicalKeySet(LogicalKeyboardKey.backspace):
                const DeleteNodeIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
                const CopyNodeIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
                const PasteNodeIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              DeleteNodeIntent: CallbackAction<DeleteNodeIntent>(onInvoke: (_) {
                if (selectedNodeIndex != null) {
                  _deleteNode();
                } else if (selectedConnectionId != null) {
                  _deleteConnection();
                }

                return null;
              }),
              CopyNodeIntent:
                  CallbackAction<CopyNodeIntent>(onInvoke: (_) => _copyNode()),
              PasteNodeIntent:
                  CallbackAction<PasteNodeIntent>(onInvoke: (_) => _pasteNode())
            },
            child: Focus(
              autofocus: true,
              focusNode: focusNode,
              child: Listener(
                onPointerSignal: (event) {
                  if (_isLinkingMode) return;
                  if (event is PointerScrollEvent) {
                    final zoomAmount = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
                    _updateStateAndSave(
                        () => scale = (scale * zoomAmount).clamp(0.1, 5.0));
                  }
                },
                child: GestureDetector(
                  onPanUpdate: _onCanvasPanUpdate,
                  onTapUp: (details) =>
                      _handleCanvasClick(details.localPosition),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: EditorPainter(
                            offset,
                            scale,
                            nodes,
                            connections,
                            tempLink,
                            selectedNodeIndex,
                            selectedConnectionId),
                      ),
                      ...nodes.asMap().entries.map((entry) {
                        int index = entry.key;
                        Node node = entry.value;
                        return Positioned(
                          left: node.position.dx * scale + offset.dx,
                          top: node.position.dy * scale + offset.dy,
                          child: NodeWidget(
                            node: node,
                            nodeIndex: index,
                            isSelected: selectedNodeIndex == index,
                            scale: scale,
                            onTap: () {
                              if (_isLinkingMode) return;
                              _updateStateAndSave(() {
                                selectedNodeIndex = index;
                                selectedConnectionId = null;
                              });
                            },
                            onPortPanStart: (portIndex, isOutput, details) =>
                                _handlePortPanStart(
                                    index, portIndex, isOutput, details),
                            onPortPanUpdate: _handlePortPanUpdate,
                            onPortPanEnd: _handlePortPanEnd,
                            selectedPortForLinking: _selectedPortForLinking,
                            portColor: node.data.portColor,
                            selectedPortColor: node.data.selectedPortColor,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
