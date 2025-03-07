import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import './bluetooth_page.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  final bool isPreAuthenticated;
  
  const SettingsPage({
    super.key,
    this.isPreAuthenticated = false,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _toggleStates = {};
  final Map<int, PrinterDevice?> _selectedPrinters = {};
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String? _currentPassword;
  bool _isAuthenticated = false;
  bool _obscurePassword = true;

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
      'logoSize',
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
    });

    // Initialize toggle states
    [
      'enablePrinter1',
      'enablePrinter2',
      'enablePrinter3',
      'mobileCountryCode',
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
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: const Color(0xFF0066CB),
                size: 28,
              ),
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
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
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
                        borderSide: const BorderSide(color: Color(0xFF0066CB), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red.shade400),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF0066CB),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value != _currentPassword) {
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
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              ),
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
      },
    );

    return result ?? false;
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

      await _databaseHelper.updateSettings(settings);

      if (mounted) {
        setState(() => _currentPassword = settings['settingLoginPassword']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildColorField(
    String label,
    TextEditingController? controller, {
    String defaultColor = '#000000',
  }) {
    if (controller == null) return const SizedBox.shrink();

    // Ensure controller has a valid initial value
    if (controller.text.isEmpty) {
      controller.text = defaultColor;
    }

    // Try to parse the color, fallback to default if invalid
    Color currentColor;
    try {
      currentColor = Color(int.parse(controller.text.replaceAll('#', '0xFF')));
    } catch (e) {
      currentColor = Color(int.parse(defaultColor.replaceAll('#', '0xFF')));
      controller.text = defaultColor;
    }

    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _showColorPicker(controller, label),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: currentColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        suffixIcon: const Icon(Icons.color_lens),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }

  void _showColorPicker(TextEditingController controller, String title) {
    Color currentColor;
    try {
      currentColor = Color(int.parse(controller.text.replaceAll('#', '0xFF')));
    } catch (e) {
      currentColor = Colors.black;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick $title'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: currentColor,
                  onColorChanged: (Color color) {
                    currentColor = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false,
                  displayThumbColor: true,
                  showLabel: true,
                  paletteType: PaletteType.hsvWithHue,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Color Code',
                    hintText: '#RRGGBB',
                    border: const OutlineInputBorder(),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: currentColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 7 && value.startsWith('#')) {
                      try {
                        setState(() {
                          currentColor = Color(
                            int.parse(value.replaceAll('#', '0xFF')),
                          );
                        });
                      } catch (e) {
                        // Invalid color code
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final colorHex =
                      currentColor.value.toRadixString(16).toUpperCase();
                  controller.text = '#${colorHex.substring(2)}';
                });
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Server Settings Card
        Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                    TextField(
                      controller: _controllers['serverAddress'],
                      decoration: InputDecoration(
                        labelText: 'Server Address',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.dns),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // General Settings Card
        Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: const Text(
              'General Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColorField(
                      'Title Font Color',
                      _controllers['titleFontColor'],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controllers['logoSize'],
                      decoration: InputDecoration(
                        labelText: 'Logo Size',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.photo_size_select_large),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controllers['settingLoginPassword'],
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Settings Login Password',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controllers['defaultCountryCode'],
                      decoration: InputDecoration(
                        labelText: 'Default Country Code',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.flag),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Mobile Country Code'),
                            subtitle: const Text(
                              'Enable mobile country code selection',
                            ),
                            value: _toggleStates['mobileCountryCode'] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _toggleStates['mobileCountryCode'] = value;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text('Display Date and Time'),
                            subtitle: const Text('Show current date and time'),
                            value: _toggleStates['displayDateTime'] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _toggleStates['displayDateTime'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrintersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        final printerNumber = index + 1;
        final isPrinterConnected = _selectedPrinters[printerNumber] != null;
        final isEnabled = _toggleStates['enablePrinter$printerNumber'] ?? false;

        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              'Printer $printerNumber Options',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enable Print Switch with Status
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Enable Print'),
                            value: isEnabled,
                            onChanged: (value) {
                              if (!isPrinterConnected && value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please connect a printer first',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                _toggleStates['enablePrinter$printerNumber'] =
                                    value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Print Type Dropdown
                    DropdownButtonFormField<String>(
                      value:
                          _controllers['printerType$printerNumber']
                                      ?.text
                                      .isEmpty ==
                                  true
                              ? 'Type 1'
                              : _controllers['printerType$printerNumber']?.text,
                      decoration: const InputDecoration(
                        labelText: 'Print Type',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          ['Type 1', 'Type 2', 'Type 3']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged:
                          isPrinterConnected
                              ? (value) {
                                if (value != null) {
                                  setState(() {
                                    _controllers['printerType$printerNumber']
                                        ?.text = value;
                                  });
                                }
                              }
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Printer Selection Button
                    _buildPrinterSelectionButton(printerNumber),
                    const SizedBox(height: 16),

                    // Print Tickets Slider
                    const Text('Print Tickets:'),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: const Color(0xFF0066CB),
                        inactiveTrackColor: Colors.grey.shade200,
                        thumbColor: const Color(0xFF0066CB),
                        overlayColor: const Color(0xFF0066CB).withOpacity(0.12),
                      ),
                      child: Slider(
                        value:
                            double.tryParse(
                              _controllers['printerTickets$printerNumber']
                                      ?.text ??
                                  '1',
                            ) ??
                            1,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label:
                            _controllers['printerTickets$printerNumber']
                                ?.text ??
                            '1',
                        onChanged:
                            isPrinterConnected
                                ? (value) {
                                  setState(() {
                                    _controllers['printerTickets$printerNumber']
                                        ?.text = value.toInt().toString();
                                  });
                                }
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrinterSelectionButton(int printerNumber) {
    final isPrinterConnected = _selectedPrinters[printerNumber] != null;
    final printerName = _controllers['printerName$printerNumber']?.text;
    final printerAddress = _controllers['printerAddress$printerNumber']?.text;

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isPrinterConnected ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPrinterConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_searching,
                  size: 24,
                  color: isPrinterConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPrinterConnected
                            ? 'Currently Connected To:'
                            : 'No Printer Connected',
                        style: TextStyle(
                          color:
                              isPrinterConnected ? Colors.green : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (isPrinterConnected && printerName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          printerName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                      if (isPrinterConnected && printerAddress != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          printerAddress,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      bool isBluetoothOn = await FlutterBluePlus.isOn;

                      if (!isBluetoothOn) {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Printer Connection'),
                              content: const Text(
                                'Please enable Bluetooth to connect to a printer.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      const intent = AndroidIntent(
                                        action:
                                            'android.settings.BLUETOOTH_SETTINGS',
                                        flags: [268435456],
                                      );
                                      await intent.launch();
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Unable to open Bluetooth settings. Please enable Bluetooth manually.',
                                          ),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Open Settings'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      final printer = await Navigator.push<PrinterDevice>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BluetoothPage(
                                printerLabel: 'Printer $printerNumber',
                              ),
                        ),
                      );

                      if (printer != null && mounted) {
                        setState(() {
                          _selectedPrinters[printerNumber] = printer;
                          _controllers['printerName$printerNumber']?.text =
                              printer.name;
                          _controllers['printerAddress$printerNumber']?.text =
                              printer.address;
                        });
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isPrinterConnected ? Colors.blue : Colors.grey.shade700,
                    side: BorderSide(
                      color:
                          isPrinterConnected
                              ? Colors.blue
                              : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(isPrinterConnected ? 'Change' : 'Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final buttonNumber = index + 1;
        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              'Button $buttonNumber Options',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller:
                          _controllers['buttonServiceDestination$buttonNumber'],
                      decoration: InputDecoration(
                        labelText: 'Service Destination',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.location_on),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controllers['buttonFirstTitle$buttonNumber'],
                      decoration: InputDecoration(
                        labelText: 'First Title',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.title),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controllers['buttonLogo$buttonNumber'],
                      decoration: InputDecoration(
                        labelText: 'Logo',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.image),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller:
                          _controllers['buttonSecondTitle$buttonNumber'],
                      decoration: InputDecoration(
                        labelText: 'Second Title',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.title),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Queue Management'),
                            value:
                                _toggleStates['buttonMissedQueueReActivation$buttonNumber'] ??
                                false,
                            onChanged: (value) {
                              setState(() {
                                _toggleStates['buttonMissedQueueReActivation$buttonNumber'] =
                                    value;
                              });
                            },
                          ),
                          if (_toggleStates['buttonMissedQueueReActivation$buttonNumber'] ==
                              true) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                controller:
                                    _controllers['buttonReActivationLabel$buttonNumber'],
                                decoration: InputDecoration(
                                  labelText: 'Reactivation Label',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  prefixIcon: const Icon(Icons.label),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildColorField(
                      'Background Color 1',
                      _controllers['buttonBackgroundColor1_$buttonNumber'],
                      defaultColor: '#d3d3d3',
                    ),
                    const SizedBox(height: 16),
                    _buildColorField(
                      'Background Color 2',
                      _controllers['buttonBackgroundColor2_$buttonNumber'],
                      defaultColor: '#D8E6FF',
                    ),
                    const SizedBox(height: 16),
                    _buildColorField(
                      'Text Color',
                      _controllers['buttonTextColor$buttonNumber'],
                      defaultColor: '#000000',
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Show Waiting Time'),
                            subtitle: const Text(
                              'Display estimated waiting duration',
                            ),
                            value:
                                _toggleStates['buttonShowWaitingTime$buttonNumber'] ??
                                false,
                            onChanged: (value) {
                              setState(() {
                                _toggleStates['buttonShowWaitingTime$buttonNumber'] =
                                    value;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text('Show Queue Length'),
                            subtitle: const Text(
                              'Display number of tickets in queue',
                            ),
                            value:
                                _toggleStates['buttonShowTicketBehind$buttonNumber'] ??
                                false,
                            onChanged: (value) {
                              setState(() {
                                _toggleStates['buttonShowTicketBehind$buttonNumber'] =
                                    value;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text(
                              'Enable Dropdown for Second Title',
                            ),
                            subtitle: const Text(
                              'Convert second title to a dropdown menu',
                            ),
                            value:
                                _toggleStates['buttonConvertToDropDown$buttonNumber'] ??
                                false,
                            onChanged: (value) {
                              setState(() {
                                _toggleStates['buttonConvertToDropDown$buttonNumber'] =
                                    value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_toggleStates['buttonConvertToDropDown$buttonNumber'] ==
                        true) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller:
                            _controllers['buttonDropDownChoices$buttonNumber'],
                        decoration: InputDecoration(
                          labelText: 'Dropdown Menu Options (comma-separated)',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(Icons.list),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to build the printer status widget
  Widget _buildPrinterStatus() {
    // Get list of connected printers
    _selectedPrinters.entries
        .where((entry) => entry.value != null)
        .map((entry) => 'P${entry.key}: ${entry.value!.name}')
        .join(', ');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.bluetooth, color: Colors.white),
        const SizedBox(width: 8),
      ],
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
              onPressed: () => Navigator.of(context).pop(),
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

  @override
  void dispose() {
    _tabController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
