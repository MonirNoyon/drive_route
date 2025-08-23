import 'package:car_routing_application/config/routes/app_pages.dart';
import 'package:car_routing_application/core/widget/no_page_found.dart';
import 'package:car_routing_application/features/booking/presentation/booking_page.dart';
import 'package:car_routing_application/features/home/domain/entities/place_details.dart';
import 'package:car_routing_application/features/home/presentation/home.dart';
import 'package:car_routing_application/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generate(RouteSettings setting) {
    switch (setting.name) {
      case AppPages.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppPages.home:
        return MaterialPageRoute(builder: (_) =>  HomePage());
      case AppPages.bookingPage:
        Map? arg = setting.arguments as Map?;
        PlaceDetails pickup = arg?["pick_up"];
        PlaceDetails dropOff = arg?["drop_off"];
        return MaterialPageRoute(builder: (_) =>  RideBookingScreen(
          pickUpPlaceDetails: pickup,
          dropOffPlaceDetails: dropOff,
        ));
      default:
        return MaterialPageRoute(builder: (_) => const NoPageFound()
        );
    }
  }
}