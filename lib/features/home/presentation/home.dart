import 'package:car_routing_application/config/routes/app_pages.dart';
import 'package:car_routing_application/config/routes/app_routes.dart';
import 'package:car_routing_application/core/widget/autocomplete_widget.dart';
import 'package:car_routing_application/core/widget/location_auto_search.dart';
import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';
import 'package:car_routing_application/features/home/domain/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
   const HomePage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsList = ref.watch(pickupSuggestionsProvider);
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

                      TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.location_solid, color: Colors.white70),
                          hintText: "Pick-up location",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (va)async{
                          final suggestions = await ref.read(getPlaceSuggestionsProvider).call(
                            va,
                            sessionToken: 'uuid-1',
                            countryComponent: 'country:bd',
                          );
                          ref.read(pickupSuggestionsProvider.notifier).state = suggestions;
                          print(suggestions.length);
                        },
                      ),

                      StrictAutocomplete<PlaceSuggestion>(
                        items: [],
                        prefixIcon: const Icon(CupertinoIcons.add_circled_solid, color: Colors.white70),
                        displayStringForOption: (s) => s.description,
                        hintText: "Drop-off location",
                        onChange: (value){

                        },
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
                if(suggestionsList.isNotEmpty)...[
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestionsList.length,
                      itemBuilder: (ctx,index){
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(suggestionsList[index].description),
                          onTap: (){
                            // Handle the selection
                            print('Selected: ${suggestionsList[index]}');
                          },
                        );
                      }
                  )
                ],

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
