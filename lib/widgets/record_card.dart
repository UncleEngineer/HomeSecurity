// widgets/record_card.dart
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';

class RecordCard extends StatelessWidget {
  final VehicleRecord record;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onPrint;
  final VoidCallback? onRecordExit;
  final VoidCallback? onArchive;

  const RecordCard({
    super.key,
    required this.record,
    required this.onDelete,
    required this.onEdit,
    required this.onPrint,
    this.onRecordExit,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onLongPress: onEdit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: record.vehicleType.color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: record.vehicleType.color.withOpacity(0.2),
              child: Icon(
                record.vehicleType.icon,
                color: record.vehicleType.color,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'ป้าย: ${record.licensePlate}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: record.vehicleType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: record.vehicleType.color.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    record.vehicleType.label,
                    style: TextStyle(
                      fontSize: 10,
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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (record.exitTime != null)
                  Text(
                    'ออก: ${record.exitTime!.day}/${record.exitTime!.month}/${record.exitTime!.year} ${record.exitTime!.hour.toString().padLeft(2, '0')}:${record.exitTime!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                Text(
                  'อยู่ในหมู่บ้าน: ${record.formattedTimeInVillage}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        record.status == VehicleStatus.inside
                            ? Colors.green
                            : Colors.grey.shade600,
                    fontWeight:
                        record.status == VehicleStatus.inside
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
                if (record.status != VehicleStatus.inside)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          record.status == VehicleStatus.archived
                              ? Colors.grey
                              : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      record.status.label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: _buildTrailingActions(),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingActions() {
    if (record.status == VehicleStatus.archived) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPrint,
            icon: const Icon(Icons.print, color: Colors.blue),
            tooltip: 'ดูตัวอย่างการพิมพ์',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'ลบข้อมูล',
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (record.status == VehicleStatus.inside && onRecordExit != null)
          IconButton(
            onPressed: onRecordExit,
            icon: const Icon(Icons.access_time, color: Colors.purple),
            tooltip: 'บันทึกเวลาออก',
          ),
        if (record.exitTime != null &&
            record.status == VehicleStatus.exited &&
            onArchive != null)
          IconButton(
            onPressed: onArchive,
            icon: const Icon(Icons.archive, color: Colors.brown),
            tooltip: 'เก็บประวัติ',
          ),
        IconButton(
          onPressed: onPrint,
          icon: const Icon(Icons.print, color: Colors.blue),
          tooltip: 'ดูตัวอย่างการพิมพ์',
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, color: Colors.orange),
          tooltip: 'แก้ไขข้อมูล',
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'ลบข้อมูล',
        ),
      ],
    );
  }
}
