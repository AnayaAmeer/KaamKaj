import 'package:flutter/material.dart';
import '../../role_selection/screens/role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.home_repair_service,
      "title": "Find Trusted Services",
      "description":
          "Search verified professionals for all your home service needs."
    },
    {
      "icon": Icons.calendar_month,
      "title": "Book Easily",
      "description":
          "Book any service in just a few taps whenever you need."
    },
    {
      "icon": Icons.location_on,
      "title": "Track Your Booking",
      "description":
          "Track your booking status and stay updated in real time."
    },
  ];

  void _goToRoleSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RoleSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _goToRoleSelection,
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            pages[index]["icon"],
                            size: 90,
                            color: Colors.amber,
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          pages[index]["title"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          pages[index]["description"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: currentPage == index ? 28 : 10,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Colors.amber
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (currentPage < pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToRoleSelection();
                    }
                  },
                  child: Text(
                    currentPage == pages.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}