import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider_prove/model/place.dart';
import 'package:provider_prove/service/geolocator_service.dart';
import 'package:provider_prove/service/marker_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Search extends StatelessWidget {
  void _launchMapUrl(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = Provider.of<Position>(context);
    final placesProvider = Provider.of<Future<List<Place>>>(context);
    final geoService = GeolocatorService();
    final markerService = MarkerService();

    return FutureProvider(
      create: (context) => placesProvider,
      child: SafeArea(
        child: Scaffold(
          body: (currentPosition != null)
              ? Consumer<List<Place>>(
                  builder: (_, places, __) {
                    var markers = (places != null)
                        ? markerService.getMarker(places)
                        : List<Marker>();
                    return (places != null)
                        ? Column(
                            children: <Widget>[
                              Container(
                                height:
                                    MediaQuery.of(context).size.height / 1.7,
                                width: MediaQuery.of(context).size.width,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                      target: LatLng(currentPosition.latitude,
                                          currentPosition.longitude),
                                      zoom: 16.0),
                                  zoomGesturesEnabled: true,
                                  markers: Set<Marker>.of(markers),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: places.length,
                                    itemBuilder: (context, index) {
                                      return FutureProvider(
                                        create: (context) =>
                                            geoService.getDistance(
                                                currentPosition.latitude,
                                                currentPosition.longitude,
                                                places[index]
                                                    .geometry
                                                    .location
                                                    .lat,
                                                places[index]
                                                    .geometry
                                                    .location
                                                    .lng),
                                        child: Card(
                                          child: ListTile(
                                            title: Text(places[index].name),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 4),
                                                (places[index].rating != null)
                                                    ? Row(
                                                        children: <Widget>[
                                                          RatingBarIndicator(
                                                            rating:
                                                                places[index]
                                                                    .rating,
                                                            itemBuilder:
                                                                (context,
                                                                        index) =>
                                                                    Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.yellow,
                                                            ),
                                                            itemCount: 5,
                                                            itemSize: 10,
                                                            direction:
                                                                Axis.horizontal,
                                                          )
                                                        ],
                                                      )
                                                    : Row(),
                                                SizedBox(height: 10),
                                                Consumer<double>(
                                                  builder: (context, meters,
                                                      widget) {
                                                    return (meters != null)
                                                        ? Text(
                                                            '${places[index].vicinity} \u00b7 $meters')
                                                        : Container();
                                                  },
                                                )
                                              ],
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(Icons.directions),
                                              color: Colors.blueAccent,
                                              onPressed: () {
                                                _launchMapUrl(
                                                    places[index]
                                                        .geometry
                                                        .location
                                                        .lat,
                                                    places[index]
                                                        .geometry
                                                        .location
                                                        .lng);
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            ],
                          )
                        : Center(child: CircularProgressIndicator());
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
