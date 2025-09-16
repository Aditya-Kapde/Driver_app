import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const JourneyPlannerApp());
}

class JourneyPlannerApp extends StatelessWidget {
  const JourneyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const JourneyPlannerScreen(),
    );
  }
}

class JourneyPlannerScreen extends StatefulWidget {
  const JourneyPlannerScreen({super.key});

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _tripButtonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  // Text editing controllers for search fields
  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();

  // Focus nodes for search fields
  final FocusNode _startPointFocus = FocusNode();
  final FocusNode _endPointFocus = FocusNode();

  // Mock data - would typically come from API calls
  final String routeName = "Route 15A - City Center";
  String currentLocation = "Central Mall Bus Stop";
  String destination = "Railway Station Terminal";
  
  final List<UpcomingStop> upcomingStops = [
    UpcomingStop(name: "Market Square", time: "2 min"),
    UpcomingStop(name: "City Hospital", time: "5 min"),
    UpcomingStop(name: "Railway Station", time: "12 min"),
  ];

  // Track if user has started a trip
  bool _tripStarted = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _tripButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _tripButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start button pulsing animation
    _tripButtonAnimationController.repeat(reverse: true);
    
    // Auto-focus on the starting point field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_startPointFocus);
    });
  }

  @override
  void dispose() {
    _tripButtonAnimationController.dispose();
    _startPointController.dispose();
    _endPointController.dispose();
    _startPointFocus.dispose();
    _endPointFocus.dispose();
    super.dispose();
  }

  // Function to handle start trip button tap
  void _handleStartTrip() {
    if (_startPointController.text.isEmpty || _endPointController.text.isEmpty) {
      // Show error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both starting point and destination"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Stop the pulsing animation
    _tripButtonAnimationController.stop();
    
    // Animate button press
    _tripButtonAnimationController.forward().then((_) {
      _tripButtonAnimationController.reverse();
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Planning your route..."),
              ],
            ),
          );
        },
      );
      
      // Simulate API call delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Update with new route data (simulated)
        setState(() {
          currentLocation = _startPointController.text;
          destination = _endPointController.text;
          _tripStarted = true;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Trip started successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Route View"),
        backgroundColor: Colors.orange[700],
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search fields (always shown at the top)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _startPointController,
                    focusNode: _startPointFocus,
                    decoration: InputDecoration(
                      labelText: 'Starting Point',
                      prefixIcon: const Icon(Icons.my_location, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _endPointController,
                    focusNode: _endPointFocus,
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: ElevatedButton(
                      onPressed: _handleStartTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Trip',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Only show route details after trip has been started
            if (_tripStarted) ...[
              // Route information section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.orange[700],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLocationRow(Icons.my_location, currentLocation),
                    const SizedBox(height: 8),
                    _buildLocationRow(Icons.location_on, destination),
                  ],
                ),
              ),
              
              // Map view section
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, size: 50, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        "Map View",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Integration Required",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Upcoming stops section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upcoming Stops",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: upcomingStops.length,
                      itemBuilder: (context, index) {
                        return _buildStopItem(upcomingStops[index]);
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show prompt to start a trip
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    "Enter your starting point and destination to plan your journey",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStopItem(UpcomingStop stop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_pin, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stop.name,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            stop.time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for upcoming stops
class UpcomingStop {
  final String name;
  final String time;

  UpcomingStop({required this.name, required this.time});
}

// Backend API integration comments
/*
API Integration Points:

1. Route Planning API:
   - Endpoint: POST /api/plan-route
   - Parameters: {start: "Starting Point", end: "Destination"}
   - Returns: Planned route with details and estimated times

2. Fetch Route Data:
   - Endpoint: GET /api/routes/{routeId}
   - Returns: Route details including name, stops, and other information

3. Fetch Upcoming Stops:
   - Endpoint: GET /api/routes/{routeId}/stops
   - Returns: List of upcoming stops with estimated arrival times

4. Real-time Location Updates:
   - WebSocket: ws://api.example.com/rt-locations/{routeId}
   - Continuously sends vehicle location data for map integration

5. Map Integration:
   - Would use Google Maps API or similar service
   - Requires API key and proper setup
   - Would display real-time vehicle location and route path

Implementation Steps:

1. Add HTTP client dependency (http, dio, etc.)
2. Create API service class with methods for:
   - planRoute(start, end)
   - fetchRouteDetails(routeId)
   - fetchUpcomingStops(routeId)
   - connectToRealTimeUpdates(routeId)
3. Add error handling for API calls
4. Implement loading states while fetching data
5. Add proper state management (Provider, Bloc, etc.)
*/