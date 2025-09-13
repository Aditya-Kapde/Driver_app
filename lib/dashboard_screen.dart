import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'setup_profile_personal_screen.dart';
import 'sos_emergency_screen.dart';
import 'trip_history_screen.dart';
import 'journey_planner_screen.dart';

import 'support_center_screen.dart' as support_center;
import 'chat_support_screen.dart';
import 'settings_screen.dart';
import 'theme_notifier.dart'; // Import your ThemeNotifier


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Hover states for quick action buttons
  final Map<String, bool> _hoverStates = {
    'Start Trip': false,
    'Support': false,
    'Trip History': false,
    'Journey Planner': false,
  };

  bool _isFabExpanded = false;
  String _selectedQuickAction = '';

  final TextEditingController _searchController = TextEditingController();
  List<String> _features = [
    'Start Trip',
    'Support',
    'Trip History',
    'Journey Planner',
    'Setup Profile',
    'SOS Emergency',
  ];
  List<String> _filteredFeatures = [];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JourneyPlannerScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TripHistoryScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetupProfilePersonalScreen()),
      );
    }
  }

  void _setHoverState(String buttonName, bool isHovering) {
    setState(() {
      _hoverStates[buttonName] = isHovering;
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    
    // Scale animation for floating particles
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Slide animation for background elements
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.05, 0.05),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _searchController.addListener(_onSearchChanged);
    _filteredFeatures = [];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredFeatures = _features
          .where((feature) => feature.toLowerCase().contains(query))
          .toList();
    });
  }

  void _onFeatureTap(String feature) {
    if (feature == 'Start Trip') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Starting trip...')),
      );
    } else if (feature == 'Support') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacting support...')),
      );
    } else if (feature == 'Trip History') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TripHistoryScreen()),
      );
    } else if (feature == 'Journey Planner') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JourneyPlannerScreen()),
      );
    } else if (feature == 'Setup Profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetupProfilePersonalScreen()),
      );
    } else if (feature == 'SOS Emergency') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SosEmergencyScreen()),
      );
    }
    _searchController.clear();
    _filteredFeatures = [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(

      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(

      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Animated background with subtle moving gradient
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFFE1F5FE),
                      Color(0xFFF3E5F5),
                      Color(0xFFE8F5E9),
                    ],
                    stops: [0.0, 0.5 + _animationController.value * 0.1, 1.0],
                  ),
                ),
              );
            },
          ),
          
          // Animated floating particles
          ..._buildFloatingParticles(),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'DriverPortal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SosEmergencyScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emergency_outlined,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JourneyPlannerScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.route_outlined, // or use your custom icon
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Search Bar with functionality
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(

                      color: const Color(0xFF6366F1), // Keep brand color
                      borderRadius: BorderRadius.circular(8),

                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],

                    ),
                    child: Row(
                      children: [
                        Icon(

                          Icons.directions_bus_filled,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'MargDarshak',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,

                          Icons.search,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search routes, locations, features...',
                              border: InputBorder.none,
                              isDense: true,
                            ),

                          ),
                        ),
                      ],
                    ),
                  ),

                  // Show filtered features as suggestions
                  if (_filteredFeatures.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(

                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),

                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: _filteredFeatures.map((feature) {
                          return ListTile(
                            title: Text(feature),
                            onTap: () => _onFeatureTap(feature),
                          );
                        }).toList(),
                      ),
                    ),

                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const support_center.SupportCenterScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.support_agent_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),


                  const SizedBox(height: 24),

                  // Ready for journey text
                  const Text(
                    'Ready for your next journey?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,

                    ),
                  ),

                  const SizedBox(height: 20),


              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: theme.hintColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search routes, locations...',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ready for journey text
              Text(
                'Ready for your next journey?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),

                  // Stats Cards - First Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today\'s Hours',
                          '6.5h',
                          Colors.green,
                          Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Distance',
                          '245 km',
                          const Color(0xFF6366F1),
                          Icons.navigation_outlined,
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(height: 16),


              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Today\'s Hours',
                      '6.5h',
                      Colors.green,
                      Icons.access_time,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Distance',
                      '245 km',
                      const Color(0xFFD2D2D8),
                      Icons.navigation_outlined,
                      theme,
                    ),

                  // Stats Cards - Second Row (Earnings centered)
                  Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: _buildStatCard(
                          'Earnings',
                          '₹1,850',
                          Colors.purple,
                          Icons.account_balance_wallet,
                        ),
                      ),
                      const Spacer(),
                    ],

                  ),

                  const SizedBox(height: 32),


              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Fuel Level',
                      '78%',
                      Colors.orange,
                      Icons.local_gas_station,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Earnings',
                      '₹1,850',
                      Colors.purple,
                      Icons.account_balance_wallet,
                      theme,

                  // Quick Actions Section
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,

                    ),
                  ),

                  const SizedBox(height: 16),


              // Quick Actions Section
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],

                    ),
                    child: Column(
                      children: [

                        Expanded(
                          child: _buildQuickActionButton(
                            'Start Trip',
                            const Color(0xFF6366F1),
                            Icons.navigation,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const JourneyPlannerScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            'SOS Emergency',
                            Colors.red,
                            Icons.emergency,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SosEmergencyScreen()),
                              );
                            },
                          ),

                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionButton(
                                'Start Trip',
                                _hoverStates['Start Trip']! ? const Color(0xFF6366F1) : Colors.grey[100]!,
                                Icons.navigation,
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Starting trip...')),
                                  );
                                },
                                onHover: (isHovering) => _setHoverState('Start Trip', isHovering),
                                isHovered: _hoverStates['Start Trip']!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionButton(
                                'Support',
                                _hoverStates['Support']! ? const Color(0xFF6366F1) : Colors.grey[100]!,
                                Icons.headset_mic_outlined,
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Contacting support...')),
                                  );
                                },
                                onHover: (isHovering) => _setHoverState('Support', isHovering),
                                isHovered: _hoverStates['Support']!,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionButton(
                                'Trip History',
                                _hoverStates['Trip History']! ? const Color(0xFF6366F1) : Colors.grey[100]!,
                                Icons.description_outlined,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TripHistoryScreen()),
                                  );
                                },
                                onHover: (isHovering) => _setHoverState('Trip History', isHovering),
                                isHovered: _hoverStates['Trip History']!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionButton(
                                'Journey Planner',
                                _hoverStates['Journey Planner']! ? const Color(0xFF6366F1) : Colors.grey[100]!,
                                Icons.route_outlined,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const JourneyPlannerScreen()),
                                  );
                                },
                                onHover: (isHovering) => _setHoverState('Journey Planner', isHovering),
                                isHovered: _hoverStates['Journey Planner']!,
                              ),
                            ),
                          ],

                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Test Navigation Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      children: [

                        Expanded(
                          child: _buildQuickActionButton(
                            'Trip History',
                            Colors.green,
                            Icons.history,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TripHistoryScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            'Settings',
                            Colors.grey[600]!,
                            Icons.settings,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            },
=======
                        const Icon(
                          Icons.bug_report,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Testing Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const JourneyPlannerScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),

                          ),
                          child: const Text('Go to Journey Planner'),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],

                  ),

                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),

          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.cardColor,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: theme.iconTheme.color,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.route_outlined),
              activeIcon: Icon(Icons.route),
              label: 'Routes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: 'Trip History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Setup Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFabMenu(context),
    );
  }

  Widget _buildFabMenu(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // SOS FAB
        if (_isFabExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 120, right: 8),
            child: FloatingActionButton(
              heroTag: 'sos_fab',
              backgroundColor: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SosEmergencyScreen()),
                );
                setState(() => _isFabExpanded = false);
              },
              child: const Icon(Icons.emergency_outlined, color: Colors.white),
            ),
          ),
        // Location FAB (green, location icon)
        if (_isFabExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 60, right: 8),
            child: FloatingActionButton(
              heroTag: 'location_fab',
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JourneyPlannerScreen()),
                );
                setState(() => _isFabExpanded = false);
              },
              child: const Icon(Icons.location_on, color: Colors.white),
            ),
          ),
        // Main FAB (toggle)
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: FloatingActionButton(
            heroTag: 'menu_fab',
            backgroundColor: Colors.white,
            onPressed: () {
              setState(() => _isFabExpanded = !_isFabExpanded);
            },
            child: const Icon(Icons.menu, color: Colors.blue, size: 32),
          ),
        ),
      ],
    );
  }


  Widget _buildStatCard(String title, String value, Color color, IconData icon, ThemeData theme) {

  List<Widget> _buildFloatingParticles() {
    return [
      // Large animated circles
      Positioned(
        top: 50,
        right: -60,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.1, 1.0],
              ),
            ),
          ),
        ),
      ),
      
      Positioned(
        bottom: 150,
        left: -70,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.15).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
            ),
          ),
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.08),
                  Colors.transparent,
                ],
                stops: const [0.1, 1.0],
              ),
            ),
          ),
        ),
      ),
      
      // Small floating particles
      Positioned(
        top: 120,
        left: 30,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: TweenSequence<double>([
              TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.0), weight: 1),
              TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 1),
            ]).animate(_animationController),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.05),
              ),
            ),
          ),
        ),
      ),
      
      Positioned(
        bottom: 200,
        right: 40,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0),
            end: const Offset(-0.05, -0.05),
          ).animate(_animationController),
          child: ScaleTransition(
            scale: TweenSequence<double>([
              TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 1),
              TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 1),
            ]).animate(_animationController),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withOpacity(0.05),
              ),
            ),
          ),
        ),
      ),
      
      Positioned(
        top: 250,
        right: 80,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0),
            end: const Offset(0.05, 0.05),
          ).animate(_animationController),
          child: ScaleTransition(
            scale: TweenSequence<double>([
              TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 0.9), weight: 1),
              TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.2), weight: 1),
            ]).animate(_animationController),
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.05),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    Color backgroundColor,
    IconData icon,

    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,

    VoidCallback onTap, {
    Function(bool)? onHover,
    bool isHovered = false,
  }) {
    final bool isSelected = _selectedQuickAction == title;
    return MouseRegion(
      onEnter: (_) => onHover?.call(true),
      onExit: (_) => onHover?.call(false),
      child: AnimatedScale(
        scale: isHovered ? 1.07 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedQuickAction = title;
              });
              onTap();
            },
            borderRadius: BorderRadius.circular(12),
            splashColor: const Color(0xFF6366F1).withOpacity(0.2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : (isHovered ? const Color(0xFF6366F1) : backgroundColor),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected || isHovered)
                        ? const Color(0xFF6366F1).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: (isSelected || isHovered) ? 18 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: (isSelected || isHovered) ? Colors.white : Colors.grey[600],
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: (isSelected || isHovered) ? Colors.white : Colors.grey[700],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

              ),
            ),
          ),
        ),
      ),
    );
  }
}