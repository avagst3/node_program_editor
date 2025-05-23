class IoDataTemplate {
  final String type;
  final bool isMandatory;
  final String name;

  IoDataTemplate(this.name, this.type, this.isMandatory);

  Map<String, dynamic> toJson() => {
        "type": this.type,
        "is_mandatory": this.isMandatory,
        "name": this.name,
      };
}
