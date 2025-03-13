import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../components/settings_components/printer_components/printer_settings.dart'
    as printer_components;
import '../models/printer_device.dart';
import '../components/settings_components/button_components/button_settings.dart';
import '../components/settings_components/general_components/general_settings.dart';
import '../components/settings_components/general_components/queue_system_settings.dart';
import '../components/settings_components/general_components/ticket_printing_settings.dart';
import '../components/settings_components/general_components/sms_notification_settings.dart';
import '../components/settings_components/general_components/security_misc_settings.dart';
import '../components/settings_components/general_components/server_settings.dart';
import '../components/settings_components/auth/authentication_dialog.dart';
import '../components/settings_components/printer_components/printer_status.dart';
import '../pages/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.isPreAuthenticated = false});

  final bool isPreAuthenticated;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  final Map<String, TextEditingController> _controllers = {};
  String? _currentPassword;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isAuthenticated = false;
  bool _obscurePassword = true;
  final Map<int, PrinterDevice?> _selectedPrinters = {};
  late TabController _tabController;
  final Map<String, bool> _toggleStates = {};

  @override
  void dispose() {
    _tabController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
    _loadSettings();
    _isAuthenticated = widget.isPreAuthenticated;
  }

  void _initializeControllers() {
    // Initialize text controllers for each text field
    [
      'serverAddress',
      'settingLoginPassword',
      'defaultCountryCode',
      'titleFontColor',
      'buttonTextFontColor',
      'buttonsBackgroundColor',
      'sixBigButtonsBackgroundColor',
      'logoSize',
      'bigButtonsTextSize',
      'bigButtonsSecondTitleSize',
      'waitingTimeFontSize',
      'waitingTimeFontColor',
      'selectServiceTitle',
      'afterRegistrationButtonText',
      'afterRegisterText',
      'ticketPrintTitleText',
      'ticketPrintSubtitleLabel',
      'smsButtonTitle',
      'ticketButtonTitle',
      'ticketQrCodeUrl',
      'confirmationSmsTitle',
      'confirmationSmsSecondTitle',
      'totalActivatedButtons',
      // Printer settings
      ...List.generate(
        3,
        (index) => [
          'printerType${index + 1}',
          'printerTickets${index + 1}',
          'printerName${index + 1}',
          'printerAddress${index + 1}',
        ],
      ).expand((x) => x),
      // Button settings for each button (1-6)
      ...List.generate(
        6,
        (index) => [
          'buttonServiceDestination${index + 1}',
          'buttonFirstTitle${index + 1}',
          'buttonLogo${index + 1}',
          'buttonSecondTitle${index + 1}',
          'buttonReActivationLabel${index + 1}',
          'buttonBackgroundColor1_${index + 1}',
          'buttonBackgroundColor2_${index + 1}',
          'buttonTextColor${index + 1}',
          'buttonDropDownChoices${index + 1}',
        ],
      ).expand((x) => x),
    ].forEach((key) {
      _controllers[key] = TextEditingController();
      // Set default values
      switch (key) {
        case 'serverAddress':
          _controllers[key]!.text = 'https://singaporeq.com';
          break;
        case 'bigButtonsTextSize':
          _controllers[key]!.text = '24';
          break;
        case 'bigButtonsSecondTitleSize':
          _controllers[key]!.text = '14';
          break;
        case 'waitingTimeFontSize':
          _controllers[key]!.text = '14';
          break;
        case 'sixBigButtonsBackgroundColor':
          _controllers[key]!.text = '#FFFFFF';
          break;
        case 'buttonsBackgroundColor':
          _controllers[key]!.text = '#FFFFFF';
          break;
      }
    });

    // Initialize toggle states
    [
      'roundButton',
      'afterRegistrationButton',
      'afterRegistrationDisplayWaitingTime',
      'ticketPrintTitle',
      'ticketPrintSubtitle',
      'askForSmsOrTicket',
      'ticketPrintFootnote',
      'showFootnoteOnTablet',
      'ticketPrintQrCode',
      'mobileCountryCode',
      'forceOnMobileNumber',
      'confirmationToReceiveSms',
      'displayDateTime',
      // Button toggle states
      ...List.generate(
        6,
        (index) => [
          'buttonMissedQueueReActivation${index + 1}',
          'buttonShowWaitingTime${index + 1}',
          'buttonShowTicketBehind${index + 1}',
          'buttonConvertToDropDown${index + 1}',
        ],
      ).expand((x) => x),
    ].forEach((key) {
      _toggleStates[key] = false;
    });
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _databaseHelper.getSettings();
      if (mounted) {
        setState(() {
          // Load password
          _currentPassword = settings['settingLoginPassword'] ?? '';

          // Set default server address if not set
          if (settings['serverAddress']?.isEmpty ?? true) {
            settings['serverAddress'] = 'https://singaporeq.com';
          }

          // Set default font sizes if not set
          if (settings['bigButtonsTextSize']?.isEmpty ?? true) {
            settings['bigButtonsTextSize'] =
                _controllers['bigButtonsTextSize']!.text;
          }
          if (settings['bigButtonsSecondTitleSize']?.isEmpty ?? true) {
            settings['bigButtonsSecondTitleSize'] =
                _controllers['bigButtonsSecondTitleSize']!.text;
          }
          if (settings['waitingTimeFontSize']?.isEmpty ?? true) {
            settings['waitingTimeFontSize'] =
                _controllers['waitingTimeFontSize']!.text;
          }

          // Set default colors if not set
          if (settings['sixBigButtonsBackgroundColor']?.isEmpty ?? true) {
            settings['sixBigButtonsBackgroundColor'] = '#FFFFFF';
          }
          if (settings['buttonsBackgroundColor']?.isEmpty ?? true) {
            settings['buttonsBackgroundColor'] = '#FFFFFF';
          }

          // Set default total activated buttons to 6 if not set
          if (settings['totalActivatedButtons']?.isEmpty ?? true) {
            settings['totalActivatedButtons'] = '6';
          }

          // Initialize default button names and colors if not set
          for (int i = 1; i <= 6; i++) {
            // Set default button title if not set
            if (settings['buttonFirstTitle$i']?.isEmpty ?? true) {
              settings['buttonFirstTitle$i'] = 'Button $i';
            }

            // Set default background colors if not set
            if (settings['buttonBackgroundColor1_$i']?.isEmpty ?? true) {
              settings['buttonBackgroundColor1_$i'] = '#FFFFFF';
            }
            if (settings['buttonBackgroundColor2_$i']?.isEmpty ?? true) {
              settings['buttonBackgroundColor2_$i'] = '#D8E6FF';
            }

            // Set default text color if not set
            if (settings['buttonTextColor$i']?.isEmpty ?? true) {
              settings['buttonTextColor$i'] = '#000000';
            }
          }

          // Load text field values
          _controllers.forEach((key, controller) {
            controller.text = settings[key] ?? '';
          });

          // Load toggle states
          _toggleStates.forEach((key, _) {
            _toggleStates[key] = settings[key]?.toLowerCase() == 'true';
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading settings: $e')));
      }
    }
  }

  Future<bool> _showPasswordDialog() async {
    final dialog = AuthenticationDialog(
      currentPassword: _currentPassword ?? '',
    );
    return dialog.show(context);
  }

  Future<void> _saveSettings() async {
    try {
      final Map<String, String> settings = {};

      // Save text field values
      _controllers.forEach((key, controller) {
        settings[key] = controller.text;
      });

      // Save toggle states
      _toggleStates.forEach((key, value) {
        settings[key] = value.toString();
      });

      // Check if server address has changed
      final currentSettings = await _databaseHelper.getSettings();
      final currentServerAddress =
          currentSettings['serverAddress'] ?? 'https://singaporeq.com';
      final newServerAddress =
          settings['serverAddress'] ?? 'https://singaporeq.com';
      final serverAddressChanged = currentServerAddress != newServerAddress;

      // Save all settings
      await _databaseHelper.updateSettings(settings);

      if (mounted) {
        setState(() => _currentPassword = settings['settingLoginPassword']);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              serverAddressChanged
                  ? 'Settings saved. Server address changed - you will be redirected to login.'
                  : 'Settings saved successfully',
            ),
            backgroundColor:
                serverAddressChanged ? Colors.orange : Colors.green,
            duration: Duration(seconds: serverAddressChanged ? 3 : 2),
          ),
        );

        // If server address changed, navigate to login page after a short delay
        if (serverAddressChanged) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GeneralSettings(
          controllers: _controllers,
          toggleStates: _toggleStates,
          onToggleChanged: (key, value) {
            setState(() {
              _toggleStates[key] = value;
            });
          },
        ),
        QueueSystemSettings(
          controllers: _controllers,
          toggleStates: _toggleStates,
          onToggleChanged: (key, value) {
            setState(() {
              _toggleStates[key] = value;
            });
          },
        ),
        TicketPrintingSettings(
          controllers: _controllers,
          toggleStates: _toggleStates,
          onToggleChanged: (key, value) {
            setState(() {
              _toggleStates[key] = value;
            });
          },
        ),
        SMSNotificationSettings(
          controllers: _controllers,
          toggleStates: _toggleStates,
          onToggleChanged: (key, value) {
            setState(() {
              _toggleStates[key] = value;
            });
          },
        ),
        SecurityMiscSettings(
          controllers: _controllers,
          toggleStates: _toggleStates,
          onToggleChanged: (key, value) {
            setState(() {
              _toggleStates[key] = value;
            });
          },
        ),
        ServerSettings(
          controllers: _controllers,
          toggleStates: _toggleStates,
          onToggleChanged: (key, value) {
            setState(() {
              _toggleStates[key] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPrintersTab() {
    return printer_components.PrinterSettings(
      controllers: _controllers,
      toggleStates: _toggleStates,
      selectedPrinters: _selectedPrinters,
      onPrinterSelected: (printerNumber, printer) {
        _selectedPrinters[printerNumber] = printer;
      },
      onToggleChanged: (key, value) {
        _toggleStates[key] = value;
      },
      setState: setState,
    );
  }

  Widget _buildButtonsTab() {
    return ButtonSettings(
      controllers: _controllers,
      toggleStates: _toggleStates,
      onToggleChanged: (key, value) {
        setState(() {
          _toggleStates[key] = value;
        });
      },
      setState: setState,
    );
  }

  Widget _buildPrinterStatus() {
    return PrinterStatus(
      selectedPrinters: _selectedPrinters,
      onTap: () async {
        try {
          const intent = AndroidIntent(
            action: 'android.settings.BLUETOOTH_SETTINGS',
            flags: [268435456],
          );
          await intent.launch();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Bluetooth settings'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated &&
        _currentPassword != null &&
        _currentPassword!.isNotEmpty) {
      // Show password dialog when page is first loaded and password is set
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPasswordDialog().then((authenticated) {
          if (authenticated == true) {
            setState(() => _isAuthenticated = true);
          } else {
            Navigator.of(context).pop(); // Go back if authentication fails
          }
        });
      });

      // Show loading screen while authenticating
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066CB)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0066CB), Color(0xFF0055B0)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                // Show confirmation dialog before going back
                final shouldSave = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Save Changes?'),
                      content: const Text(
                        'Do you want to save your changes before going back?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('No'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CB),
                          ),
                          child: const Text('Yes'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldSave == true) {
                  await _saveSettings();
                }
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pop(true); // Return true to indicate settings were changed
                }
              },
            ),
            actions: [
              // Wrap printer status and bluetooth button in a row
              InkWell(
                onTap: () async {
                  try {
                    const intent = AndroidIntent(
                      action: 'android.settings.BLUETOOTH_SETTINGS',
                      flags: [268435456],
                    );
                    await intent.launch();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Bluetooth settings'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: _buildPrinterStatus(),
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                tooltip: 'Save Settings',
                onPressed: _saveSettings,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.print), text: 'Printers'),
                Tab(icon: Icon(Icons.dashboard), text: 'Buttons'),
                Tab(icon: Icon(Icons.settings), text: 'General'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPrintersTab(),
              _buildButtonsTab(),
              _buildGeneralTab(),
            ],
          ),
        ),
      ),
    );
  }
}
