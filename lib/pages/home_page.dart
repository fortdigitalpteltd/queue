import 'package:flutter/material.dart';
import 'package:queue_system/pages/settings_page.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import './phone_number_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _openSettings() async {
    final currentPassword = await _databaseHelper.getSettings().then(
      (settings) => settings['settingLoginPassword'] ?? '',
    );

    if (!mounted) return;

    if (currentPassword.isEmpty) {
      // If no password is set, directly navigate to settings
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
      return;
    }

    final authenticated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildPasswordDialog(currentPassword);
      },
    );

    if (authenticated == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsPage(isPreAuthenticated: true),
        ),
      );
    }
  }

  Widget _buildPasswordDialog(String currentPassword) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: const Color(0xFF0066CB), size: 28),
          const SizedBox(width: 12),
          const Text(
            'Settings Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0066CB),
            ),
          ),
        ],
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter your password to access settings',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF0066CB),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade400),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF0066CB)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value != currentPassword) {
                    return 'Incorrect password';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Cancel', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop(true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066CB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEE, d MMM yyyy HH:mm:ss').format(_currentTime);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0066CB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Logo
                Image.asset(
                  'assets/images/fd_logo_transparent.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                // Queue Registration Text
                const Text(
                  'Queue Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Date and Time
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                // Select Service Text
                const Text(
                  'Select Service',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Your button grid or list will go here
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () async {
                              final phoneNumber = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhoneNumberPage(
                                    serviceTitle: 'Button ${index + 1} Title',
                                  ),
                                ),
                              );
                              
                              if (phoneNumber != null) {
                                // TODO: Handle the phone number submission
                                // You can process the queue registration here
                              }
                            },
                            child: Center(
                              child: Text(
                                'Button ${index + 1}\nTitle',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
