import 'package:car_routing_application/features/home/domain/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MyCurrentLocation extends StatelessWidget {
  const MyCurrentLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height * 0.18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Consumer(
        builder: (context, ref, _) {
          final mapState = ref.watch(mapControllerProvider);
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: mapState.myLatLng ?? LatLng(23.8041, 90.4152),
                  zoom: 10,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) async {
                  // When we have a location, animate to it
                  if (mapState.myLatLng != null) {
                    await controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: mapState.myLatLng!, zoom: 16),
                      ),
                    );
                  }
                  // React to future updates
                  ref.listen(mapControllerProvider, (prev, next) async {
                    if (next.myLatLng != null) {
                      await controller.animateCamera(
                        CameraUpdate.newLatLng(next.myLatLng!),
                      );
                    }
                  });
                },
                markers: {
                  if (mapState.myLatLng != null)
                    Marker(
                      markerId: const MarkerId('me'),
                      position: mapState.myLatLng!,
                      infoWindow: const InfoWindow(title: 'You are here'),
                    ),
                },
                circles: {
                  if (mapState.myLatLng != null && mapState.accuracy != null)
                    Circle(
                      circleId: const CircleId('accuracy'),
                      center: mapState.myLatLng!,
                      radius: mapState.accuracy!,
                      strokeWidth: 1,
                      strokeColor: Colors.blue.withValues(alpha: 0.4),
                      fillColor: Colors.blue.withValues(alpha: 0.1),
                    ),
                },
              ),
              if (mapState.loading)
                const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text('Getting current location...'),
                      ),
                    ),
                  ),
                ),
              if (mapState.error != null)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          mapState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
