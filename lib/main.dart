import 'package:car_routing_application/config/routes/app_pages.dart';
import 'package:car_routing_application/config/routes/app_routes.dart';
import 'package:car_routing_application/config/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Routing Application',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      initialRoute: AppPages.initial,
      onGenerateRoute: AppRoutes.generate,
    );
  }
}