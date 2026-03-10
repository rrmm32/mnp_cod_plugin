class Location {
  final String? id;
  final String? name;
  final String? city;
  final Map<String, dynamic> raw;

  const Location({this.id, this.name, this.city, required this.raw});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: (json['id'] ?? json['ID'] ?? json['LocationID'])?.toString(),
      name: (json['name'] ?? json['Name'] ?? json['LocationName'])?.toString(),
      city: (json['city'] ?? json['City'] ?? json['CityName'])?.toString(),
      raw: json,
    );
  }
}
