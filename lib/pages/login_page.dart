import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../database/database_helper.dart';
import '../pages/home_page.dart';
import 'dart:convert';

class ProjectResponse {
  final bool success;
  final String message;
  final List<Project> projects;

  ProjectResponse({
    required this.success,
    required this.message,
    required this.projects,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      projects:
          json['data'] != null
              ? List<Project>.from(json['data'].map((x) => Project.fromJson(x)))
              : [],
    );
  }
}

class Project {
  final String id;
  final String name;
  final int number;
  final int waiting;
  final int processing;
  final String requiresVerification;
  final String requiresCollection;
  final String? remarks;

  Project({
    required this.id,
    required this.name,
    required this.number,
    required this.waiting,
    required this.processing,
    required this.requiresVerification,
    required this.requiresCollection,
    this.remarks,
  });

  factory Project.fromCsv(List<String> values) {
    return Project(
      id: values[0],
      name: values[1],
      number: int.tryParse(values[2]) ?? 0,
      waiting: int.tryParse(values[3]) ?? 0,
      processing: int.tryParse(values[4]) ?? 0,
      requiresVerification: values[5],
      requiresCollection: values[6],
      remarks: values.length > 7 ? values[7] : null,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? 0,
      waiting: json['waiting'] ?? 0,
      processing: json['processing'] ?? 0,
      requiresVerification: json['requiresVerification'] ?? '',
      requiresCollection: json['requiresCollection'] ?? '',
      remarks: json['remarks'],
    );
  }
}

class Config {
  final String logoUrl;
  final String primaryColor;
  final String textColor;
  final String buttonTextColor;
  final String buttonColor;
  final String showEstimatedTime;
  final String showCurrentNumber;
  final String? message;

  Config({
    required this.logoUrl,
    required this.primaryColor,
    required this.textColor,
    required this.buttonTextColor,
    required this.buttonColor,
    required this.showEstimatedTime,
    required this.showCurrentNumber,
    this.message,
  });

