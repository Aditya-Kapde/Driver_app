import 'package:flutter/material.dart';

// TODO: Import necessary packages for API calls (http, dio, etc.)
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All Trips';
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // TODO: Add variables for storing API data
  // List<Trip> _trips = [];
  // MonthlyStats _monthlyStats = MonthlyStats();

  final List<Map<String, dynamic>> _filters = [
    {'label': 'All Trips', 'icon': Icons.all_inclusive, 'count': 28},
    {'label': 'Today', 'icon': Icons.today, 'count': 3},
    {'label': 'This Week', 'icon': Icons.calendar_view_week, 'count': 12},
    {'label': 'This Month', 'icon': Icons.calendar_today, 'count': 28}
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // TODO: Call API to fetch initial trip data
    _fetchTripData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // TODO: Implement API call to fetch trip data
  Future<void> _fetchTripData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Example API call structure:
      // final response = await http.get(
      //   Uri.parse('https://your-api.com/trips?filter=$_selectedFilter'),
      //   headers: {'Authorization': 'Bearer your_token'},
      // );
      // 
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   setState(() {
      //     _trips = data['trips'].map((trip) => Trip.fromJson(trip)).toList();
      //     _monthlyStats = MonthlyStats.fromJson(data['monthlyStats']);
      //     _isLoading = false;
      //   });
      // } else {
      //   throw Exception('Failed to load trips');
      // }
      
      // Simulating API delay
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // TODO: Handle error (show snackbar or dialog)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading trips: $error')),
      );
    }
  }

  // TODO: Implement API call for viewing trip details
  Future<void> _viewTripDetails(String tripId) async {
    // Example:
    // final response = await http.get(
    //   Uri.parse('https://your-api.com/trips/$tripId'),
    //   headers: {'Authorization': 'Bearer your_token'},
    // );
    // 
    // if (response.statusCode == 200) {
    //   final tripDetails = json.decode(response.body);
    //   // Navigate to trip details screen or show dialog
    // } else {
    //   throw Exception('Failed to load trip details');
    // }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for trip $tripId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monthly Overview Section with animation
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      )),
                      child: const Text(
                        'Monthly Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Animated Stats Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildAnimatedStatCard(0, '28', 'Total Trips', Icons.directions_bus_filled, Colors.orange),
                        _buildAnimatedStatCard(1, '894.5 km', 'Distance', Icons.navigation_rounded, Colors.green),
                        _buildAnimatedStatCard(2, '₹82,485', 'Revenue', Icons.account_balance_wallet_rounded, Colors.orange),
                        _buildAnimatedStatCard(3, '1247', 'Passengers', Icons.people_alt_rounded, Colors.purple),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Filter Chips with icons and counts
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      )),
                      child: SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _filters.asMap().entries.map((entry) {
                            final index = entry.key;
                            final filter = entry.value;
                            final isSelected = _selectedFilter == filter['label'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(filter['icon'], size: 16),
                                    const SizedBox(width: 4),
                                    Text(filter['label']),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${filter['count']})',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white70 : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter['label'];
                                  });
                                  // TODO: Refetch data when filter changes
                                  _fetchTripData();
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.orange,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.grey[300]!,
                                    width: isSelected ? 0 : 1,
                                  ),
                                ),
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated Trip List
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: _buildTripList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAnimatedStatCard(int index, String value, String title, IconData icon, Color color) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.1 + index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.1 + index * 0.1, 1.0, curve: Curves.easeIn),
          ),
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripList() {
    // TODO: Replace with ListView.builder using _trips data
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildAnimatedTripCard(0, 'trip_001', 'City Center → Airport Terminal',
            '2024-01-15 • 08:00 AM - 10:30 AM', '45.2 km', '2h 30m', '38', '₹950', 'Completed'),
        const SizedBox(height: 16),
        _buildAnimatedTripCard(1, 'trip_002', 'Airport Terminal → Railway Station',
            '2024-01-15 • 11:15 AM - 01:45 PM', '32.8 km', '2h 30m', '42', '₹1,050', 'Completed'),
        const SizedBox(height: 16),
        _buildAnimatedTripCard(2, 'trip_003', 'Railway Station → Bus Stand',
            '2024-01-15 • 02:30 PM - 04:00 PM', '18.5 km', '1h 30m', '35', '₹700', 'Completed'),
      ],
    );
  }

  Widget _buildAnimatedTripCard(
    int index,
    String tripId,
    String route,
    String dateTime,
    String distance,
    String duration,
    String passengers,
    String revenue,
    String status,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.3 + index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.3 + index * 0.1, 1.0, curve: Curves.easeIn),
          ),
        ),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        route,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dateTime,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTripDetail('Distance', distance, Icons.navigation_rounded),
                    _buildTripDetail('Duration', duration, Icons.access_time_rounded),
                    _buildTripDetail('Passengers', passengers, Icons.people_alt_rounded),
                    _buildTripDetail('Revenue', revenue, Icons.account_balance_wallet_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _viewTripDetails(tripId);
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetail(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// TODO: Add data models for API responses
// class Trip {
//   final String id;
//   final String route;
//   final String dateTime;
//   final String distance;
//   final String duration;
//   final String passengers;
//   final String revenue;
//   final String status;
// 
//   Trip({
//     required this.id,
//     required this.route,
//     required this.dateTime,
//     required this.distance,
//     required this.duration,
//     required this.passengers,
//     required this.revenue,
//     required this.status,
//   });
// 
//   factory Trip.fromJson(Map<String, dynamic> json) {
//     return Trip(
//       id: json['id'],
//       route: json['route'],
//       dateTime: json['dateTime'],
//       distance: json['distance'],
//       duration: json['duration'],
//       passengers: json['passengers'],
//       revenue: json['revenue'],
//       status: json['status'],
//     );
//   }
// }
// 
// class MonthlyStats {
//   final int totalTrips;
//   final String totalDistance;
//   final String totalRevenue;
//   final int totalPassengers;
// 
//   MonthlyStats({
//     this.totalTrips = 0,
//     this.totalDistance = '0 km',
//     this.totalRevenue = '₹0',
//     this.totalPassengers = 0,
//   });
// 
//   factory MonthlyStats.fromJson(Map<String, dynamic> json) {
//     return MonthlyStats(
//       totalTrips: json['totalTrips'],
//       totalDistance: json['totalDistance'],
//       totalRevenue: json['totalRevenue'],
//       totalPassengers: json['totalPassengers'],
//     );
//   }
// }