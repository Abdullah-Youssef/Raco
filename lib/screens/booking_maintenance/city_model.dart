class City {
  int id;
  String name;
  List<Alhayi> alhayi_names;

  City({required this.id, required this.name, required this.alhayi_names});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      alhayi_names: List<Alhayi>.from(
          json['alhayi_names'].map((x) => Alhayi.fromJson(x))),
    );
  }
}

class Alhayi {
  int id;
  String name;

  Alhayi({required this.id, required this.name});

  factory Alhayi.fromJson(Map<String, dynamic> json) {
    return Alhayi(
      id: json['id'],
      name: json['name'],
    );
  }
}