  factory Config.fromCsv(List<String> values) {
    return Config(
      logoUrl: values[0],
      primaryColor: values[1],
      textColor: values[2],
      buttonTextColor: values[3],
      buttonColor: values[4],
      showEstimatedTime: values[5],
      showCurrentNumber: values[6],
      message: values.length > 7 ? values[7].trim() : null,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _linkAddressController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  final _databaseHelper = DatabaseHelper();
  List<Project>? _projects;
  String _serverDomain = 'https://singaporeq.com';
  Config? _config;
  String? _logoUrl;
  Color _backgroundColor = const Color(0xFF0066CB); // Default color

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    // Set logo URL immediately
    setState(() {
      _logoUrl = 'https://www.singaporeq.com/images/fdlogo3.jpg';
      print('Logo URL set in initState: $_logoUrl');
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _linkAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await _databaseHelper.getLoginCredentials();
      setState(() {
        _usernameController.text = credentials['username'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
        _linkAddressController.text = credentials['linkAddress'] ?? '';
        _serverDomain = credentials['serverDomain'] ?? 'https://singaporeq.com';
      });
      
      // If we have credentials, try to get the logo
      if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
        await _loadLogoFromApi();
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  Future<void> _loadLogoFromApi() async {
    try {
      final username = _usernameController.text;
      final password = _passwordController.text;
      
      print('Attempting to load logo from API...');
      final response = await http
          .get(
            Uri.parse(
              '$_serverDomain/qapi/aicredit.php?username=$username&password=$password',
            ),
          )
          .timeout(const Duration(seconds: 10));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final configValues = response.body.split(',');
        if (configValues.length >= 2) { // Check if we have at least logo URL and color
          final rawLogoUrl = configValues[0].trim();
          final primaryColor = configValues[1].trim();
          print('Raw Logo URL: $rawLogoUrl');
          print('Primary Color: $primaryColor');
          
          // Always use the full URL from the API response
          final logoUrl = 'https://www.singaporeq.com/images/fdlogo3.jpg';
          
          // Convert hex color string to Color
          final color = Color(int.parse('FF${primaryColor}', radix: 16));
          
          if (mounted) {
            setState(() {
              _logoUrl = logoUrl;
              _backgroundColor = color;
              print('Logo URL set in state: $_logoUrl');
              print('Background color set: $_backgroundColor');
            });
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error loading logo: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final linkAddress = _linkAddressController.text;

      // First, check credits and get logo
      final creditResponse = await http
          .get(
            Uri.parse(
              '$_serverDomain/qapi/aicredit.php?username=$username&password=$password',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (creditResponse.statusCode == 200 && creditResponse.body.isNotEmpty) {
        final configValues = creditResponse.body.split(',');
        if (configValues.length >= 1) {
          // Always use the full URL from the API response
          final logoUrl = 'https://www.singaporeq.com/images/fdlogo3.jpg';
          print('Setting logo URL in handleLogin: $logoUrl');
          await _databaseHelper.saveLogoUrl(logoUrl);
          if (mounted) {
            setState(() => _logoUrl = logoUrl);
          }

          // Now fetch project list
          final projectResponse = await http
              .get(
                Uri.parse(
                  '$_serverDomain/qapi/project-list.php?username=$username&password=$password&link=$linkAddress',
                ),
              )
              .timeout(const Duration(seconds: 10));

          if (projectResponse.statusCode == 200) {
            // Clean up the response by removing <br> tags
            String cleanResponse = projectResponse.body.replaceAll('<br>', '\n');
            final lines = cleanResponse.split('\n');
            if (lines.isNotEmpty) {
              print('Raw API Response (cleaned): $cleanResponse');
              // Parse first line as config
              final configLine = lines[0].trim();
              print('Config Line: $configLine');
              if (configLine.isNotEmpty) {
                final configValues = configLine.split(',');
                if (configValues.length >= 7) {
                  setState(() {
                    _config = Config.fromCsv(configValues);
                  });
                }
              }

              // Parse remaining lines as projects
              final projects = <Project>[];
              for (var i = 1; i < lines.length; i++) {
                final line = lines[i].trim();
                if (line.isNotEmpty && !line.startsWith('____')) {  // Skip the footer line
                  print('Processing project line: $line');
                  final values = line.split(',');
                  if (values.length >= 7) {
                    try {
                      final project = Project.fromCsv(values);
                      print('Successfully parsed project: ${project.id} - ${project.name}');
                      projects.add(project);
                    } catch (e) {
                      print('Error parsing project line: $e');
                      print('Values: ${values.join(', ')}');
                    }
                  } else {
                    print('Invalid project line format: $line');
                  }
                }
              }

              print('Number of projects parsed: ${projects.length}');
              if (projects.isEmpty) {
                _showError('No services available from the server');
                setState(() => _isLoading = false);
                return;
              }

              setState(() => _projects = projects);

              // Save credentials
              await _databaseHelper.saveLoginCredentials(
                username,
                password,
                linkAddress,
              );

              // Navigate to home page with projects and config
              if (mounted) {
                print('Navigating to HomePage with ${projects.length} projects');
                for (var project in projects) {
                  print('Project being passed: ${project.id} - ${project.name}');
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      projects: projects,
                      config: _config,
                    ),
                  ),
                );
              }
            } else {
              _showError('Invalid response from server');
            }
          } else {
            _showError('Failed to fetch projects: ${projectResponse.statusCode}');
          }
        } else {
          _showError('Invalid configuration from server');
        }
      } else {
        _showError('Invalid credentials or server error');
      }
    } catch (e) {
      _showError('Connection error. Please try again.');
      print('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUrl = Uri.parse('https://wa.me/6581515000');
    if (!await launchUrl(whatsappUrl)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  Future<void> _showServerDomainDialog() async {
    final controller = TextEditingController(text: _serverDomain);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Server Domain'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter server domain',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  final newDomain = controller.text.trim();
                  if (newDomain.isNotEmpty) {
                    await _databaseHelper.saveServerDomain(newDomain);
                    setState(() => _serverDomain = newDomain);
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).viewPadding;
    final availableHeight = screenHeight - padding.top - padding.bottom;

    print('Building login page with logo URL: $_logoUrl');

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(height: availableHeight * 0.08),
                      Container(
                        height: availableHeight * 0.20,
                        width: screenWidth * 0.8,
                        child: Image.network(
                          'https://www.singaporeq.com/images/fdlogo3.jpg',
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            print('Logo loading progress: $loadingProgress');
                            if (loadingProgress == null) {
                              print('Logo loaded successfully');
                              return child;
                            }
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3.0,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading logo image: $error');
                            print('Logo error stack trace: $stackTrace');
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white70,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: availableHeight * 0.03),
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.040,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Login Form Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      screenWidth * 0.06,
                    ), // Increased padding
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_errorMessage != null)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: availableHeight * 0.02,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  12,
                                ), // Increased from 8
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize:
                                        screenHeight *
                                        0.018, // Increased from 0.014
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                          // Form fields with responsive spacing
                          ...[
                            // Username, Password, and Link Address fields
                            _buildTextField(
                              controller: _usernameController,
                              label: 'Username',
                              icon: Icons.person,
                              screenHeight: screenHeight,
                              availableHeight: availableHeight,
                            ),
                            SizedBox(height: availableHeight * 0.02),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock,
                              isPassword: true,
                              screenHeight: screenHeight,
                              availableHeight: availableHeight,
                            ),
                            SizedBox(height: availableHeight * 0.02),
                            _buildTextField(
                              controller: _linkAddressController,
                              label: 'Link Address',
                              icon: Icons.link,
                              screenHeight: screenHeight,
                              availableHeight: availableHeight,
                            ),
                          ],

                          SizedBox(height: availableHeight * 0.03),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height:
                                availableHeight * 0.07, // Increased from 0.06
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0066CB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ), // Added padding
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        height: availableHeight * 0.03,
                                        width: availableHeight * 0.03,
                                        child:
                                            const CircularProgressIndicator(),
                                      )
                                      : Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize:
                                              screenHeight *
                                              0.022, // Increased from 0.018
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),

                          // Register link
                          Padding(
                            padding: EdgeInsets.only(
                              top: availableHeight * 0.02,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize:
                                        screenHeight *
                                        0.018, // Increased from 0.015
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Navigate to register page
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ), // Increased from 4
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          screenHeight *
                                          0.018, // Increased from 0.015
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Support Buttons Row
                  Padding(
                    padding: EdgeInsets.only(
                      top: availableHeight * 0.03,
                      bottom: availableHeight * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSupportButton(
                          icon: Icons.dns,
                          label: 'Server',
                          onTap: _showServerDomainDialog,
                          screenHeight: screenHeight,
                        ),
                        _buildSupportButton(
                          icon: Icons.support_agent,
                          label: 'Support',
                          onTap: _launchWhatsApp,
                          screenHeight: screenHeight,
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double screenHeight,
    required double availableHeight,
    bool isPassword = false,
  }) {
    return SizedBox(
      height: availableHeight * 0.07,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white70,
            fontSize: screenHeight * 0.02,
          ),
          hintText: 'Enter your ${label.toLowerCase()}',
          hintStyle: TextStyle(
            color: Colors.white30,
            fontSize: screenHeight * 0.018,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: screenHeight * 0.022, // Increased vertical padding
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white70,
            size: screenHeight * 0.026,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                      size: screenHeight * 0.026,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
        style: TextStyle(color: Colors.white, fontSize: screenHeight * 0.02),
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildSupportButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double screenHeight,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: screenHeight * 0.032),
          SizedBox(height: screenHeight * 0.008),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
