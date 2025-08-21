import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "Coupons"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section Profile + Weather
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage("assets/images/user_avatar.png"),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.location_on_outlined, color: Colors.white70),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Pick up location",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.flag_outlined, color: Colors.white70),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Drop-off location",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          ],
                        ),
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
                          onPressed: () {},
                          child: const Text("Find drivers"),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Map Preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    "assets/images/map_preview.png",
                    fit: BoxFit.cover,
                    height: 160,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 16),

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
                    _serviceIcon("assets/icons/car.png", "Ride"),
                    _serviceIcon("assets/icons/food.png", "Food"),
                    _serviceIcon("assets/icons/grocery.png", "Grocery"),
                    _serviceIcon("assets/icons/reserve.png", "Reserve"),
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
