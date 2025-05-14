import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

class ApiService {
  static const String apiUrl =
      "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&limit=10";

  static Future<List<Earthquake>> fetchEarthquakes() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List features = data["features"];
      return features.map((e) => Earthquake.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load earthquake data");
    }
  }
}
