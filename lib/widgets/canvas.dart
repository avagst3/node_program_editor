import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:node_program_editor/widgets/node.dart';

import '../actions.dart';
import '../core/painter.dart';
import '../models/connection_model.dart';
import '../models/node_data_model.dart';
import '../models/node_models.dart';
import '../models/selected_port_info_model.dart';
import '../models/temp_link_model.dart';

class EditorCanvas extends StatefulWidget {
  final void Function(String json)? onSaveRequest;
  final void Function(void Function(String) load)? onLoadRequest;

  EditorCanvas({
    Key? key,
    this.onSaveRequest,
    this.onLoadRequest,
  }) : super(key: key);

  @override
  _EditorCanvasState createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
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

  String saveCanvasToJson() {
    final data = {
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'scale': scale,
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'connections': connections.map((c) => c.toJson()).toList(),
    };
    return JsonEncoder.withIndent('  ').convert(data);
  }

  void loadCanvasFromJson(String jsonString) {
    if (jsonString.isEmpty) return;
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      _updateStateAndSave(() {
        offset = Offset((data['offset'] as Map)['dx'] as double,
            (data['offset'] as Map)['dy'] as double);
        scale = data['scale'] as double;
        nodes = (data['nodes'] as List)
            .map((nodeJson) => Node.fromJson(nodeJson as Map<String, dynamic>))
            .toList();
        connections = (data['connections'] as List)
            .map((connJson) => Connection.fromJson(connJson as Map<String, dynamic>))
            .toList();
        selectedNodeIndex = null;
        selectedConnectionId = null;
      });
    } catch (e) {
      print("Erreur lors du chargement du JSON : $e");
    }
  }

  void _updateStateAndSave(VoidCallback updateCallback) {
    setState(updateCallback);
    if (widget.onSaveRequest != null) {
      widget.onSaveRequest!(saveCanvasToJson());
    }
  }

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

  int _countConnectionsForPort(int nodeId, int portId, bool isOutput) {
    int count = 0;
    for (final connection in connections) {
      if (isOutput) {
        if (connection.fromNodeId == nodeId && connection.fromPortId == portId) count++;
      } else {
        if (connection.toNodeId == nodeId && connection.toPortId == portId) count++;
      }
    }
    return count;
  }

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

  void _handlePortPanUpdate(DragUpdateDetails details) {
    if (_isLinkingMode) {
      _updateStateAndSave(() => tempLink!.currentDragPosition += details.delta / scale);
    }
  }

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

        if ((portLogicalPosition - dragPos).distance <= 20 / scale) {
          final targetPort = targetPorts[j];
          final currentLinks = _countConnectionsForPort(
              targetNode.id, targetPort.id, !isTargetAnInput);

          if (targetPort.maxLinks != -1 && currentLinks >= targetPort.maxLinks)
            continue;

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
            hitTolerance / scale) return link.id;
      }
    }
    return null;
  }

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

  void _deleteConnection() {
    if (_isLinkingMode || selectedConnectionId == null) return;
    _updateStateAndSave(() {
      connections.removeWhere((link) => link.id == selectedConnectionId);
      selectedConnectionId = null;
    });
  }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onLoadRequest != null) {
        widget.onLoadRequest!(loadCanvasFromJson);
      }
    });
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
            LogicalKeySet(LogicalKeyboardKey.backspace): const DeleteNodeIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
                const CopyNodeIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
                const PasteNodeIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              DeleteNodeIntent: CallbackAction<DeleteNodeIntent>(onInvoke: (_) {
                if (selectedNodeIndex != null)
                  _deleteNode();
                else if (selectedConnectionId != null) _deleteConnection();
                return null;
              }),
              CopyNodeIntent: CallbackAction<CopyNodeIntent>(onInvoke: (_) => _copyNode()),
              PasteNodeIntent: CallbackAction<PasteNodeIntent>(onInvoke: (_) => _pasteNode())
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
                  onTapUp: (details) => _handleCanvasClick(details.localPosition),
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
