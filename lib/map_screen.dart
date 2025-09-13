// map_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // TODO: Add actual map API integration (Google Maps, Mapbox, etc.)
  // For now, we'll use a placeholder with interactive elements
  
  bool _isLocationFocused = false;
  
  void _toggleLocationFocus() {
    setState(() {
      _isLocationFocused = !_isLocationFocused;
    });
    
    // TODO: Implement actual location focus functionality with map APIs
    if (_isLocationFocused) {
      // Simulate focusing on driver's location
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Focusing on your location...')),
      );
    }
  }
  
  void _openInMapsApp() async {
    // TODO: Replace with actual coordinates from GPS/API
    const String url = 'https://www.google.com/maps/search/?api=1&query=12.9716,77.5946';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInMapsApp,
            tooltip: 'Open in Maps App',
          ),
        ],
      ),
      body: Stack(
        children: [
          // TODO: Replace with actual map widget (Google Maps, Mapbox, etc.)
          // Placeholder for map - in real implementation, use GoogleMap widget or similar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[100]!, Colors.green[100]!],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Map View',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Live location tracking will be implemented here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Simulated driver marker
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_pin_circle, color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Driver Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Route 15A - Near Central Mall',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Location focus button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleLocationFocus,
              backgroundColor: _isLocationFocused ? Colors.blue : Colors.white,
              child: Icon(
                Icons.my_location,
                color: _isLocationFocused ? Colors.white : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}