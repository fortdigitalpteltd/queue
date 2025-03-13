import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PrinterDevice {
  final String name;
  final String address;
  final BluetoothDevice? device;

  PrinterDevice({
    required this.name,
    required this.address,
    this.device,
  });
} 