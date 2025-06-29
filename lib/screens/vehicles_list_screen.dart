// screens/vehicles_list_screen.dart (แก้ไขให้แสดงผลได้)
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import '../widgets/edit_record_dialog.dart';
import '../widgets/print_preview_dialog.dart';

class VehiclesListScreen extends StatelessWidget {
  final List<VehicleRecord> records;
  final Function(int, VehicleRecord) onUpdateRecord;
  final Function(int) onDeleteRecord;
  final Function(int) onRecordExit;
  final Function(int) onArchive;

  const VehiclesListScreen({
    super.key,
    required this.records,
    required this.onUpdateRecord,
    required this.onDeleteRecord,
    required this.onRecordExit,
    required this.onArchive,
  });

  void _showPrintPreview(BuildContext context, VehicleRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PrintPreviewDialog(record: record);
      },
    );
  }

  void _editRecord(BuildContext context, int index) async {
    final result = await showDialog<VehicleRecord>(
      context: context,
      builder: (BuildContext context) {
        return EditRecordDialog(record: records[index]);
      },
    );

    if (result != null) {
      onUpdateRecord(index, result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('แก้ไขข้อมูลเรียบร้อยแล้ว'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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

  void _recordExit(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.access_time, color: Colors.purple),
              SizedBox(width: 8),
              Text('บันทึกเวลาออก'),
            ],
          ),
          content: Text(
            'บันทึกเวลาออกสำหรับรถป้าย ${records[index].licensePlate}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                onRecordExit(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกเวลาออกเรียบร้อยแล้ว'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('บันทึกเวลาออก'),
            ),
          ],
        );
      },
    );
  }

  void _archiveRecord(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.archive, color: Colors.brown),
              SizedBox(width: 8),
              Text('เก็บประวัติ'),
            ],
          ),
          content: Text(
            'เก็บข้อมูลรถป้าย ${records[index].licensePlate} เป็นประวัติ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                onArchive(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('เก็บประวัติเรียบร้อยแล้ว'),
                    backgroundColor: Colors.brown,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: const Text('เก็บประวัติ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // แสดงเฉพาะรถที่ไม่ได้เก็บประวัติ
    final activeRecords =
        records.where((r) => r.status != VehicleStatus.archived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('รถในหมู่บ้าน'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // สรุปจำนวนรถ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'รถในหมู่บ้านขณะนี้',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${activeRecords.length} คัน',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                if (activeRecords.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // สรุปตามประเภท
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        VehicleType.values.map((type) {
                          final count =
                              activeRecords
                                  .where((r) => r.vehicleType == type)
                                  .length;
                          return Column(
                            children: [
                              Icon(type.icon, color: type.color, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: type.color,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // คำแนะนำการใช้งาน
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'กดค้างที่ Card เพื่อแก้ไข | 🕐 บันทึกเวลาออก | 📦 เก็บประวัติ',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),

          // รายการรถ - ใช้ Card แบบเดิม
          Expanded(
            child:
                activeRecords.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'ไม่มีรถในหมู่บ้านขณะนี้',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: activeRecords.length,
                      itemBuilder: (context, index) {
                        final record = activeRecords[index];
                        final originalIndex = records.indexOf(record);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onLongPress:
                                () => _editRecord(context, originalIndex),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: record.vehicleType.color.withOpacity(
                                    0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: record.vehicleType.color
                                      .withOpacity(0.2),
                                  child: Icon(
                                    record.vehicleType.icon,
                                    color: record.vehicleType.color,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'ป้าย: ${record.licensePlate}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: record.vehicleType.color
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: record.vehicleType.color
                                              .withOpacity(0.3),
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
                                    Text(
                                      'บ้านเลขที่: ${record.houseNumber}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'เข้า: ${record.entryTime.day}/${record.entryTime.month}/${record.entryTime.year} ${record.entryTime.hour.toString().padLeft(2, '0')}:${record.entryTime.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (record.exitTime != null)
                                      Text(
                                        'ออก: ${record.exitTime!.day}/${record.exitTime!.month}/${record.exitTime!.year} ${record.exitTime!.hour.toString().padLeft(2, '0')}:${record.exitTime!.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      'อยู่: ${record.formattedTimeInVillage}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            record.status ==
                                                    VehicleStatus.inside
                                                ? Colors.green
                                                : Colors.grey.shade600,
                                        fontWeight:
                                            record.status ==
                                                    VehicleStatus.inside
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (record.status != VehicleStatus.inside)
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              record.status ==
                                                      VehicleStatus.archived
                                                  ? Colors.grey
                                                  : Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          record.status.label,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: _buildTrailingActions(
                                  context,
                                  record,
                                  originalIndex,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingActions(
    BuildContext context,
    VehicleRecord record,
    int originalIndex,
  ) {
    List<Widget> actions = [];

    if (record.status == VehicleStatus.inside) {
      actions.add(
        IconButton(
          onPressed: () => _recordExit(context, originalIndex),
          icon: const Icon(Icons.access_time, color: Colors.purple, size: 20),
          tooltip: 'บันทึกเวลาออก',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.all(4),
        ),
      );
    }

    if (record.exitTime != null && record.status == VehicleStatus.exited) {
      actions.add(
        IconButton(
          onPressed: () => _archiveRecord(context, originalIndex),
          icon: const Icon(Icons.archive, color: Colors.brown, size: 20),
          tooltip: 'เก็บประวัติ',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.all(4),
        ),
      );
    }

    actions.addAll([
      IconButton(
        onPressed: () => _showPrintPreview(context, record),
        icon: const Icon(Icons.print, color: Colors.blue, size: 20),
        tooltip: 'พิมพ์',
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: const EdgeInsets.all(4),
      ),
      IconButton(
        onPressed: () => _editRecord(context, originalIndex),
        icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
        tooltip: 'แก้ไข',
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: const EdgeInsets.all(4),
      ),
      IconButton(
        onPressed: () => _deleteRecord(context, originalIndex),
        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
        tooltip: 'ลบ',
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: const EdgeInsets.all(4),
      ),
    ]);

    return SizedBox(
      width: actions.length * 36.0, // จำกัดความกว้างตามจำนวนปุ่ม
      child: Row(mainAxisSize: MainAxisSize.min, children: actions),
    );
  }
}
