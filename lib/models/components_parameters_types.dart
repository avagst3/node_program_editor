enum ComponentsParametersTypes {
  INT_FIELD,
  STRING_FIELD,
  FILE_FIELD,
  FOLDER_FIELD,
  DROPDOWN,
  FLOAT_FIELD,
  COLOR_FIELD;
  String toJson() => name;
  static ComponentsParametersTypes fromJson(String json) => values.byName(json);
}
