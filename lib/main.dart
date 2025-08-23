import 'package:car_routing_application/config/routes/app_pages.dart';
import 'package:car_routing_application/config/routes/app_routes.dart';
import 'package:car_routing_application/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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