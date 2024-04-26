class AgentModel {
  int id;
  String name;
  String address;
  String image;

  AgentModel(
      {required this.id,
      required this.name,
      required this.address,
      required this.image});

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      image: json['image'] ?? "",
    );
  }
}
