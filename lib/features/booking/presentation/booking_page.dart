import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideBookingScreen extends StatefulWidget {
  @override
  _RideBookingScreenState createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  late GoogleMapController mapController;

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(12.9716, 77.5946), // Bangalore coordinates
    zoom: 14,
  );

  // Coordinates for the polyline
  final List<LatLng> _polylineCoordinates = [
    LatLng(12.9716, 77.5946), // Start position (Krisna Rajendra)
    LatLng(12.9700, 77.5950), // End position (Pendrikkan Kilo)
  ];

  // Set to hold polylines
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _addPolyline(); // Add polyline when the widget is initialized
  }

  // Method to add the polyline
  void _addPolyline() {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'), // Unique ID for the polyline
          // Polyline color (you can choose any color)
          width: 5, // Polyline width
          points: _polylineCoordinates, // List of coordinates for the route
        ),
      );
    });
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
              mapType: MapType.hybrid,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId("start"),
                  position: LatLng(12.9716, 77.5946), // Start position
                  infoWindow: InfoWindow(title: "Krisna Rajendra"),
                ),
                Marker(
                  markerId: MarkerId("end"),
                  position: LatLng(12.9700, 77.5950), // End position
                  infoWindow: InfoWindow(title: "Pendrikkan Kilo"),
                ),
              },
              polylines: _polylines, // Set the polylines to be displayed on the map
            ),
          ),
          SizedBox(height: 16),
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
                RideOption(
                  rideName: "Taxita Medium",
                  price: "\$23.87",
                  time: "10:24am | 2 min",
                ),
                RideOption(
                  rideName: "Taxita Exclusive",
                  price: "\$23.87",
                  time: "10:24am | 2 min",
                ),
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