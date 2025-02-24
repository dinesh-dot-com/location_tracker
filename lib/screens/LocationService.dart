import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static Future<void> startLocationUpdates() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> locations = prefs.getStringList("locations") ?? [];

    String newLocation =
        "Lat: ${position.latitude}, Lng: ${position.longitude}";
    locations.add(newLocation);

    await prefs.setStringList("locations", locations);
  }
}
