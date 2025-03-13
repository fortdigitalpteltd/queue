import 'package:flutter/material.dart';
import 'package:queue_system/pages/settings_page.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import './phone_number_page.dart';
import './login_page.dart';

class HomePage extends StatefulWidget {
  final List<Project>? projects;
  final Config? config;

  const HomePage({super.key, this.projects, this.config});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late DateTime _currentTime;
  late Timer _timer;
  Map<String, String> _settings = {};
  bool _isLoading = true;
  List<Widget> _projectButtons = []; // Cache the buttons

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    // Load settings once at init
    _loadSettings().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _createButtons(); // Create buttons once after loading settings

          // Debug log only once after initial load
          print('Debug: Initializing HomePage');
          print(
            'Projects received in HomePage: ${widget.projects?.length ?? 0}',
          );
          print(
            'Total activated buttons setting: ${_settings['totalActivatedButtons']}',
          );

          if (widget.projects != null) {
            print('Projects list:');
            for (var project in widget.projects!) {
              print(
                'Project: ${project.name}, Waiting: ${project.waiting}, ID: ${project.id}',
              );
            }
          } else {
            print('No projects provided, should show default buttons');
          }
        });
      }
    });
  }

  void _createButtons() {
    final List<Widget> buttons = [];
    final totalButtons =
        int.tryParse(_settings['totalActivatedButtons'] ?? '6') ?? 6;
    print('Debug: Total buttons to show: $totalButtons');

    if (widget.projects == null || widget.projects!.isEmpty) {
      print('Debug: Creating default buttons');
      for (int i = 1; i <= totalButtons; i++) {
        print('Debug: Creating default button $i');
        buttons.add(_createDefaultButton(i));
      }
    } else {
      print('Debug: Creating buttons from projects');
      final Set<int> usedIndices = {};

      for (var project in widget.projects!) {
        final buttonIndex = int.tryParse(project.id.substring(1)) ?? 1;

        if (buttons.length >= totalButtons || buttonIndex > totalButtons) {
          print('Debug: Skipping project ${project.name}');
          continue;
        }

        print(
          'Debug: Creating button from project: ${project.name}, index: $buttonIndex',
        );
        usedIndices.add(buttonIndex);
        buttons.add(_createProjectButton(project, buttonIndex));
      }

      for (int i = 1; i <= totalButtons; i++) {
        if (!usedIndices.contains(i)) {
          print('Debug: Adding additional default button $i');
          buttons.add(_createDefaultButton(i));
        }
      }
    }

    _projectButtons = buttons;
  }

  // Helper method to get border radius based on settings
  double _getButtonBorderRadius() {
    final isRoundButton = _settings['roundButton']?.toLowerCase() == 'true';
    return isRoundButton ? 15.0 : 0.0;
  }

  // New method to create a project button
  Widget _createProjectButton(Project project, int buttonIndex) {
    final bigButtonsTextSize =
        double.tryParse(_settings['bigButtonsTextSize'] ?? '') ?? 24.0;
    final bigButtonsSecondTitleSize =
        double.tryParse(_settings['bigButtonsSecondTitleSize'] ?? '') ?? 14.0;
    final waitingTimeFontSize =
        double.tryParse(_settings['waitingTimeFontSize'] ?? '') ?? 14.0;
    final borderRadius = _getButtonBorderRadius();
    final isDropdown = _settings['enableDropdownMenu']?.toLowerCase() == 'true';

    // Parse dropdown items if enabled
    List<String> dropdownItems = [];
    if (isDropdown) {
      final items = _settings['buttonDropdownItems$buttonIndex'] ?? '';
      dropdownItems =
          items.split('\n').where((item) => item.trim().isNotEmpty).toList();
      if (dropdownItems.isEmpty) {
        dropdownItems = [project.name]; // Use project name as default item
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        key: ValueKey(project.id),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient:
                _getButtonBackgroundColor(buttonIndex) == Colors.transparent
                    ? _getButtonGradient(buttonIndex)
                    : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getButtonBackgroundColor(buttonIndex),
                        _getButtonBackgroundColor(buttonIndex),
                      ],
                    ),
          ),
          child: Material(
            color: Colors.transparent,
            child:
                isDropdown
                    ? _buildDropdownButton(
                      buttonIndex,
                      dropdownItems,
                      bigButtonsTextSize,
                      bigButtonsSecondTitleSize,
                      waitingTimeFontSize,
                      borderRadius,
                    )
                    : InkWell(
                      borderRadius: BorderRadius.circular(borderRadius),
                      onTap: () async {
                        final phoneNumber = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PhoneNumberPage(serviceTitle: project.name),
                          ),
                        );

                        if (phoneNumber != null) {
                          // TODO: Handle the phone number submission
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    project.name,
                                    style: TextStyle(
                                      fontSize: bigButtonsTextSize,
                                      fontWeight: FontWeight.w600,
                                      color: _getButtonTextColor(buttonIndex),
                                    ),
                                  ),
                                  if (project.remarks?.isNotEmpty == true) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      project.remarks!,
                                      style: TextStyle(
                                        fontSize: bigButtonsSecondTitleSize,
                                        color: _getButtonTextColor(buttonIndex),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (widget.config?.showEstimatedTime
                                        .toLowerCase() ==
                                    'y' ||
                                widget.config?.showCurrentNumber
                                        .toLowerCase() ==
                                    'y') ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.config?.showEstimatedTime
                                                .toLowerCase() ==
                                            'y' &&
                                        project.waiting > 0) ...[
                                      Text(
                                        '~${project.waiting * 5} min',
                                        style: TextStyle(
                                          fontSize: waitingTimeFontSize,
                                          fontWeight: FontWeight.w500,
                                          color: _getWaitingTimeColor(),
                                        ),
                                      ),
                                    ],
                                    if (widget.config?.showCurrentNumber
                                                .toLowerCase() ==
                                            'y' &&
                                        project.waiting > 0) ...[
                                      if (widget.config?.showEstimatedTime
                                              .toLowerCase() ==
                                          'y')
                                        const SizedBox(height: 4),
                                      Text(
                                        '${project.waiting} ahead',
                                        style: TextStyle(
                                          fontSize: waitingTimeFontSize,
                                          fontWeight: FontWeight.w500,
                                          color: _getWaitingTimeColor(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadSettings() async {
    final settings = await _databaseHelper.getSettings();
    if (mounted) {
      setState(() {
        _settings = settings;
      });
    }
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
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
      if (result == true) {
        _loadSettings(); // Reload settings if changes were saved
      }
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
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsPage(isPreAuthenticated: true),
        ),
      );
      if (result == true) {
        _loadSettings(); // Reload settings if changes were saved
      }
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

  Color _getButtonBackgroundColor(int buttonIndex) {
    try {
      // First check if button has specific background colors for gradient
      final color1 = _settings['buttonBackgroundColor1_$buttonIndex'];
      final color2 = _settings['buttonBackgroundColor2_$buttonIndex'];

      // If button has specific colors set, return transparent to use gradient
      if (color1 != null &&
          color1.isNotEmpty &&
          color2 != null &&
          color2.isNotEmpty) {
        return Colors.transparent;
      }

      // If no specific colors, try to get the global background color
      final globalColor =
          _settings['sixBigButtonsBackgroundColor'] ?? '#FFFFFF';
      if (globalColor.isNotEmpty) {
        return Color(int.parse(globalColor.replaceAll('#', '0xFF')));
      }

      // If no global color either, return transparent to use default gradient
      return Colors.transparent;
    } catch (e) {
      return Colors.transparent;
    }
  }

  Gradient _getButtonGradient(int buttonIndex) {
    try {
      final color1 =
          _settings['buttonBackgroundColor1_$buttonIndex'] ?? '#d3d3d3';
      final color2 =
          _settings['buttonBackgroundColor2_$buttonIndex'] ?? '#D8E6FF';

      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(int.parse(color1.replaceAll('#', '0xFF'))),
          Color(int.parse(color2.replaceAll('#', '0xFF'))),
        ],
      );
    } catch (e) {
      print('Error creating gradient for button $buttonIndex: $e');
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFd3d3d3), Color(0xFFD8E6FF)],
      );
    }
  }

  Color _getButtonTextColor(int buttonIndex) {
    try {
      // First try to get button-specific text color
      final color = _settings['buttonTextColor$buttonIndex'] ?? '#000000';
      // If not set, fall back to global button text color
      final globalColor = _settings['buttonTextFontColor'] ?? '#000000';
      return Color(
        int.parse(
          (color.isEmpty ? globalColor : color).replaceAll('#', '0xFF'),
        ),
      );
    } catch (e) {
      return Colors.black87;
    }
  }

  Color _getTitleFontColor() {
    try {
      final color = _settings['titleFontColor'] ?? '#FFFFFF';
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0066CB),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Check if dropdown menu is enabled
    final isDropdownEnabled =
        _settings['enableDropdownMenu']?.toLowerCase() == 'true';

    // Collect all available services if dropdown is enabled
    List<String> allServices = [];
    if (isDropdownEnabled) {
      if (widget.projects != null && widget.projects!.isNotEmpty) {
        // If we have projects, use their names
        allServices = widget.projects!.map((p) => p.name).toList();
      } else {
        // Otherwise collect services from button settings
        final totalButtons =
            int.tryParse(_settings['totalActivatedButtons'] ?? '6') ?? 6;
        for (int i = 1; i <= totalButtons; i++) {
          final buttonTitle = _settings['buttonFirstTitle$i'];
          if (buttonTitle != null && buttonTitle.isNotEmpty) {
            allServices.add(buttonTitle);
          }
        }
      }
      // If no services found, add default
      if (allServices.isEmpty) {
        allServices = ['Service 1', 'Service 2', 'Service 3'];
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background container
          Container(
            decoration: BoxDecoration(
              image:
                  _settings['backgroundImageUrl']?.isNotEmpty == true
                      ? DecorationImage(
                        image: NetworkImage(_settings['backgroundImageUrl']!),
                        fit: BoxFit.cover,
                      )
                      : null,
              gradient:
                  _settings['backgroundImageUrl']?.isNotEmpty != true
                      ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0066CB), Color(0xFF004C96)],
                      )
                      : null,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Image.network(
                          widget.config?.logoUrl ??
                              'https://singaporeq.com/images/fdlogo3.jpg',
                          height:
                              double.tryParse(_settings['logoSize'] ?? '') ??
                              80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          (_settings['ticketPrintSubtitle']?.toLowerCase() ==
                                      'true' &&
                                  _settings['ticketPrintSubtitleLabel']
                                          ?.isNotEmpty ==
                                      true)
                              ? _settings['ticketPrintSubtitleLabel']!
                              : 'Queue Registration',
                          style: TextStyle(
                            color: _getTitleFontColor(),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat(
                            'EEE, d MMM yyyy HH:mm:ss',
                          ).format(_currentTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _settings['selectServiceTitle']?.isNotEmpty == true
                              ? _settings['selectServiceTitle']!
                              : 'Select Service',
                          style: TextStyle(
                            color: _getTitleFontColor(),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (isDropdownEnabled) ...[
                          // Single dropdown menu for all services
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      popupMenuTheme: PopupMenuThemeData(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        elevation: 8,
                                        color: Colors.white,
                                        textStyle: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    child: PopupMenuButton<String>(
                                      offset: const Offset(0, 10),
                                      position: PopupMenuPosition.under,
                                      constraints: BoxConstraints(
                                        minWidth:
                                            MediaQuery.of(context).size.width -
                                            40,
                                        maxWidth:
                                            MediaQuery.of(context).size.width -
                                            40,
                                      ),
                                      onSelected:
                                          (String service) =>
                                              _handleButtonTap(1, service),
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          ...allServices.map((String service) {
                                            return PopupMenuItem<String>(
                                              value: service,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF0066CB,
                                                        ).withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        color: Color(
                                                          0xFF0066CB,
                                                        ),
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        service,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ];
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _settings['dropdownMenuTitle'] ??
                                                        'Select Service',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black87
                                                          .withOpacity(0.7),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${allServices.length} services available',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF0066CB,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: Color(0xFF0066CB),
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Original button list
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: ListView(
                                key: const ValueKey('project_list'),
                                children: _projectButtons,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings button in top-right corner
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                10, // Account for status bar
            right: 10, // Position on the right side
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                popupMenuTheme: PopupMenuThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.settings, color: Colors.transparent),
                offset: const Offset(0, 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem<String>(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: const Color(0xFF0066CB),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            const Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                onSelected: (value) async {
                  if (value == 'settings') {
                    await _openSettings();
                    await _loadSettings();
                    if (mounted) {
                      setState(() {
                        _createButtons(); // Recreate buttons after settings change
                      });
                    }
                  } else if (value == 'logout') {
                    // Navigate to login page
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create a default button
  Widget _createDefaultButton(int index) {
    final bigButtonsTextSize =
        double.tryParse(_settings['bigButtonsTextSize'] ?? '') ?? 24.0;
    final bigButtonsSecondTitleSize =
        double.tryParse(_settings['bigButtonsSecondTitleSize'] ?? '') ?? 14.0;
    final waitingTimeFontSize =
        double.tryParse(_settings['waitingTimeFontSize'] ?? '') ?? 14.0;
    final borderRadius = _getButtonBorderRadius();
    final isDropdown = _settings['enableDropdownMenu']?.toLowerCase() == 'true';

    // Parse dropdown items if enabled
    List<String> dropdownItems = [];
    if (isDropdown) {
      final items = _settings['buttonDropdownItems$index'] ?? '';
      dropdownItems =
          items.split('\n').where((item) => item.trim().isNotEmpty).toList();
      if (dropdownItems.isEmpty) {
        dropdownItems = [
          'Service 1',
          'Service 2',
          'Service 3',
        ]; // Default items
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        key: ValueKey('B$index'),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient:
                _getButtonBackgroundColor(index) == Colors.transparent
                    ? _getButtonGradient(index)
                    : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getButtonBackgroundColor(index),
                        _getButtonBackgroundColor(index),
                      ],
                    ),
          ),
          child: Material(
            color: Colors.transparent,
            child:
                isDropdown
                    ? _buildDropdownButton(
                      index,
                      dropdownItems,
                      bigButtonsTextSize,
                      bigButtonsSecondTitleSize,
                      waitingTimeFontSize,
                      borderRadius,
                    )
                    : InkWell(
                      borderRadius: BorderRadius.circular(borderRadius),
                      onTap:
                          () => _handleButtonTap(
                            index,
                            _settings['buttonFirstTitle$index'] ??
                                'Button $index',
                          ),
                      child: _buildButtonContent(
                        index,
                        _settings['buttonFirstTitle$index'] ?? 'Button $index',
                        _settings['buttonSecondTitle$index'] ?? '',
                        bigButtonsTextSize,
                        bigButtonsSecondTitleSize,
                        waitingTimeFontSize,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownButton(
    int index,
    List<String> items,
    double titleSize,
    double subtitleSize,
    double waitingTimeSize,
    double borderRadius,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        offset: const Offset(0, 60),
        onSelected: (String service) => _handleButtonTap(index, service),
        itemBuilder: (BuildContext context) {
          return items.map((String service) {
            return PopupMenuItem<String>(
              value: service,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _settings['buttonFirstTitle$index'] ?? 'Select Service',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: _getButtonTextColor(index),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${items.length} services available',
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: _getButtonTextColor(index).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: _getButtonTextColor(index).withOpacity(0.7),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_settings['buttonShowWaitingTime$index']?.toLowerCase() ==
                      'true' ||
                  _settings['buttonShowTicketBehind$index']?.toLowerCase() ==
                      'true') ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_settings['buttonShowWaitingTime$index']
                              ?.toLowerCase() ==
                          'true') ...[
                        Text(
                          '~5 min',
                          style: TextStyle(
                            fontSize: waitingTimeSize,
                            fontWeight: FontWeight.w500,
                            color: _getWaitingTimeColor(),
                          ),
                        ),
                      ],
                      if (_settings['buttonShowTicketBehind$index']
                              ?.toLowerCase() ==
                          'true') ...[
                        if (_settings['buttonShowWaitingTime$index']
                                ?.toLowerCase() ==
                            'true')
                          const SizedBox(height: 4),
                        Text(
                          '2 ahead',
                          style: TextStyle(
                            fontSize: waitingTimeSize,
                            fontWeight: FontWeight.w500,
                            color: _getWaitingTimeColor(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(
    int index,
    String title,
    String subtitle,
    double titleSize,
    double subtitleSize,
    double waitingTimeSize,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: _getButtonTextColor(index),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: _getButtonTextColor(index),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_settings['buttonShowWaitingTime$index']?.toLowerCase() ==
                  'true' ||
              _settings['buttonShowTicketBehind$index']?.toLowerCase() ==
                  'true') ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_settings['buttonShowWaitingTime$index']?.toLowerCase() ==
                      'true') ...[
                    Text(
                      '~5 min',
                      style: TextStyle(
                        fontSize: waitingTimeSize,
                        fontWeight: FontWeight.w500,
                        color: _getWaitingTimeColor(),
                      ),
                    ),
                  ],
                  if (_settings['buttonShowTicketBehind$index']
                          ?.toLowerCase() ==
                      'true') ...[
                    if (_settings['buttonShowWaitingTime$index']
                            ?.toLowerCase() ==
                        'true')
                      const SizedBox(height: 4),
                    Text(
                      '2 ahead',
                      style: TextStyle(
                        fontSize: waitingTimeSize,
                        fontWeight: FontWeight.w500,
                        color: _getWaitingTimeColor(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleButtonTap(int index, String serviceTitle) async {
    final phoneNumber = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneNumberPage(serviceTitle: serviceTitle),
      ),
    );

    if (phoneNumber != null) {
      // TODO: Handle the phone number submission
    }
  }

  Color _getWaitingTimeColor() {
    try {
      final color = _settings['waitingTimeFontColor'] ?? '#000000';
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.black87;
    }
  }
}
