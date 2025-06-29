// screens/security_guard_screen.dart (แก้ไข)
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import '../widgets/print_preview_dialog.dart';
import '../widgets/vehicle_type_selector.dart';

class SecurityGuardScreen extends StatefulWidget {
  final Function(VehicleRecord) onAddRecord;

  const SecurityGuardScreen({super.key, required this.onAddRecord});

  @override
  State<SecurityGuardScreen> createState() => _SecurityGuardScreenState();
}

class _SecurityGuardScreenState extends State<SecurityGuardScreen> {
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  VehicleType _selectedVehicleType = VehicleType.visitor;

  void _saveRecord() {
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

    final record = VehicleRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      licensePlate: _licensePlateController.text.trim(),
      houseNumber: _houseNumberController.text.trim(),
      vehicleType: _selectedVehicleType,
      entryTime: DateTime.now(),
    );

    widget.onAddRecord(record);
    _showPrintPreview(record);

    // เคลียร์ form
    _licensePlateController.clear();
    _houseNumberController.clear();
    setState(() {
      _selectedVehicleType = VehicleType.visitor;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPrintPreview(VehicleRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PrintPreviewDialog(record: record);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกข้อมูลรถ'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // หัวข้อและคำอธิบาย
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.security, size: 48, color: Colors.blue.shade700),
                  const SizedBox(height: 12),
                  Text(
                    'ระบบบันทึกข้อมูลรถ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'สำหรับเจ้าหน้าที่รักษาความปลอดภัย',
                    style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ฟอร์มกรอกข้อมูล
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        'บันทึกข้อมูลรถใหม่',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ป้ายทะเบียน
                  TextField(
                    controller: _licensePlateController,
                    decoration: InputDecoration(
                      labelText: 'ป้ายทะเบียนรถ',
                      hintText: 'เช่น ABC1234',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.directions_car),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),

                  const SizedBox(height: 16),

                  // บ้านเลขที่
                  TextField(
                    controller: _houseNumberController,
                    decoration: InputDecoration(
                      labelText: 'บ้านเลขที่ที่ต้องการไป',
                      hintText: 'เช่น 123/45',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.home),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // เลือกประเภทรถ
                  VehicleTypeSelector(
                    selectedType: _selectedVehicleType,
                    onChanged: (type) {
                      setState(() {
                        _selectedVehicleType = type;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // ปุ่มบันทึก
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveRecord,
                      icon: const Icon(Icons.save, size: 24),
                      label: const Text(
                        'บันทึกข้อมูล',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // คำแนะนำ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'คำแนะนำการใช้งาน',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• เลือกประเภทรถให้ถูกต้อง\n'
                    '• ตรวจสอบป้ายทะเบียนก่อนบันทึก\n'
                    '• ระบบจะพิมพ์ใบเสร็จอัตโนมัติ\n'
                    '• ดูรายการรถได้ที่แท็บ "รถในหมู่บ้าน"',
                    style: TextStyle(color: Colors.amber.shade700, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }
}
