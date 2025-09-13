import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityTipsScreen extends StatelessWidget {
  const SecurityTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Tips'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Tips for Drivers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            _buildSecurityTip(
              icon: Icons.lock,
              title: 'Never share your login credentials',
              subtitle: 'Keep your password confidential and change it regularly.',
            ),
            _buildSecurityTip(
              icon: Icons.exit_to_app,
              title: 'Always log out when ending your shift',
              subtitle: 'Prevent unauthorized access by logging out after each shift.',
            ),
            _buildSecurityTip(
              icon: Icons.warning,
              title: 'Report suspicious app behavior immediately',
              subtitle: 'Contact support if you notice any unusual app activity.',
            ),
            _buildSecurityTip(
              icon: Icons.system_update,
              title: 'Keep your device updated and secure',
              subtitle: 'Install security updates and use device encryption.',
            ),
            _buildSecurityTip(
              icon: Icons.emergency,
              title: 'Use the emergency button in dangerous situations',
              subtitle: 'The emergency button immediately alerts authorities.',
            ),

            const SizedBox(height: 30),

            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildEmergencyContact(
              context: context,
              title: 'Dispatch Emergency',
              number: '911',
              subtitle: 'Priority dispatch line',
              icon: Icons.phone,
            ),

            _buildEmergencyContact(
              context: context,
              title: 'Technical Support',
              number: '1-800-TECH-911',
              subtitle: 'Help with app or device issues',
              icon: Icons.support_agent,
            ),

            _buildEmergencyContact(
              context: context,
              title: 'Security Incident',
              number: '*DISPATCH',
              subtitle: 'Report a security incident',
              icon: Icons.security,
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Quick Advice',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'If you feel unsafe, stop in a public, well-lit area, lock your doors, and call the dispatch or emergency services listed above. Never confront an aggressive passenger.'
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAllContactsDialog(context);
                },
                icon: const Icon(Icons.contact_phone),
                label: const Text('View All Contacts'),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTip({required IconData icon, required String title, String? subtitle}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              child: Icon(icon, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact({
    required BuildContext context,
    required String title,
    required String number,
    String? subtitle,
    IconData? icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: icon != null ? Icon(icon) : const Icon(Icons.call),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : Text(number),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy number',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: number));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied $number to clipboard')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Show details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Number: $number'),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text('Info: $subtitle'),
                        ]
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () async {
          // default behaviour: copy number and notify user
          await Clipboard.setData(ClipboardData(text: number));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied $number to clipboard')),
          );
        },
      ),
    );
  }

  void _showAllContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('All Emergency Contacts'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Dispatch Emergency'),
                  subtitle: Text('911'),
                ),
                ListTile(
                  leading: Icon(Icons.support_agent),
                  title: Text('Technical Support'),
                  subtitle: Text('1-800-TECH-911'),
                ),
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Security Incident'),
                  subtitle: Text('*DISPATCH'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
