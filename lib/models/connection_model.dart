/// The `Connection` class represents a connection between nodes with specific IDs and port IDs, and
/// provides methods for JSON serialization and deserialization.
class Connection {
  final int fromNodeId;
  final int fromPortId;
  final int toNodeId;
  final int toPortId;
  final int id;

  Connection({
    required this.fromNodeId,
    required this.fromPortId,
    required this.toNodeId,
    required this.toPortId,
    required this.id,
  });

  /// This function converts an object's properties into a map with string keys and dynamic values.
  Map<String, dynamic> toJson() => {
        'id': id,
        'fromNodeId': fromNodeId,
        'fromPortId': fromPortId,
        'toNodeId': toNodeId,
        'toPortId': toPortId,
      };

  /// This Dart factory method creates a Connection object from a JSON map.
  /// 
  /// Args:
  ///   json (Map<String, dynamic>): The `json` parameter in the `Connection.fromJson` factory method is
  /// a map that contains key-value pairs representing the properties of a `Connection` object. The keys
  /// in the map correspond to the properties of the `Connection` class (id, fromNodeId, fromPortId,
  /// toNodeId, to
  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json['id'],
        fromNodeId: json['fromNodeId'],
        fromPortId: json['fromPortId'],
        toNodeId: json['toNodeId'],
        toPortId: json['toPortId'],
      );
}