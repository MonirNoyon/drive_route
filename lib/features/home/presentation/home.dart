import 'package:car_routing_application/config/routes/app_pages.dart';
import 'package:car_routing_application/config/routes/app_routes.dart';
import 'package:car_routing_application/core/widget/autocomplete_widget.dart';
import 'package:car_routing_application/core/widget/location_auto_search.dart';
import 'package:car_routing_application/features/home/domain/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const cities = <City>[
      City('Dhaka', 'Bangladesh'),
      City('Chattogram', 'Bangladesh'),
      City('Cox\'s Bazar', 'Bangladesh'),
      City('Kolkata', 'India'),
      City('Singapore', 'Singapore'),
      City('London', 'UK'),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Desirae Levin",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.cloud, color: Colors.orange),
                        SizedBox(width: 6),
                        Text("25°C", style: TextStyle(fontSize: 14)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Greeting Section
                const Text(
                  "Hi Emery,",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Where do you will go?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Pick-up & Drop-off Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2D1D), // dark green BG
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    spacing: 12,
                    children: [
                //   Padding(
                //   padding: const EdgeInsets.all(16),
                //   child: GoogleSearchAutoComplete<City>(
                //     places: cities,
                //     // optional: how to show each item (fallback: toString())
                //     displayStringForOption: (c) => '${c.name}, ${c.country}',
                //     // optional: customize rows
                //     itemBuilder: (ctx, city, query) => Padding(
                //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                //       child: Row(
                //         children: [
                //           const Icon(Icons.place_outlined, size: 20),
                //           const SizedBox(width: 10),
                //           Expanded(
                //             child: Text('${city.name}, ${city.country}',
                //                 maxLines: 1, overflow: TextOverflow.ellipsis),
                //           ),
                //         ],
                //       ),
                //     ),
                //     onSelected: (city) {
                //       debugPrint('Selected: ${city.name}');
                //     },
                //     onChange: (q) {
                //       debugPrint('Query changed: $q');
                //     },
                //     hintText: 'Search cities…',
                //     // decoration: InputDecoration(...),
                //     minSearchLength: 1,
                //     debounceMs: 150,
                //   ),
                // ),

                      TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.location_solid, color: Colors.white70),
                          hintText: "Pick-up location",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (va)async{
                          print('object');
                          final suggestions = await ref.read(getPlaceSuggestionsProvider).call(
                            va,
                            sessionToken: 'uuid-1',
                            countryComponent: 'country:bd',
                          );
                          print(suggestions.length);
                        },
                      ),

                      StrictAutocomplete<String>(
                        items: <String>[
                          'Apple', 'Apricot', 'Banana', 'Blackberry', 'Blueberry',
                          'Cherry', 'Grapes', 'Mango', 'Orange', 'Peach', 'Pear',
                          'Pineapple', 'Plum', 'Strawberry', 'Watermelon',
                        ],
                        prefixIcon: const Icon(CupertinoIcons.add_circled_solid, color: Colors.white70),
                        displayStringForOption: (s) => s,
                        hintText: "Drop-off location",
                        onSelected: (value) {
                          debugPrint('Selected: $value');
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, AppPages.bookingPage);
                          },
                          child: const Text("Find drivers"),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),


                // Discount Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Discount SafeTrip+ activated for \$10\nUp to \$5 vouchers for pickup delays.",
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Services Section
                const Text("Services",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // _serviceIcon("assets/icons/car.png", "Ride"),
                    // _serviceIcon("assets/icons/food.png", "Food"),
                    // _serviceIcon("assets/icons/grocery.png", "Grocery"),
                    // _serviceIcon("assets/icons/reserve.png", "Reserve"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceIcon(String path, String title) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          radius: 28,
          child: Image.asset(path, height: 28, fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}


class City {
  final String name;
  final String country;
  const City(this.name, this.country);

  @override
  String toString() => '$name, $country';
}
