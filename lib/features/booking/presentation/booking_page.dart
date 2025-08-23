import 'package:car_routing_application/features/home/domain/entities/place_details.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({
    super.key,
    required this.pickUpPlaceDetails,
    required this.dropOffPlaceDetails,
  });

  final PlaceDetails pickUpPlaceDetails;
  final PlaceDetails dropOffPlaceDetails;

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  late GoogleMapController mapController;

   late CameraPosition _initialPosition;

  // Origin & destination (A and B)
  late LatLng _origin;
  late LatLng _destination;

  // Polylines for all available routes
  final Set<Polyline> _polylines = {};

  // Route stats
  int _routeCount = 0;
  int? _shortestRouteIndex;
  String? _shortestDistanceText;
  String? _shortestDurationText;

  // 🔑 Set your Google Maps Directions API key here
  final String _googleApiKey = 'AIzaSyA6Y6eG8TICGWA-Skcqc5LL4iETdnqLEI8';

  @override
  void initState() {
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(widget.pickUpPlaceDetails.lat, 77.5946), // Bangalore coordinates
      zoom: 14,
    );
    _origin = LatLng(widget.pickUpPlaceDetails.lat, widget.pickUpPlaceDetails.lng);
    _destination = LatLng(widget.dropOffPlaceDetails.lat, widget.dropOffPlaceDetails.lng);
    _fetchRoutes(); // Fetch alternative routes on init
  }

  Future<void> _fetchRoutes() async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${_origin.latitude},${_origin.longitude}'
        '&destination=${_destination.latitude},${_destination.longitude}'
        '&mode=driving&alternatives=true&key=${_googleApiKey}',
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) return;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? [];
      _renderRoutes(routes);
    } catch (e) {
      // You may want to show a snackbar/toast here in a real app
      debugPrint('Directions error: $e');
    }
  }

  // Decode an encoded polyline string into a list of LatLngs
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return poly;
  }

  void _renderRoutes(List routes) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.cyan,
    ];

    final Set<Polyline> newPolylines = {};

    int? shortestIdx;
    int shortestMeters = 1 << 30;
    String? shortestDistanceText;
    String? shortestDurationText;

    // To compute bounds
    double? minLat, minLng, maxLat, maxLng;

    for (int i = 0; i < routes.length; i++) {
      final r = routes[i] as Map<String, dynamic>;
      final overview = r['overview_polyline']?['points'] as String?;
      if (overview == null) continue;

      final points = _decodePolyline(overview);

      // Track bounds
      for (final p in points) {
        minLat = (minLat == null) ? p.latitude : (p.latitude < minLat! ? p.latitude : minLat);
        minLng = (minLng == null) ? p.longitude : (p.longitude < minLng! ? p.longitude : minLng);
        maxLat = (maxLat == null) ? p.latitude : (p.latitude > maxLat! ? p.latitude : maxLat);
        maxLng = (maxLng == null) ? p.longitude : (p.longitude > maxLng! ? p.longitude : maxLng);
      }

      // Find distance/duration from legs
      int meters = 0;
      String? distText;
      String? durText;
      final legs = (r['legs'] as List?) ?? [];
      for (final leg in legs) {
        final m = (leg['distance']?['value'] as int?) ?? 0;
        meters += m;
        distText = leg['distance']?['text'] as String? ?? distText;
        durText = leg['duration']?['text'] as String? ?? durText;
      }

      if (meters < shortestMeters) {
        shortestMeters = meters;
        shortestIdx = i;
        shortestDistanceText = distText;
        shortestDurationText = durText;
      }

      final color = i < colors.length ? colors[i] : Colors.grey;

      newPolylines.add(
        Polyline(
          polylineId: PolylineId('route_$i'),
          points: points,
          width: 5,
          color: color.withOpacity(0.8),
        ),
      );
    }

    setState(() {
      _polylines
        ..clear()
        ..addAll(newPolylines.map((p) {
          // Bump width for the shortest route for visibility
          if (p.polylineId.value == 'route_${shortestIdx ?? -1}') {
            return p.copyWith(widthParam: 7, colorParam: Colors.blueAccent);
          }
          return p;
        }));
      _routeCount = newPolylines.length;
      _shortestRouteIndex = shortestIdx;
      _shortestDistanceText = shortestDistanceText;
      _shortestDurationText = shortestDurationText;
    });

    // Fit camera to bounds
    if (minLat != null && minLng != null && maxLat != null && maxLng != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      // Using a small delay helps when map is not yet fully created
      Future.delayed(const Duration(milliseconds: 300), () {
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 60),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.5),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Google Map
          SizedBox(
            height: 550,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId("start"),
                  position: _origin,
                  infoWindow: InfoWindow(title: "Krisna Rajendra"),
                ),
                Marker(
                  markerId: MarkerId("end"),
                  position: _destination,
                  infoWindow: InfoWindow(title: "Pendrikkan Kilo"),
                ),
              },
              polylines: _polylines, // Set the polylines to be displayed on the map
            ),
          ),
          SizedBox(height: 16),
          if (_routeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Routes: ' + _routeCount.toString() +
                    (_shortestDistanceText != null && _shortestDurationText != null
                        ? '  •  Shortest: ' + _shortestDistanceText! + ' (' + _shortestDurationText! + ')'
                        : ''),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 6, color: Colors.grey)],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose a ride",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                RideOption(
                  rideName: "Taxita Regular",
                  price: "\$23.87",
                  time: "10:24am | 2 min",
                  isCheaper: true,
                ),
                // RideOption(
                //   rideName: "Taxita Medium",
                //   price: "\$23.87",
                //   time: "10:24am | 2 min",
                // ),
                // RideOption(
                //   rideName: "Taxita Exclusive",
                //   price: "\$23.87",
                //   time: "10:24am | 2 min",
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RideOption extends StatelessWidget {
  final String rideName;
  final String price;
  final String time;
  final bool isCheaper;

  const RideOption({
    required this.rideName,
    required this.price,
    required this.time,
    this.isCheaper = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rideName),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isCheaper)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Cheaper",
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}


class fsd extends StatefulWidget {
  const fsd({super.key});

  @override
  State<fsd> createState() => _fsdState();
}

class _fsdState extends State<fsd> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
