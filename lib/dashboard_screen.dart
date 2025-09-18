import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'theme_notifier.dart';
import 'setup_profile_personal_screen.dart';
import 'sos_emergency_screen.dart';
import 'trip_history_screen.dart';
import 'journey_planner_screen.dart';
import 'settings_screen.dart';
import 'support_center_screen.dart';
import 'bus_schedule_screen.dart';

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

  final Map<String, bool> _hoverStates = {
    'Start Trip': false,
    'Support': false,
    'Schedule': false,
    'Journey Planner': false,
  };

  bool _isFabExpanded = false;
  String _selectedQuickAction = '';
  bool _isLoading = false;

  // Dashboard data
  Map<String, dynamic> _driverStats = {
    'todayHours': '0h',
    'distance': '0 km',
    'earnings': '₹0',
    'activeRoute': null,
    'currentLocation': 'Unknown'
  };

  // Crowd level state
  String _crowdLevel = 'Medium';
  final List<String> _crowdLevels = ['Low', 'Medium', 'High'];

  final TextEditingController _searchController = TextEditingController();
  final List<String> _features = [
    'Start Trip',
    'Support',
    'Schedule',
    'Journey Planner',
    'Setup Profile',
    'SOS Emergency',
  ];
  List<String> _filteredFeatures = [];

  // Driver's vehicle number
  String? _vehicleNumber;

  // API endpoints
  static const String BASE_URL = String.fromEnvironment('BASE_URL',
      defaultValue: 'http://localhost:8080/api');
  static const String WS_URL = String.fromEnvironment('WS_URL',
      defaultValue: 'ws://localhost:8080/trip/socket');
  static const String DASHBOARD_STATS_ENDPOINT = '$BASE_URL/driver/stats';
  static const String ACTIVE_ROUTE_ENDPOINT = '$BASE_URL/driver/active-route';
  static const String START_TRIP_ENDPOINT = '$BASE_URL/trips/start';
  static const String DRIVER_PROFILE_ENDPOINT = '$BASE_URL/driver/profile';

  // WebSocket for live location
  WebSocketChannel? _wsChannel;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat(reverse: true);
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.05, 0.05),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _searchController.addListener(_onSearchChanged);
    _filteredFeatures = _features;

    _loadDriverProfile();
    _checkLocationPermission();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _locationTimer?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }

  // Check and request location permission
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }

  // Load driver profile to get vehicleNumber
  Future<void> _loadDriverProfile() async {
    try {
      final storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');

      if (accessToken == null) {
        return;
      }

      final response = await http.get(
        Uri.parse(DRIVER_PROFILE_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        setState(() {
          _vehicleNumber = profileData['vehicleNumber'];
        });
      } else {
        print('Failed to load driver profile: ${response.body}');
      }
    } catch (e) {
      print('Error loading driver profile: $e');
    }
  }

  // Select a vehicle from BusScheduleScreen
  Future<void> _selectVehicle() async {
    final result = await Navigator.pushNamed(context, '/bus_schedule');
    if (result != null && result is Map<String, String>) {
      setState(() {
        _vehicleNumber = result['vehicleNumber'];
      });
    }
  }

  // Load dashboard data from backend
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to view dashboard'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Fetch dashboard statistics
      final statsResponse = await http.get(
        Uri.parse(DASHBOARD_STATS_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (statsResponse.statusCode == 200) {
        final statsData = json.decode(statsResponse.body);
        setState(() {
          _driverStats = {
            ..._driverStats,
            'todayHours':
                '${(statsData['todayHours'] ?? 0.0).toStringAsFixed(1)}h',
            'distance': '${statsData['todayDistance'] ?? '0'} km',
            'earnings': '₹${statsData['todayEarnings'] ?? '0'}',
          };
        });
      }

      // Fetch active route
      final routeResponse = await http.get(
        Uri.parse(ACTIVE_ROUTE_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (routeResponse.statusCode == 200) {
        final routeData = json.decode(routeResponse.body);
        if (routeData['hasActiveRoute'] == true) {
          setState(() {
            _driverStats['activeRoute'] = routeData['activeRoute'];
            _driverStats['currentLocation'] =
                routeData['currentLocation'] ?? 'Unknown';
          });
        } else {
          setState(() {
            _driverStats['activeRoute'] = null;
            _driverStats['currentLocation'] = 'Unknown';
          });
        }
      }
    } catch (e) {
      print('Failed to load dashboard data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load dashboard: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Start a new trip and setup WebSocket for live location sharing
  Future<void> _startTrip() async {
    if (_vehicleNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle from the schedule.'),
          backgroundColor: Colors.orange,
        ),
      );
      await _selectVehicle();
      if (_vehicleNumber == null) return;
    }

    setState(() => _isLoading = true);

    try {
      final storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to start a trip'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Prepare trip data for POST request
      final tripData = {
        'vehicleNumber': _vehicleNumber,
        'startTime': DateTime.now().toUtc().toIso8601String(),
      };

      // Send POST request to start trip
      final response = await http.post(
        Uri.parse(START_TRIP_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(tripData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip started successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Connect WebSocket
        _wsChannel = WebSocketChannel.connect(
          Uri.parse('$WS_URL?token=$accessToken'),
        );

        _wsChannel!.stream.listen(
          (message) {
            print('Received WebSocket message: $message');
            // Update current location in driverStats
            try {
              final data = json.decode(message);
              if (data['latitude'] != null && data['longitude'] != null) {
                setState(() {
                  _driverStats['currentLocation'] =
                      'Lat: ${data['latitude']}, Lng: ${data['longitude']}';
                });
              }
            } catch (e) {
              print('Error parsing WebSocket message: $e');
            }
          },
          onError: (error) {
            print('WebSocket error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('WebSocket error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
          onDone: () {
            print('WebSocket disconnected');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('WebSocket disconnected'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        );

        // Send initial WebSocket message with location
        final initialLocationData = {
          'vehicleNumber': _vehicleNumber,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        };
        _wsChannel!.sink.add(json.encode(initialLocationData));

        // Send periodic location updates
        _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
          try {
            Position updatedPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);
            final locationData = {
              'vehicleNumber': _vehicleNumber,
              'latitude': updatedPosition.latitude,
              'longitude': updatedPosition.longitude,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            };
            _wsChannel!.sink.add(json.encode(locationData));
            print(
                'Sent location to WebSocket: (${updatedPosition.latitude}, ${updatedPosition.longitude})');
            setState(() {
              _driverStats['currentLocation'] =
                  'Lat: ${updatedPosition.latitude}, Lng: ${updatedPosition.longitude}';
            });
          } catch (e) {
            print('Error sending location update: $e');
          }
        });

        await _loadDashboardData();
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Failed to start trip';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Failed to start trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start trip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.pushNamed(context, '/journey_planner');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/trip_history');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/setup_profile_personal');
    }
  }

  void _setHoverState(String buttonName, bool isHovering) {
    setState(() => _hoverStates[buttonName] = isHovering);
  }

  void _onSearchChanged() {
    setState(() {
      final q = _searchController.text.toLowerCase();
      _filteredFeatures =
          _features.where((f) => f.toLowerCase().contains(q)).toList();
    });
  }

  void _onFeatureTap(String feature) {
    switch (feature) {
      case 'Start Trip':
        _startTrip();
        break;
      case 'Support':
        Navigator.pushNamed(context, '/support_center');
        break;
      case 'Schedule':
        _selectVehicle();
        break;
      case 'Journey Planner':
        Navigator.pushNamed(context, '/journey_planner');
        break;
      case 'Setup Profile':
        Navigator.pushNamed(context, '/setup_profile_personal');
        break;
      case 'SOS Emergency':
        Navigator.pushNamed(context, '/sos_emergency');
        break;
    }
    _searchController.clear();
    _filteredFeatures = _features;
  }

  // Helper methods for crowd level
  Color _getCrowdLevelColor() {
    switch (_crowdLevel) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCrowdLevelIcon() {
    switch (_crowdLevel) {
      case 'Low':
        return Icons.people_outline;
      case 'Medium':
        return Icons.people;
      case 'High':
        return Icons.people_alt;
      default:
        return Icons.people_outline;
    }
  }

  // The rest of the build method and other unchanged methods remain as in the original code
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeNotifier>().isDarkMode;
    final cardColor = theme.cardColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final onCard = theme.colorScheme.onSurface.withOpacity(0.7);

    // Compute brand pill colors
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color pillBg = dark
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.35)
        : theme.colorScheme.primary.withOpacity(0.18);
    final Color pillBorder = dark
        ? theme.colorScheme.onSurface.withOpacity(0.15)
        : theme.colorScheme.primary.withOpacity(0.25);
    final Color pillForeground =
        dark ? theme.colorScheme.onSurface : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final base = isDark
                  ? [
                      const Color(0xFF1F2330),
                      const Color(0xFF1A1F2B),
                      const Color(0xFF182026),
                    ]
                  : const [
                      Color(0xFFE1F5FE),
                      Color(0xFFF3E5F5),
                      Color(0xFFE8F5E9),
                    ];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: base,
                    stops: [0.0, 0.5 + _animationController.value * 0.1, 1.0],
                  ),
                ),
              );
            },
          ),

          ..._buildFloatingParticles(),

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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: pillBorder, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_shipping,
                                color: pillForeground, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'DriverPortal',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: pillForeground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Tooltip(
                        message: isDark ? 'Switch to light' : 'Switch to dark',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () =>
                              context.read<ThemeNotifier>().toggleTheme(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
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
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/sos_emergency');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow( // ✅ correct widget
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 2,
      blurRadius: 5,
      offset: Offset(0, 3),
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
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
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
                        Icon(Icons.search, color: onCard, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: theme.textTheme.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: 'Search routes, locations, features...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (_filteredFeatures.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
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
                        children: _filteredFeatures
                            .map((feature) => ListTile(
                                  title: Text(feature,
                                      style: theme.textTheme.bodyMedium),
                                  onTap: () => _onFeatureTap(feature),
                                ))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Active Route card
                  if (_driverStats['activeRoute'] != null)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Active Route',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(color: theme.hintColor)),
                                    const SizedBox(height: 2),
                                    Text(
                                        _driverStats['activeRoute']['name'] ??
                                            'Unknown Route',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Next Stop',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(color: theme.hintColor)),
                                  const SizedBox(height: 2),
                                  Text(
                                      _driverStats['activeRoute']['nextStop'] ??
                                          'Unknown Stop',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.place_outlined,
                                  size: 16,
                                  color: theme.hintColor.withOpacity(0.9)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Current Location',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(color: theme.hintColor)),
                                    const SizedBox(height: 2),
                                    Text(_driverStats['currentLocation'],
                                        style: theme.textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Crowd Level Toggle Section
                  Row(
                    children: [
                      Icon(_getCrowdLevelIcon(),
                          size: 16, color: _getCrowdLevelColor()),
                      const SizedBox(width: 6),
                      Text('Crowd Level',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: theme.hintColor)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCrowdLevelColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getCrowdLevelColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _crowdLevels.map((level) {
                            final isSelected = level == _crowdLevel;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _crowdLevel = level);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _getCrowdLevelColor()
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  level,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : _getCrowdLevelColor(),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Today\'s Hours',
                            _driverStats['todayHours'], Colors.green, Icons.access_time),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Distance', _driverStats['distance'],
                            theme.colorScheme.primary, Icons.navigation_outlined),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: _buildStatCard('Earnings', _driverStats['earnings'],
                            Colors.purple, Icons.account_balance_wallet),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text('Quick Actions',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionButton(
                                'Start Trip',
                                _hoverStates['Start Trip']!
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                Icons.navigation,
                                _startTrip,
                                onHover: (h) => _setHoverState('Start Trip', h),
                                isHovered: _hoverStates['Start Trip']!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionButton(
                                'Support',
                                _hoverStates['Support']!
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                Icons.headset_mic_outlined,
                                () => Navigator.pushNamed(context, '/support_center'),
                                onHover: (h) => _setHoverState('Support', h),
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
                                'Schedule',
                                _hoverStates['Schedule']!
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                Icons.schedule,
                                _selectVehicle,
                                onHover: (h) => _setHoverState('Schedule', h),
                                isHovered: _hoverStates['Schedule']!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionButton(
                                'Settings',
                                _hoverStates['Journey Planner']!
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                Icons.settings,
                                () => Navigator.pushNamed(context, '/settings'),
                                onHover: (h) => _setHoverState('Journey Planner', h),
                                isHovered: _hoverStates['Journey Planner']!,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(isDark ? 0.2 : 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.bug_report, color: Colors.amber, size: 24),
                        const SizedBox(height: 8),
                        Text('Testing Mode',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/journey_planner');
                          },
                          child: const Text('Go to Journey Planner'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
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
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.hintColor,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.route_outlined),
                activeIcon: Icon(Icons.route),
                label: 'Routes'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history),
                label: 'Trip History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Setup Profile'),
          ],
        ),
      ),
      floatingActionButton: _buildFabMenu(context),
    );
  }

  Widget _buildFabMenu(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isFabExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 120, right: 8),
            child: FloatingActionButton(
              heroTag: 'sos_fab',
              backgroundColor: Colors.red,
              onPressed: () {
                Navigator.pushNamed(context, '/sos_emergency');
                setState(() => _isFabExpanded = false);
              },
              child: const Icon(Icons.emergency_outlined, color: Colors.white),
            ),
          ),
        if (_isFabExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 60, right: 8),
            child: FloatingActionButton(
              heroTag: 'location_fab',
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.pushNamed(context, '/journey_planner');
                setState(() => _isFabExpanded = false);
              },
              child: const Icon(Icons.location_on, color: Colors.white),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: FloatingActionButton(
            heroTag: 'menu_fab',
            backgroundColor: theme.colorScheme.surface,
            onPressed: () {
              setState(() => _isFabExpanded = !_isFabExpanded);
            },
            child: Icon(Icons.menu, color: theme.colorScheme.primary, size: 32),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingParticles() {
    return [
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
          scale: Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
          )),
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
      Positioned(
        top: 120,
        left: 30,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 1),
              TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 1),
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
                  begin: const Offset(0, 0), end: const Offset(-0.05, -0.05))
              .animate(_animationController),
          child: ScaleTransition(
            scale: TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
              TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
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
                  begin: const Offset(0, 0), end: const Offset(0.05, 0.05))
              .animate(_animationController),
          child: ScaleTransition(
            scale: TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 1),
              TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.2), weight: 1),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
          ]),
          const SizedBox(height: 12),
          Text(title,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    Color backgroundColor,
    IconData icon,
    VoidCallback onTap, {
    Function(bool)? onHover,
    bool isHovered = false,
  }) {
    final bool isSelected = _selectedQuickAction == title;
    final theme = Theme.of(context);
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
              setState(() => _selectedQuickAction = title);
              onTap();
            },
            borderRadius: BorderRadius.circular(12),
            splashColor: theme.colorScheme.primary.withOpacity(0.2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isHovered
                        ? theme.colorScheme.primary
                        : backgroundColor),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected || isHovered)
                        ? theme.colorScheme.primary.withOpacity(0.3)
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
                    color: (isSelected || isHovered)
                        ? Colors.white
                        : theme.iconTheme.color,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: (isSelected || isHovered)
                          ? Colors.white
                          : theme.textTheme.labelLarge?.color,
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