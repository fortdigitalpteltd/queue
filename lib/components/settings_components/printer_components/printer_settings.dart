import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:queue_system/pages/bluetooth_page.dart' hide PrinterDevice;
import 'package:queue_system/models/printer_device.dart';

class PrinterSettings extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> toggleStates;
  final Map<int, PrinterDevice?> selectedPrinters;
  final Function(int, PrinterDevice) onPrinterSelected;
  final Function(String, bool) onToggleChanged;
  final Function(void Function()) setState;

  const PrinterSettings({
    super.key,
    required this.controllers,
    required this.toggleStates,
    required this.selectedPrinters,
    required this.onPrinterSelected,
    required this.onToggleChanged,
    required this.setState,
  });

  Widget _buildPrinterSelectionButton(BuildContext context, int printerNumber) {
    final isPrinterConnected = selectedPrinters[printerNumber] != null;
    final printerName = controllers['printerName$printerNumber']?.text;
    final printerAddress = controllers['printerAddress$printerNumber']?.text;

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
                        if (!context.mounted) return;
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
                                      if (!context.mounted) return;
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

                      if (printer != null && context.mounted) {
                        setState(() {
                          onPrinterSelected(printerNumber, printer);
                          controllers['printerName$printerNumber']?.text =
                              printer.name;
                          controllers['printerAddress$printerNumber']?.text =
                              printer.address;
                        });
                      }
                    } catch (e) {
                      if (!context.mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        final printerNumber = index + 1;
        final isPrinterConnected = selectedPrinters[printerNumber] != null;
        final isEnabled = toggleStates['enablePrinter$printerNumber'] ?? false;

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
                                onToggleChanged(
                                  'enablePrinter$printerNumber',
                                  value,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Print Type Dropdown
                    Container(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        value:
                            controllers['printerType$printerNumber']
                                        ?.text
                                        .isEmpty ==
                                    true
                                ? 'Star Printer'
                                : controllers['printerType$printerNumber']
                                    ?.text,
                        decoration: InputDecoration(
                          labelText: 'Print Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isPrinterConnected ? Colors.black87 : Colors.grey,
                        ),
                        dropdownColor: Colors.white,
                        items:
                            ['Star Printer', 'Others']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            isPrinterConnected
                                ? (value) {
                                  if (value != null) {
                                    setState(() {
                                      controllers['printerType$printerNumber']
                                          ?.text = value;
                                    });
                                  }
                                }
                                : null,
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Printer Selection Button
                    _buildPrinterSelectionButton(context, printerNumber),
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
                              controllers['printerTickets$printerNumber']
                                      ?.text ??
                                  '1',
                            ) ??
                            1,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label:
                            controllers['printerTickets$printerNumber']?.text ??
                            '1',
                        onChanged:
                            isPrinterConnected
                                ? (value) {
                                  setState(() {
                                    controllers['printerTickets$printerNumber']
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
}
