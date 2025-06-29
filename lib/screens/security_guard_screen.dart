// screens/security_guard_screen.dart (อัพเดทให้ทำงานกับ Database)
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import '../widgets/print_preview_dialog.dart';
import '../widgets/vehicle_type_selector.dart';

class SecurityGuardScreen extends StatefulWidget {
  final Future<void> Function(VehicleRecord) onAddRecord;

  const SecurityGuardScreen({super.key, required this.onAddRecord});

  @override
  State<SecurityGuardScreen> createState() => _SecurityGuardScreenState();
}

class _SecurityGuardScreenState extends State<SecurityGuardScreen> {
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  VehicleType _selectedVehicleType = VehicleType.visitor;
  bool _isSaving = false;

  Future<void> _saveRecord() async {
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

    if (_isSaving) return; // ป้องกันการกดซ้ำ

    setState(() {
      _isSaving = true;
    });

    try {
      final record = VehicleRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        licensePlate: _licensePlateController.text.trim(),
        houseNumber: _houseNumberController.text.trim(),
        vehicleType: _selectedVehicleType,
        entryTime: DateTime.now(),
      );

      // บันทึกข้อมูลลงฐานข้อมูล
      await widget.onAddRecord(record);

      // แสดงตัวอย่างการพิมพ์
      if (mounted) {
        _showPrintPreview(record);

        // เคลียร์ form
        _licensePlateController.clear();
        _houseNumberController.clear();
        setState(() {
          _selectedVehicleType = VehicleType.visitor;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึก: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storage,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ข้อมูลจะถูกบันทึกลงฐานข้อมูล',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                    enabled: !_isSaving,
                    decoration: InputDecoration(
                      labelText: 'ป้ายทะเบียนรถ',
                      hintText: 'เช่น ABC1234',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.directions_car),
                      filled: true,
                      fillColor:
                          _isSaving
                              ? Colors.grey.shade100
                              : Colors.grey.shade50,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),

                  const SizedBox(height: 16),

                  // บ้านเลขที่
                  TextField(
                    controller: _houseNumberController,
                    enabled: !_isSaving,
                    decoration: InputDecoration(
                      labelText: 'บ้านเลขที่ที่ต้องการไป',
                      hintText: 'เช่น 123/45',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.home),
                      filled: true,
                      fillColor:
                          _isSaving
                              ? Colors.grey.shade100
                              : Colors.grey.shade50,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // เลือกประเภทรถ
                  VehicleTypeSelector(
                    selectedType: _selectedVehicleType,
                    onChanged:
                        _isSaving
                            ? null
                            : (type) {
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
                      onPressed: _isSaving ? null : _saveRecord,
                      icon:
                          _isSaving
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
                              : const Icon(Icons.save, size: 24),
                      label: Text(
                        _isSaving ? 'กำลังบันทึก...' : 'บันทึกข้อมูล',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isSaving ? Colors.grey : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: _isSaving ? 0 : 2,
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
                    '• ข้อมูลจะถูกบันทึกลงฐานข้อมูลอัตโนมัติ\n'
                    '• ระบบจะแสดงตัวอย่างการพิมพ์หลังบันทึก\n'
                    '• ดูรายการรถได้ที่แท็บ "รถในหมู่บ้าน"',
                    style: TextStyle(color: Colors.amber.shade700, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // สถานะการเชื่อมต่อฐานข้อมูล
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'เชื่อมต่อฐานข้อมูลสำเร็จ',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.storage, color: Colors.green.shade700, size: 16),
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
