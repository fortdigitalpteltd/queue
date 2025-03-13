import 'package:flutter/material.dart';
import '../general_components/color_picker_field.dart';
import 'package:http/http.dart' as http;
import '../../../database/database_helper.dart';
import 'dart:convert';

class ButtonSettings extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;
  final Function(void Function()) setState;

  const ButtonSettings({
    super.key,
    required this.controllers,
    required this.toggleStates,
    required this.onToggleChanged,
    required this.setState,
  });

  @override
  State<ButtonSettings> createState() => _ButtonSettingsState();
}

class _ButtonSettingsState extends State<ButtonSettings> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = false;
  String _errorMessage = '';
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    // Remove automatic loading on init
    // _loadButtonDataFromServer();
  }

  Future<void> _loadButtonDataFromServer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _debugInfo = '';
      });

      // Get credentials from database
      final credentials = await _databaseHelper.getLoginCredentials();
      final username = credentials['username'] ?? '';
      final password = credentials['password'] ?? '';
      final linkAddress = credentials['linkAddress'] ?? '';
      final serverDomain =
          credentials['serverDomain'] ?? 'https://singaporeq.com';

      if (username.isEmpty || password.isEmpty || linkAddress.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login credentials not found. Please log in first.';
        });
        return;
      }

      // Fetch data from API
      final url =
          '$serverDomain/qapi/project-list.php?username=$username&password=$password&link=$linkAddress';
      print('Fetching data from: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        print('API Response: $responseBody');

        // Replace HTML <br> tags with actual newlines for proper parsing
        final String cleanedResponse = responseBody.replaceAll('<br>', '\n');
        print('Cleaned Response: $cleanedResponse');

        final List<String> lines = cleanedResponse.split('\n');
        print('Found ${lines.length} lines in response');

        // Debug info to display in UI
        StringBuffer debugBuffer = StringBuffer();
        debugBuffer.writeln('API Response parsed:');

        // Skip the first line (config line)
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty || line.startsWith('____')) continue;

          debugBuffer.writeln('Line $i: $line');

          final parts = line.split(',');
          if (parts.length >= 2) {
            final buttonId = parts[0].trim();
            final buttonTitle = parts[1].trim();
            final buttonSubtitle = parts.length >= 8 ? parts[7].trim() : '';

            debugBuffer.writeln(
              '  ID: $buttonId, Title: $buttonTitle, Subtitle: $buttonSubtitle',
            );

            // Extract button number from ID (e.g., P1 -> 1)
            final buttonNumber = int.tryParse(buttonId.substring(1)) ?? 0;
            if (buttonNumber > 0 && buttonNumber <= 6) {
              // Update controllers directly
              print(
                'Setting button $buttonNumber title to "$buttonTitle" and subtitle to "$buttonSubtitle"',
              );

              // Ensure controllers exist
              if (widget.controllers['buttonFirstTitle$buttonNumber'] == null) {
                widget.controllers['buttonFirstTitle$buttonNumber'] =
                    TextEditingController();
              }
              if (widget.controllers['buttonSecondTitle$buttonNumber'] ==
                  null) {
                widget.controllers['buttonSecondTitle$buttonNumber'] =
                    TextEditingController();
              }

              // Update text directly
              widget.controllers['buttonFirstTitle$buttonNumber']!.text =
                  buttonTitle;
              widget.controllers['buttonSecondTitle$buttonNumber']!.text =
                  buttonSubtitle;

              // Force UI update
              widget.setState(() {});
            }
          }
        }

        setState(() {
          _isLoading = false;
          _debugInfo = debugBuffer.toString();
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load button data: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error loading button data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading button data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Button Drop Down Menu Settings
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
                        Icon(Icons.menu, color: Color(0xFF0066CB)),
                        const SizedBox(width: 12),
                        Text(
                          'Button Drop Down Menu',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0066CB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Dropdown Menu'),
                      subtitle: const Text(
                        'Convert all buttons to a single dropdown menu',
                      ),
                      value: widget.toggleStates['enableDropdownMenu'] ?? false,
                      onChanged: (bool value) {
                        widget.onToggleChanged('enableDropdownMenu', value);
                        widget.setState(() {});
                      },
                    ),
                    if (widget.toggleStates['enableDropdownMenu'] == true) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller:
                            widget.controllers['dropdownMenuTitle'] ??
                            (widget.controllers['dropdownMenuTitle'] =
                                TextEditingController(text: 'Select Service')),
                        decoration: InputDecoration(
                          labelText: 'Dropdown Menu Title',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          helperText: 'Title shown above the dropdown menu',
                        ),
                      ),
                    ],
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Individual Button Settings
            ...List.generate(
              6,
              (index) => Column(
                children: [
                  Card(
                    elevation: 0,
                    color: Colors.grey.shade50,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Text(
                            'Button ${index + 1} Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildButtonContent(index + 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading button data from server...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildButtonContent(int buttonNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service & Titles Section
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
                    const Icon(Icons.settings_applications, color: Color(0xFF0066CB)),
                    const SizedBox(width: 12),
                    const Text(
                      'Service & Titles',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0066CB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:
                      widget.controllers['buttonService$buttonNumber'] ??
                      (widget.controllers['buttonService$buttonNumber'] =
                          TextEditingController(text: 'p$buttonNumber')),
                  decoration: InputDecoration(
                    labelText: 'Button Service Destination',
                    helperText: 'Specifies the service linked to this button',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller:
                      widget.controllers['buttonFirstTitle$buttonNumber'] ??
                      (widget.controllers['buttonFirstTitle$buttonNumber'] =
                          TextEditingController(
                            text: 'Button $buttonNumber Title',
                          )),
                  decoration: InputDecoration(
                    labelText: 'Button First Title',
                    helperText: 'Main title displayed on the button',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller:
                      widget.controllers['buttonSecondTitle$buttonNumber'] ??
                      (widget.controllers['buttonSecondTitle$buttonNumber'] =
                          TextEditingController(text: 'Not set')),
                  decoration: InputDecoration(
                    labelText: 'Button Second Title',
                    helperText: 'Optional second title displayed on the button',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller:
                      widget.controllers['buttonLogo$buttonNumber'] ??
                      (widget.controllers['buttonLogo$buttonNumber'] =
                          TextEditingController(text: 'Not Set')),
                  decoration: InputDecoration(
                    labelText: 'Button Logo',
                    helperText: 'Defines an image or text logo for the button',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Button Colors & Styling Section
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
                    const Icon(Icons.palette, color: Color(0xFF0066CB)),
                    const SizedBox(width: 12),
                    const Text(
                      'Button Colors & Styling',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0066CB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ColorPickerField(
                  controller:
                      widget
                          .controllers['buttonBackgroundColor1_$buttonNumber'] ??
                      (widget.controllers['buttonBackgroundColor1_$buttonNumber'] =
                          TextEditingController(text: '#d3d3d3')),
                  label: 'Background Color 1',
                  defaultColor: '#d3d3d3',
                ),
                const SizedBox(height: 12),
                ColorPickerField(
                  controller:
                      widget
                          .controllers['buttonBackgroundColor2_$buttonNumber'] ??
                      (widget.controllers['buttonBackgroundColor2_$buttonNumber'] =
                          TextEditingController(text: '#D8E6FF')),
                  label: 'Background Color 2',
                  defaultColor: '#D8E6FF',
                ),
                const SizedBox(height: 12),
                ColorPickerField(
                  controller:
                      widget.controllers['buttonTextColor$buttonNumber'] ??
                      (widget.controllers['buttonTextColor$buttonNumber'] =
                          TextEditingController(text: '#000000')),
                  label: 'Text Color',
                  defaultColor: '#000000',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Queue Re-Activation Settings Section
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
                    const Icon(Icons.refresh_rounded, color: Color(0xFF0066CB)),
                    const SizedBox(width: 12),
                    const Text(
                      'Queue Re-Activation Settings',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0066CB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Missed Queue Re-Activation Button'),
                  subtitle: const Text(
                    'Enable/disable button for reactivating missed queue',
                  ),
                  value:
                      widget
                          .toggleStates['buttonMissedQueueReactivation$buttonNumber'] ??
                      false,
                  onChanged: (bool value) {
                    widget.onToggleChanged(
                      'buttonMissedQueueReactivation$buttonNumber',
                      value,
                    );
                  },
                ),
                if (widget
                        .toggleStates['buttonMissedQueueReactivation$buttonNumber'] ==
                    true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller:
                          widget
                              .controllers['buttonMissedQueueLabel$buttonNumber'] ??
                          (widget.controllers['buttonMissedQueueLabel$buttonNumber'] =
                              TextEditingController(
                                text: 'Missed Q Click Here',
                              )),
                      decoration: InputDecoration(
                        labelText: 'Missed Queue Re-Activation Button Label',
                        helperText: 'Custom label for the reactivation button',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Display Options Section
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
                    const Icon(Icons.visibility, color: Color(0xFF0066CB)),
                    const SizedBox(width: 12),
                    const Text(
                      'Display Options',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0066CB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Show Waiting Time'),
                  value:
                      widget
                          .toggleStates['buttonShowWaitingTime$buttonNumber'] ??
                      false,
                  onChanged: (bool value) {
                    widget.onToggleChanged(
                      'buttonShowWaitingTime$buttonNumber',
                      value,
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Ticket Behind'),
                  value:
                      widget
                          .toggleStates['buttonShowTicketBehind$buttonNumber'] ??
                      false,
                  onChanged: (bool value) {
                    widget.onToggleChanged(
                      'buttonShowTicketBehind$buttonNumber',
                      value,
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Convert Second Field to Drop Down Menu'),
                  value:
                      widget
                          .toggleStates['buttonConvertToDropdown$buttonNumber'] ??
                      false,
                  onChanged: (bool value) {
                    widget.onToggleChanged(
                      'buttonConvertToDropdown$buttonNumber',
                      value,
                    );
                  },
                ),
                if (widget
                        .toggleStates['buttonConvertToDropdown$buttonNumber'] ==
                    true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller:
                          widget
                              .controllers['buttonDropdownChoices$buttonNumber'] ??
                          (widget.controllers['buttonDropdownChoices$buttonNumber'] =
                              TextEditingController(text: '1,2')),
                      decoration: InputDecoration(
                        labelText: 'Drop Down Menu Choices',
                        helperText:
                            'Comma-separated list of choices (e.g., 1,2)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
