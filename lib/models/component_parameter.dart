

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
}
