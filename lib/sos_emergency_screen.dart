import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SosEmergencyScreen extends StatefulWidget {
  const SosEmergencyScreen({super.key});

  @override
  State<SosEmergencyScreen> createState() => _SosEmergencyScreenState();
}

class _SosEmergencyScreenState extends State<SosEmergencyScreen> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Emergency'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: const Icon(
                      Icons.emergency,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Emergency',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Emergency Services
            const Text(
              'Emergency Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Medical Emergency
            _buildEmergencyCard(
              icon: Icons.local_hospital,
              title: 'Medical Emergency',
              subtitle: 'Call ambulance service',
              phoneNumber: '108',
              color: Colors.red,
            ),
            const SizedBox(height: 12),

            // Police
            _buildEmergencyCard(
              icon: Icons.security,
              title: 'Police',
              subtitle: 'Report incidents or crimes',
              phoneNumber: '100',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),

            // Fire Service
            _buildEmergencyCard(
              icon: Icons.fire_extinguisher,
              title: 'Fire Service',
              subtitle: 'Fire emergencies',
              phoneNumber: '101',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),

            // Bus Control Room
            _buildEmergencyCard(
              icon: Icons.directions_bus,
              title: 'Bus Control Room',
              subtitle: 'Report bus-related emergencies',
              phoneNumber: '+91 123 456 7890',
              color: Colors.green,
            ),

            const SizedBox(height: 32),

            // Location Information
            const Text(
              'Your Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route 15A - City Center',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Last Stop: Central Mall',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GPS: 12.9716° N, 77.5946° E',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Share location functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing location...')),
                        );
                      },
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Emergency Instructions
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Instructions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Stay calm and provide clear information\n'
                      '• Share your exact location\n'
                      '• Describe the emergency clearly\n'
                      '• Follow operator instructions\n'
                      '• Stay on the line until help arrives',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String phoneNumber,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: () => _makePhoneCall(phoneNumber),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(phoneNumber),
        ),
      ),
    );
  }
}