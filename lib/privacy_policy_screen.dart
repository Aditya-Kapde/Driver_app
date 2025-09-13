import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How we protect and handle your personal information',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Information We Collect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBulletPoint('Driver identification and employment details'),
            _buildBulletPoint('Route and schedule information'),
            _buildBulletPoint('GPS location data during shifts'),
            _buildBulletPoint('App usage and performance data'),
            _buildBulletPoint('Reports and incident documentation'),
            
            const Divider(height: 30),
            
            const Text(
              'How We Use Your Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBulletPoint('Optimize bus routes and schedules'),
            _buildBulletPoint('Monitor driver safety and performance'),
            _buildBulletPoint('Improve public transportation services'),
            _buildBulletPoint('Comply with transportation regulations'),
            _buildBulletPoint('Provide technical support'),
            
            const Divider(height: 30),
            
            const Text(
              'Data Sharing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('We share your information only with:'),
            _buildBulletPoint('Your transportation authority or employer'),
            
            const SizedBox(height: 30),
            
            const Text(
              'Data Protection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBulletPoint('All data is encrypted in transit and at rest'),
            _buildBulletPoint('Regular security audits and penetration testing'),
            _buildBulletPoint('Access controls and authentication protocols'),
            _buildBulletPoint('Data retention policies in compliance with regulations'),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}