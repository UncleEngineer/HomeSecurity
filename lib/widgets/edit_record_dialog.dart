// widgets/edit_record_dialog.dart
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import 'vehicle_type_selector.dart';

class EditRecordDialog extends StatefulWidget {
  final VehicleRecord record;

  const EditRecordDialog({super.key, required this.record});

  @override
  State<EditRecordDialog> createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends State<EditRecordDialog> {
  late TextEditingController _licensePlateController;
  late TextEditingController _houseNumberController;
  late VehicleType _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController(
      text: widget.record.licensePlate,
    );
    _houseNumberController = TextEditingController(
      text: widget.record.houseNumber,
    );
    _selectedVehicleType = widget.record.vehicleType;
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit, color: Colors.orange),
          SizedBox(width: 8),
          Text('แก้ไขข้อมูล'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                labelText: 'ป้ายทะเบียนรถ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _houseNumberController,
              decoration: const InputDecoration(
                labelText: 'บ้านเลขที่',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 16),
            VehicleTypeSelector(
              selectedType: _selectedVehicleType,
              onChanged: (type) {
                setState(() {
                  _selectedVehicleType = type;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_licensePlateController.text.trim().isEmpty ||
                _houseNumberController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final updatedRecord = widget.record.copyWith(
              licensePlate: _licensePlateController.text.trim(),
              houseNumber: _houseNumberController.text.trim(),
              vehicleType: _selectedVehicleType,
            );

            Navigator.of(context).pop(updatedRecord);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}
