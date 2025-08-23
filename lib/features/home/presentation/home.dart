import 'package:car_routing_application/config/routes/app_pages.dart';
import 'package:car_routing_application/core/widget/auto_complete.dart';
import 'package:car_routing_application/core/widget/autocomplete_widget.dart';
import 'package:car_routing_application/core/widget/custom_text_form_field.dart';
import 'package:car_routing_application/core/widget/test_auto_complete.dart';
import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';
import 'package:car_routing_application/features/home/domain/providers.dart';
import 'package:car_routing_application/features/home/presentation/widget/location_suggestion_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
   const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropOffController = TextEditingController();


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pickupController.dispose();
    _dropOffController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickupSuggestionsList = ref.watch(pickupSuggestionsProvider);
    final dropOffSuggestionsList = ref.watch(dropOffSuggestionsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 12,
                    children: [

                      LocationSearchWidget(
                          prefixIcon: Icon(Icons.my_location,color: Colors.white,),
                          hintText: "Pick-up location",
                          onSuggestedData: (value){}
                      ),
                      LocationSearchWidget(
                          prefixIcon: Icon(Icons.place_outlined,color: Colors.white,),
                          hintText: "Drop-off location",
                          onSuggestedData: (value){}
                      ),
                      // AppTextFormField(
                      //   controller: _pickupController,
                      //   hintText: "Pick-up location",
                      //   prefixIcon: const Icon(CupertinoIcons.location_solid, color: Colors.white70),
                      //   onChanged: (va)async{
                      //     final suggestions = await ref.read(getPlaceSuggestionsProvider).call(
                      //       va,
                      //       sessionToken: 'uuid-1',
                      //       countryComponent: 'country:bd',
                      //     );
                      //     ref.read(pickupSuggestionsProvider.notifier).state = suggestions;
                      //     print(suggestions.length);
                      //   },
                      // ),
                      // // if(pickupSuggestionsList.isNotEmpty)
                      // //   Expanded(child: SuggestionList(items: pickupSuggestionsList, onSelect: (value){})),
                      //
                      // AppTextFormField(
                      //   controller: _dropOffController,
                      //   hintText: "Drop-off location",
                      //   prefixIcon: const Icon(CupertinoIcons.add_circled_solid, color: Colors.white70),
                      //   onChanged: (va)async{
                      //     final suggestions = await ref.read(getPlaceSuggestionsProvider).call(
                      //       va,
                      //       sessionToken: 'uuid-1',
                      //       countryComponent: 'country:bd',
                      //     );
                      //     ref.read(dropOffSuggestionsProvider.notifier).state = suggestions;
                      //     print(suggestions.length);
                      //   },
                      // ),



                      // StrictAutocomplete<PlaceSuggestion>(
                      //   items: [],
                      //   prefixIcon: const Icon(CupertinoIcons.add_circled_solid, color: Colors.white70),
                      //   displayStringForOption: (s) => s.description,
                      //   hintText: "Drop-off location",
                      //   onChange: (value){
                      //
                      //   },
                      //   onSelected: (value) {
                      //     debugPrint('Selected: $value');
                      //   },
                      // ),

                      // GoogleAutoCompLocSuggestion(
                      //     items: pickupSuggestionsList,
                      //     onChange: (va)async{
                      //       final suggestions = await ref.read(getPlaceSuggestionsProvider).call(
                      //         va,
                      //         sessionToken: 'uuid-1',
                      //         countryComponent: 'country:bd',
                      //       );
                      //       ref.read(pickupSuggestionsProvider.notifier).state = suggestions;
                      //       print(suggestions.length);
                      //     },
                      //     onSelected: (va){}
                      // ),
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
              ),

              const SizedBox(height: 20),

            ],
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
