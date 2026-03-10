class BranchCity {
  final String? id;
  final String? name;
  final Map<String, dynamic> raw;

  const BranchCity({this.id, this.name, required this.raw});

  factory BranchCity.fromJson(Map<String, dynamic> json) {
    return BranchCity(
      id: (json['id'] ?? json['ID'] ?? json['CityID'] ?? json['city_id'])?.toString(),
      name: (json['name'] ?? json['Name'] ?? json['CityName'] ?? json['city_name'])
          ?.toString(),
      raw: json,
    );
  }
}
