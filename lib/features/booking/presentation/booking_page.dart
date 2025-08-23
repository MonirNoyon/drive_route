import 'package:car_routing_application/features/booking/presentation/controller/route_controller.dart';
import 'package:car_routing_application/features/booking/presentation/states/route_state.dart';
import 'package:car_routing_application/features/home/domain/entities/place_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({
    super.key,
    required this.pickUpPlaceDetails,
    required this.dropOffPlaceDetails,
  });

  final PlaceDetails pickUpPlaceDetails;
  final PlaceDetails dropOffPlaceDetails;

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  late final CameraPosition _initialPosition;

  @override
  void initState() {
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(widget.pickUpPlaceDetails.lat, widget.pickUpPlaceDetails.lng),
      zoom: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(
      routeControllerFamily((widget.pickUpPlaceDetails, widget.dropOffPlaceDetails)).notifier,
    );
    final state = ref.watch(
      routeControllerFamily((widget.pickUpPlaceDetails, widget.dropOffPlaceDetails)),
    );

    final origin = LatLng(widget.pickUpPlaceDetails.lat, widget.pickUpPlaceDetails.lng);
    final destination = LatLng(widget.dropOffPlaceDetails.lat, widget.dropOffPlaceDetails.lng);

    final polylines = _buildPolylines(state);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: controller.attachMap,
              mapType: MapType.normal,
              markers: {
                Marker(markerId: const MarkerId("start"), position: origin, infoWindow: const InfoWindow(title: "Pickup point")),
                Marker(markerId: const MarkerId("end"), position: destination, infoWindow: const InfoWindow(title: "Destination")),
              },
              polylines: polylines,
            ),
          ),
          if (state.loading) const LinearProgressIndicator(),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(state.error!, style: const TextStyle(color: Colors.red)),
            ),
          if (state.routes.isNotEmpty)
            Expanded(
              flex: 6,
              child: ListView.builder(
                itemCount: state.routes.length,
                itemBuilder: (context, idx) {
                  final ro = state.routes[idx];
                  final isShortest = idx == 0;
                  final isSelected = ro.index == state.selectedIndex;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${idx + 1}')),
                    title: Text(
                      '${ro.distanceText}  •  ${ro.durationText}',
                      style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                    ),
                    subtitle: Text('Route ${ro.index + 1}${isShortest ? ' • Shortest' : ''}'),
                    trailing: isShortest ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    onTap: () => controller.selectRoute(ro.index),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Set<Polyline> _buildPolylines(RouteState state) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.cyan,
    ];

    final Set<Polyline> lines = {};
    for (int i = 0; i < state.routes.length; i++) {
      final ro = state.routes[i];
      final pts = ro.points.map((p) => LatLng(p.lat, p.lng)).toList();
      final baseColor = i < colors.length ? colors[i] : Colors.grey;
      final highlighted = ro.index == state.selectedIndex;

      lines.add(Polyline(
        polylineId: PolylineId('route_${ro.index}'),
        points: pts,
        width: highlighted ? 7 : 5,
        color: highlighted ? Colors.blueAccent : baseColor.withOpacity(0.8),
      ));
    }
    return lines;
  }
}