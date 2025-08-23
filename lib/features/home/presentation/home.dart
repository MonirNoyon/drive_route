import 'package:car_routing_application/config/routes/app_pages.dart';
import 'package:car_routing_application/core/widget/test_auto_complete.dart';
import 'package:car_routing_application/features/home/domain/entities/place_details.dart';
import 'package:car_routing_application/features/home/domain/providers.dart';
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

  PlaceDetails? pickUpPlaceDetails;
  PlaceDetails? dropOffPlaceDetails;


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
                          onSuggestedData: (value){
                            pickUpPlaceDetails = value;
                          }
                      ),
                      LocationSearchWidget(
                          prefixIcon: Icon(Icons.place_outlined,color: Colors.white,),
                          hintText: "Drop-off location",
                          onSuggestedData: (value){
                            dropOffPlaceDetails = value;
                          }
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
                            FocusNode().unfocus();
                            Navigator.pushNamed(context, AppPages.bookingPage,arguments: {
                              "pick_up": pickUpPlaceDetails,
                              "drop_off": dropOffPlaceDetails,
                            });
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
