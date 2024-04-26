class ModelCode {
  int id;
  String code;

  ModelCode({required this.id, required this.code});

  factory ModelCode.fromJson(Map<String, dynamic> json) {
    return ModelCode(
      id: json['id'],
      code: json['code'],
    );
  }
}
