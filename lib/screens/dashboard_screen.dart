// screens/dashboard_screen.dart (อัพเดทให้รองรับ Database)
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import '../models/dashboard_data.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/record_card.dart';
import '../widgets/print_preview_dialog.dart';

class DashboardScreen extends StatelessWidget {
  final List<VehicleRecord> records;
  final Function(int) onDeleteRecord;
  final Future<void> Function()? onRefresh;

  const DashboardScreen({
    super.key,
    required this.records,
    required this.onDeleteRecord,
    this.onRefresh,
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
          content: Text(
            'คุณต้องการลบข้อมูลรถป้าย ${records[index].licensePlate} หรือไม่?\n\n'
            'หมายเหตุ: การลบข้อมูลประวัติจะไม่สามารถกู้คืนได้',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                onDeleteRecord(index);
                Navigator.of(context).pop();
              },
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDataManagementDialog(
    BuildContext context,
    DashboardData dashboardData,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings_applications, color: Colors.blue),
              SizedBox(width: 8),
              Text('จัดการข้อมูล'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'สถิติข้อมูลปัจจุบัน:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text('• รถทั้งหมด: ${records.length} คัน'),
              Text(
                '• รถในหมู่บ้าน: ${dashboardData.vehiclesInside.length} คัน',
              ),
              Text(
                '• ประวัติที่เก็บไว้: ${dashboardData.archivedVehicles.length} คัน',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ข้อมูลถูกเก็บไว้ในฐานข้อมูลภายในเครื่อง',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
            if (onRefresh != null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRefresh!();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('รีเฟรชข้อมูล'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
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
        actions: [
          IconButton(
            onPressed: () => _showDataManagementDialog(context, dashboardData),
            icon: const Icon(Icons.settings),
            tooltip: 'จัดการข้อมูล',
          ),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: 'รีเฟรชข้อมูล',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  child: Column(
                    children: [
                      const Icon(Icons.archive, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'ยังไม่มีประวัติที่เก็บไว้',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ลากลงเพื่อรีเฟรชข้อมูล',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...archivedRecords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  final originalIndex = records.indexOf(record);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.brown.shade300,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown.shade100,
                          child: Icon(
                            Icons.archive,
                            color: Colors.brown.shade700,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ป้าย: ${record.licensePlate}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: record.vehicleType.color.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: record.vehicleType.color.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                record.vehicleType.label,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: record.vehicleType.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('บ้านเลขที่: ${record.houseNumber}'),
                            Text(
                              'เข้า: ${record.entryTime.day}/${record.entryTime.month}/${record.entryTime.year} ${record.entryTime.hour.toString().padLeft(2, '0')}:${record.entryTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (record.exitTime != null)
                              Text(
                                'ออก: ${record.exitTime!.day}/${record.exitTime!.month}/${record.exitTime!.year} ${record.exitTime!.hour.toString().padLeft(2, '0')}:${record.exitTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            Text(
                              'ระยะเวลา: ${record.formattedTimeInVillage}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.brown.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'เก็บประวัติแล้ว',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed:
                                  () => _showPrintPreview(context, record),
                              icon: const Icon(
                                Icons.print,
                                color: Colors.blue,
                                size: 20,
                              ),
                              tooltip: 'ดูตัวอย่างการพิมพ์',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                            IconButton(
                              onPressed:
                                  () => _deleteRecord(context, originalIndex),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              tooltip: 'ลบข้อมูลถาวร',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 24),

              // คำแนะนำ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'เกี่ยวกับข้อมูล',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ข้อมูลทั้งหมดถูกเก็บในฐานข้อมูล SQLite\n'
                      '• สามารถลากลงเพื่อรีเฟรชข้อมูลได้\n'
                      '• ข้อมูลประวัติจะถูกเก็บไว้ถาวร\n'
                      '• สามารถลบข้อมูลประวัติได้จากหน้านี้',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
