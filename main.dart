import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/earthquake.dart';

void main() {
  runApp(EarthquakeApp());
}

class EarthquakeApp extends StatelessWidget {
  const EarthquakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EarthquakeScreen(),
    );
  }
}

class EarthquakeScreen extends StatefulWidget {
  const EarthquakeScreen({super.key});

  @override
  _EarthquakeScreenState createState() => _EarthquakeScreenState();
}

class _EarthquakeScreenState extends State<EarthquakeScreen> {
  late Future<List<Earthquake>> futureEarthquakes;

  @override
  void initState() {
    super.initState();
    futureEarthquakes = ApiService.fetchEarthquakes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recent Earthquakes")),
      body: FutureBuilder<List<Earthquake>>(
        future: futureEarthquakes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No earthquakes found."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final earthquake = snapshot.data![index];
                return ListTile(
                  title: Text(earthquake.place),
                  subtitle: Text("Magnitude: ${earthquake.magnitude}"),
                  trailing: Text(
                    DateTime.fromMillisecondsSinceEpoch(earthquake.time)
                        .toString(),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
