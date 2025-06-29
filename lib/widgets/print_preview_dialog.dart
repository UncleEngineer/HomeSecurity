// widgets/print_preview_dialog.dart
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import '../services/sunmi_service.dart';

class PrintPreviewDialog extends StatefulWidget {
  final VehicleRecord record;

  const PrintPreviewDialog({super.key, required this.record});

  @override
  State<PrintPreviewDialog> createState() => _PrintPreviewDialogState();
}

class _PrintPreviewDialogState extends State<PrintPreviewDialog> {
  final SunmiService _sunmiService = SunmiService();
  bool _isPrinting = false;
  bool _printerAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkPrinter();
  }

  Future<void> _checkPrinter() async {
    final isAvailable = await _sunmiService.checkPrinterStatus();
    if (mounted) {
      setState(() {
        _printerAvailable = isAvailable;
      });
    }
  }

  Future<void> _printDocument() async {
    if (_isPrinting) return;

    setState(() {
      _isPrinting = true;
    });

    try {
      await _sunmiService.printVehicleRecord(widget.record);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('พิมพ์เรียบร้อยแล้ว'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final printContent = _sunmiService.generatePrintPreview(widget.record);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.print,
            color: _printerAvailable ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 8),
          const Text('ตัวอย่างการพิมพ์'),
          const Spacer(),
          if (!_printerAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Text(
                'เครื่องพิมพ์ไม่พร้อม',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              printContent,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isPrinting ? null : () => Navigator.of(context).pop(),
          child: const Text('ปิด'),
        ),
        ElevatedButton.icon(
          onPressed: _isPrinting || !_printerAvailable ? null : _printDocument,
          icon:
              _isPrinting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.print),
          label: Text(_isPrinting ? 'กำลังพิมพ์...' : 'พิมพ์'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _printerAvailable ? Colors.blue : Colors.grey,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
