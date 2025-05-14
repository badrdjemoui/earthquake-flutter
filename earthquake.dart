class Earthquake {
  final String place;
  final double magnitude;
  final int time;

  Earthquake({required this.place, required this.magnitude, required this.time});

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    return Earthquake(
      place: json["properties"]["place"],
      magnitude: json["properties"]["mag"].toDouble(),
      time: json["properties"]["time"],
    );
  }
}
