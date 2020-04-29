class Location {
  final double lat;
  final double lng;

  Location({this.lng, this.lat});

  Location.fromJson(Map<dynamic, dynamic> parsedJson)
      : lat = parsedJson['lat'],
        lng = parsedJson['lng'];
}
