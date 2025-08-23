import 'package:car_routing_application/features/home/domain/entities/place_details.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class _RouteInfo {
  final int index;
  final int meters;
  final String distanceText;
  final String durationText;

  _RouteInfo({
    required this.index,
    required this.meters,
    required this.distanceText,
    required this.durationText,
  });
}

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

  late LatLng _origin;
  late LatLng _destination;

  final Set<Polyline> _polylines = {};

  // Route stats
  int _routeCount = 0;
  int? _shortestRouteIndex;
  String? _shortestDistanceText;
  String? _shortestDurationText;

  // Sorted list of routes (shortest first)
  final List<_RouteInfo> _routesInfo = [];

  // Currently selected route (for highlighting); defaults to shortest
  int? _selectedRouteIndex;
  // Bounds for each route (same order as routes list)
  final List<LatLngBounds> _routeBounds = [];

  // 🔑 Set your Google Maps Directions API key here
  final String _googleApiKey = 'AIzaSyA6Y6eG8TICGWA-Skcqc5LL4iETdnqLEI8';

  @override
  void initState() {
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(widget.pickUpPlaceDetails.lat, widget.pickUpPlaceDetails.lng),
      zoom: 10,
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
    final List<_RouteInfo> routeInfoList = [];

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
    final List<LatLngBounds> routeBoundsTemp = [];

    int? shortestIdx;
    int shortestMeters = 1 << 30;
    String? shortestDistanceText;
    String? shortestDurationText;

    for (int i = 0; i < routes.length; i++) {
      final r = routes[i] as Map<String, dynamic>;
      final overview = r['overview_polyline']?['points'] as String?;
      if (overview == null) continue;

      final points = _decodePolyline(overview);

      // Per-route bounds
      double? rMinLat, rMinLng, rMaxLat, rMaxLng;
      for (final p in points) {
        rMinLat = (rMinLat == null) ? p.latitude : (p.latitude < rMinLat ? p.latitude : rMinLat);
        rMinLng = (rMinLng == null) ? p.longitude : (p.longitude < rMinLng ? p.longitude : rMinLng);
        rMaxLat = (rMaxLat == null) ? p.latitude : (p.latitude > rMaxLat ? p.latitude : rMaxLat);
        rMaxLng = (rMaxLng == null) ? p.longitude : (p.longitude > rMaxLng ? p.longitude : rMaxLng);
      }
      if (rMinLat != null && rMinLng != null && rMaxLat != null && rMaxLng != null) {
        routeBoundsTemp.add(
          LatLngBounds(
            southwest: LatLng(rMinLat, rMinLng),
            northeast: LatLng(rMaxLat, rMaxLng),
          ),
        );
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
      routeInfoList.add(
        _RouteInfo(
          index: i,
          meters: meters,
          distanceText: distText ?? '${(meters / 1000).toStringAsFixed(1)} km',
          durationText: durText ?? '',
        ),
      );

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

    // Sort routes by distance (shortest first)
    routeInfoList.sort((a, b) => a.meters.compareTo(b.meters));
    if (routeInfoList.isNotEmpty) {
      shortestIdx = routeInfoList.first.index;
      shortestDistanceText = routeInfoList.first.distanceText;
      shortestDurationText = routeInfoList.first.durationText;
    }

    setState(() {
      _polylines
        ..clear()
        ..addAll(newPolylines.map((p) {
          if (p.polylineId.value == 'route_${_selectedRouteIndex ?? -1}') {
            return p.copyWith(widthParam: 7, colorParam: Colors.blueAccent);
          }
          return p.copyWith(widthParam: 5, colorParam: p.color.withOpacity(0.8));
        }));
      _routeCount = newPolylines.length;
      _shortestRouteIndex = shortestIdx;
      _shortestDistanceText = shortestDistanceText;
      _shortestDurationText = shortestDurationText;
      // Default selection to shortest route initially
      _selectedRouteIndex = shortestIdx;
      _routeBounds
        ..clear()
        ..addAll(routeBoundsTemp);
      _routesInfo
        ..clear()
        ..addAll(routeInfoList);
    });
  }

  void _applyPolylineHighlight({bool animate = true}) {
    final selectedId = 'route_${_selectedRouteIndex ?? -1}';
    final updated = _polylines.map((p) {
      if (p.polylineId.value == selectedId) {
        return p.copyWith(widthParam: 7, colorParam: Colors.blueAccent);
      }
      return p.copyWith(widthParam: 5, colorParam: p.color.withOpacity(0.8));
    }).toSet();
    setState(() {
      _polylines
        ..clear()
        ..addAll(updated);
    });

    if (animate && _selectedRouteIndex != null && _selectedRouteIndex! < _routeBounds.length) {
      final b = _routeBounds[_selectedRouteIndex!];
      Future.delayed(const Duration(milliseconds: 150), () {
        mapController.animateCamera(CameraUpdate.newLatLngBounds(b, 60));
      });
    }
  }

  void _selectRoute(int index) {
    _selectedRouteIndex = index;
    _applyPolylineHighlight();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
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
        spacing: 5,
        children: [
          // Google Map
          Expanded(
            flex: 8,
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
                  infoWindow: InfoWindow(title: "Pickup points"),
                ),
                Marker(
                  markerId: MarkerId("end"),
                  position: _destination,
                  infoWindow: InfoWindow(title: "Destination points"),
                ),
              },
              polylines: _polylines,
            ),
          ),
          if (_routesInfo.isNotEmpty)
            Expanded(
              flex: 6,
              child: ListView.builder(
                itemCount: _routesInfo.length,
                itemBuilder: (context, idx) {
                  final r = _routesInfo[idx];
                  final isShortest = idx == 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    minTileHeight: 0,
                    leading: CircleAvatar(child: Text('${idx + 1}')),
                    title: Text(
                      '${r.distanceText}  •  ${r.durationText}',
                      style: TextStyle(fontWeight: r.index == _selectedRouteIndex ? FontWeight.w700 : FontWeight.w500),
                    ),
                    subtitle: Text('Route ${r.index + 1}${isShortest ? ' • Shortest' : ''}'),
                    trailing: isShortest ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    onTap: () => _selectRoute(r.index),
                  );
                },
              ),
            ),

        ],
      ),
    );
  }
}
