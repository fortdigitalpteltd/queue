import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../pages/login_page.dart';

class ServerSettings extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  ServerSettings({
    super.key,
    required this.controllers,
    required this.toggleStates,
    required this.onToggleChanged,
  }) {
    // Load the server domain from database when widget is created
    _loadServerDomain();
  }

  Future<void> _loadServerDomain() async {
    try {
      final credentials = await _databaseHelper.getLoginCredentials();
      final serverDomain =
          credentials['serverDomain'] ?? 'https://singaporeq.com';

      // Update the controller with the value from database
      if (controllers['serverAddress'] != null) {
        controllers['serverAddress']!.text = serverDomain;
      } else {
        controllers['serverAddress'] = TextEditingController(
          text: serverDomain,
        );
      }
    } catch (e) {
      print('Error loading server domain: $e');
    }
  }

  Future<void> _saveServerDomain(String domain, BuildContext context) async {
    try {
      // Get the current server domain to check if it changed
      final credentials = await _databaseHelper.getLoginCredentials();
      final currentDomain =
          credentials['serverDomain'] ?? 'https://singaporeq.com';

      // Save the new domain
      await _databaseHelper.saveServerDomain(domain);
      print('Server domain saved: $domain');

      // If the domain changed, navigate to login page
      if (domain != currentDomain && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server address changed. Please log in again.'),
            backgroundColor: Colors.orange,
          ),
        );

        // Navigate to login page after a short delay to allow the snackbar to be seen
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      print('Error saving server domain: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('server_settings'),
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Server Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.dns, color: Color(0xFF0066CB)),
                            const SizedBox(width: 12),
                            const Text(
                              'Server Configuration',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0066CB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller:
                              controllers['serverAddress'] ??
                              (controllers['serverAddress'] =
                                  TextEditingController(
                                    text: 'https://singaporeq.com',
                                  )),
                          decoration: InputDecoration(
                            labelText: 'Server Address',
                            hintText: 'https://singaporeq.com',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.link),
                            helperText:
                                'The server domain used for API connections. Changing this will require you to log in again.',
                            isCollapsed: false,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            // We don't save immediately on change, it will be saved when the user clicks the main save button
                            // The main save button will trigger _saveServerDomain which will check if the domain changed
                          },
                          onEditingComplete: () {
                            // Save when user presses enter or done on keyboard
                            final domain =
                                controllers['serverAddress']?.text ??
                                'https://singaporeq.com';
                            _saveServerDomain(domain, context);
                          },
                        ),
                        // Note about server changes
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'Note: Changes to the server address will be applied when you save settings. You will need to log in again if the server address is changed.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
