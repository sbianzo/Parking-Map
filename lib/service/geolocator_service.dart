import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  final geolocator = Geolocator();

  Future<Position> getLocation() async {
    return await geolocator.getCurrentPosition();
  }

  Future<double> getDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    return await geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }
}
