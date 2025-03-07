import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:async';

class PrinterDevice {
  final String name;
  final String address;
  final BluetoothDevice device;

  PrinterDevice({
    required this.name,
    required this.address,
    required this.device,
  });
}

class BluetoothPage extends StatefulWidget {
  final String printerLabel;

  const BluetoothPage({Key? key, required this.printerLabel}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<ScanResult> _devices = [];
  bool _isScanning = false;
  bool _isBluetoothOn = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    try {
      // Check if Bluetooth is available
      final isAvailable = await FlutterBluePlus.isAvailable;
      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bluetooth is not available on this device'),
            ),
          );
        }
        return;
      }

      // Listen to Bluetooth state changes
      _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (mounted) {
          setState(() => _isBluetoothOn = state == BluetoothAdapterState.on);
          if (_isBluetoothOn) {
            _startScan();
          }
        }
      });

      // Check initial Bluetooth state
      final isOn = await FlutterBluePlus.isOn;
      if (mounted) {
        setState(() => _isBluetoothOn = isOn);
        if (_isBluetoothOn) {
          _startScan();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing Bluetooth: $e')),
        );
      }
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    if (mounted) {
      setState(() {
        _devices = [];
        _isScanning = true;
      });
    }

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          if (mounted) {
            setState(() => _devices = results);
          }
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Scan error: $e')));
          }
        },
      );

      // When scan completes
      await Future.delayed(const Duration(seconds: 10));
      if (mounted) {
        setState(() => _isScanning = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to scan for devices: $e')),
        );
        setState(() => _isScanning = false);
      }
    }
  }

  Widget _buildDeviceList() {
    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.print_disabled, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Printer Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure your printer is turned on and nearby',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _startScan,
              icon:
                  _isScanning
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.refresh),
              label: Text(_isScanning ? 'Scanning...' : 'Scan Again'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final result = _devices[index];
        // Skip if device has no name
        if (result.device.platformName.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.print),
            title: Text(result.device.platformName),
            subtitle: Text(result.device.remoteId.str),
            trailing: ElevatedButton(
              onPressed: () => _connectToDevice(result),
              child: const Text('Connect'),
            ),
          ),
        );
      },
    );
  }

  Future<void> _connectToDevice(ScanResult result) async {
    try {
      await result.device.connect();

      final device = PrinterDevice(
        name: result.device.platformName,
        address: result.device.remoteId.str,
        device: result.device,
      );

      if (mounted) {
        Navigator.pop(context, device);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to connect: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${widget.printerLabel}'),
        actions: [
          if (_isBluetoothOn)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isScanning ? null : _startScan,
              tooltip: 'Scan again',
            ),
        ],
      ),
      body:
          _isBluetoothOn
              ? Stack(
                children: [
                  _buildDeviceList(),
                  if (_isScanning) const LinearProgressIndicator(),
                ],
              )
              : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bluetooth_disabled,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bluetooth is turned off',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please enable Bluetooth to scan for printers',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          const intent = AndroidIntent(
                            action: 'android.settings.BLUETOOTH_SETTINGS',
                          );
                          await intent.launch();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not open Bluetooth settings. Please enable Bluetooth manually.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Open Bluetooth Settings'),
                    ),
                  ],
                ),
              ),
    );
  }
}
