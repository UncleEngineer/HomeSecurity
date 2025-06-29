// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import '../models/dashboard_data.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/record_card.dart';
import '../widgets/print_preview_dialog.dart';

class DashboardScreen extends StatelessWidget {
  final List<VehicleRecord> records;
  final Function(int) onDeleteRecord;

  const DashboardScreen({
    super.key,
    required this.records,
    required this.onDeleteRecord,
  });

  void _showPrintPreview(BuildContext context, VehicleRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PrintPreviewDialog(record: record);
      },
    );
  }

  void _deleteRecord(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณต้องการลบข้อมูลนี้หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                onDeleteRecord(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ลบข้อมูลเรียบร้อยแล้ว'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardData = DashboardData(records);
    final archivedRecords = dashboardData.archivedVehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // สรุปข้อมูล Dashboard
            DashboardSummary(dashboardData: dashboardData),

            const SizedBox(height: 24),

            // ประวัติรถที่เก็บแล้ว
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ประวัติรถที่เก็บแล้ว',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.brown.shade300),
                  ),
                  child: Text(
                    '${archivedRecords.length} รายการ',
                    style: TextStyle(
                      color: Colors.brown.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (archivedRecords.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.archive, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'ยังไม่มีประวัติที่เก็บไว้',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              ...archivedRecords.asMap().entries.map((entry) {
                final index = entry.key;
                final record = entry.value;
                final originalIndex = records.indexOf(record);

                return RecordCard(
                  record: record,
                  onDelete: () => _deleteRecord(context, originalIndex),
                  onEdit: () {}, // ไม่ให้แก้ไขข้อมูลที่เก็บประวัติแล้ว
                  onPrint: () => _showPrintPreview(context, record),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
