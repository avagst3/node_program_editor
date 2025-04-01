import 'components_parameters_types.dart';

class ComponentParameter {
  final String _name;
  final ComponentsParametersTypes _type;
  final dynamic _option;
  dynamic value;
  String get name => _name;
  dynamic get option => _option;

  ComponentsParametersTypes get types => _type;

  ComponentParameter(this._name, this._type, this._option) {
    if (_option is List) {
      value = _option.first;
    }
  }

  void updateValue(dynamic newValue) {
    value = newValue;
  }

  Map<String, dynamic> toJson() => {
        "name": _name,
        "value": value,
        "option": _option,
        "type": _type.toJson(),
      };

  ComponentParameter.fromJson(
    Map<String, dynamic> json,
  )   : _name = json["name"],
        value = json["value"],
        _option = json["option"],
        _type = ComponentsParametersTypes.fromJson(json["type"]);
}
