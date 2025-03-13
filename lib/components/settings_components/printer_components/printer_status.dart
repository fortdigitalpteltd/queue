import 'package:flutter/material.dart';
import '../../../models/printer_device.dart';

class PrinterStatus extends StatelessWidget {
  final Map<int, PrinterDevice?> selectedPrinters;
  final VoidCallback onTap;

  const PrinterStatus({
    super.key,
    required this.selectedPrinters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bluetooth, color: Colors.white),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
} 