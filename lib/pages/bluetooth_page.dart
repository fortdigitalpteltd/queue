import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:async';
import '../models/printer_device.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPage extends StatefulWidget {
  final String printerLabel;

  const BluetoothPage({super.key, required this.printerLabel});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<ScanResult> _devices = [];
  List<BluetoothDevice> _bondedDevices = [];
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

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        print('${permission.toString()} is not granted: ${status.toString()}');
        allGranted = false;
      }
    });

    if (!allGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please grant all required permissions to scan for devices',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return allGranted;
  }

  Future<void> _initBluetooth() async {
    try {
      // Check permissions first
      if (!await _checkPermissions()) {
        return;
      }

      // Check if Bluetooth is available
      final isAvailable = await FlutterBluePlus.isAvailable;
      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bluetooth is not available on this device'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get bonded (paired) devices
      _bondedDevices = await FlutterBluePlus.bondedDevices;
      if (mounted) {
        setState(() {}); // Update UI with bonded devices
      }

      // Listen to Bluetooth state changes
      _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
        print('Bluetooth state changed: $state');
        if (mounted) {
          setState(() => _isBluetoothOn = state == BluetoothAdapterState.on);
          if (_isBluetoothOn) {
            _updateBondedDevices(); // Update bonded devices when Bluetooth turns on
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
      print('Error in _initBluetooth: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing Bluetooth: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateBondedDevices() async {
    try {
      final devices = await FlutterBluePlus.bondedDevices;
      if (mounted) {
        setState(() {
          _bondedDevices = devices;
        });
      }
    } catch (e) {
      print('Error getting bonded devices: $e');
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    if (!await _checkPermissions()) {
      return;
    }

    if (mounted) {
      setState(() {
        _devices = [];
        _isScanning = true;
      });
    }

    try {
      // Check if Bluetooth is available and on
      if (!await FlutterBluePlus.isAvailable || !await FlutterBluePlus.isOn) {
        throw Exception('Bluetooth is not available or turned off');
      }

      print('Starting Bluetooth scan with settings...');

      // Set scan mode to low latency
      await FlutterBluePlus.setLogLevel(LogLevel.verbose);

      // Start scan with specific settings
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          print('Found ${results.length} devices');
          if (mounted) {
            setState(() {
              // Filter out devices with very weak signals
              _devices = results.where((r) => r.rssi > -90).toList();
            });
          }
        },
        onError: (e) {
          print('Scan error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Scan error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      // When scan completes
      await Future.delayed(const Duration(seconds: 15));
      if (mounted) {
        setState(() => _isScanning = false);
        print('Scan completed. Found ${_devices.length} devices');

        if (_devices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No devices found. Make sure devices are turned on and in range.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error during scan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan for devices: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isScanning = false);
      }
    }
  }

  Widget _buildDeviceList() {
    if (_bondedDevices.isEmpty && _devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_searching, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _isScanning ? 'Scanning for devices...' : 'No Devices Found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isScanning
                  ? 'Please wait while we search for nearby devices'
                  : 'Make sure devices are turned on and in range',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _startScan,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isScanning ? 'Scanning...' : 'Scan Again'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (_bondedDevices.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Paired Devices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._bondedDevices.map((device) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.bluetooth_connected),
                  title: Text(device.platformName.isEmpty
                      ? 'Unknown Device'
                      : device.platformName),
                  subtitle: Text(device.remoteId.str),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToBondedDevice(device),
                    child: const Text('Connect'),
                  ),
                ),
              )),
        ],
        if (_devices.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Available Devices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._devices.map((result) {
            final deviceName = result.device.platformName.isEmpty
                ? 'Unknown Device'
                : result.device.platformName;
            final deviceId = result.device.remoteId.str;
            final rssi = result.rssi;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(deviceName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deviceId),
                    Text('Signal Strength: $rssi dBm')
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _connectToDevice(result),
                  child: const Text('Connect'),
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Future<void> _connectToDevice(ScanResult result) async {
    if (!mounted) return;
    
    try {
      // Show connecting banner
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Connecting to ${result.device.platformName}...'),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade50,
          leading: const Icon(Icons.bluetooth_searching, color: Colors.blue),
          actions: const [SizedBox.shrink()],
        ),
      );

      // Try to connect with retry logic for Android
      bool connected = false;
      int retryCount = 0;
      while (!connected && retryCount < 3) {
        try {
          await result.device.connect(timeout: const Duration(seconds: 5));
          connected = true;
        } catch (e) {
          retryCount++;
          if (retryCount == 3) throw e;
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      if (!mounted) return;
      // Hide the banner
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

      final device = PrinterDevice(
        name: result.device.platformName,
        address: result.device.remoteId.str,
        device: result.device,
      );

      // Return to printer settings with success
      Navigator.pop(context, device);
      
    } catch (e) {
      if (!mounted) return;
      // Hide the banner
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _connectToBondedDevice(BluetoothDevice device) async {
    if (!mounted) return;
    
    try {
      // Show connecting banner
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Connecting to ${device.platformName}...'),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade50,
          leading: const Icon(Icons.bluetooth_searching, color: Colors.blue),
          actions: const [SizedBox.shrink()],
        ),
      );

      // Try to connect with retry logic for Android
      bool connected = false;
      int retryCount = 0;
      while (!connected && retryCount < 3) {
        try {
          await device.connect(timeout: const Duration(seconds: 5));
          connected = true;
        } catch (e) {
          retryCount++;
          if (retryCount == 3) throw e;
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      if (!mounted) return;
      // Hide the banner
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

      final printerDevice = PrinterDevice(
        name: device.platformName,
        address: device.remoteId.str,
        device: device,
      );

      // Return to printer settings with success
      Navigator.pop(context, printerDevice);
      
    } catch (e) {
      if (!mounted) return;
      // Hide the banner
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
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
