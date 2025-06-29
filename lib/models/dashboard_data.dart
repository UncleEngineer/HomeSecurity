import './vehicle_record.dart';

// models/dashboard_data.dart
class DashboardData {
  final List<VehicleRecord> records;

  DashboardData(this.records);

  // สรุปรถตามประเภท (เฉพาะที่อยู่ในหมู่บ้าน)
  Map<VehicleType, int> get vehicleCountByType {
    final insideVehicles =
        records.where((r) => r.status == VehicleStatus.inside).toList();
    return {
      for (var type in VehicleType.values)
        type: insideVehicles.where((r) => r.vehicleType == type).length,
    };
  }

  // สรุปรถทั้งหมดตามประเภท (รวมทุกสถานะ)
  Map<VehicleType, int> get totalVehicleCountByType {
    return {
      for (var type in VehicleType.values)
        type: records.where((r) => r.vehicleType == type).length,
    };
  }

  // รถที่อยู่ในหมู่บ้านทั้งหมด
  List<VehicleRecord> get vehiclesInside {
    return records.where((r) => r.status == VehicleStatus.inside).toList();
  }

  // รถที่เก็บประวัติแล้ว
  List<VehicleRecord> get archivedVehicles {
    return records.where((r) => r.status == VehicleStatus.archived).toList();
  }

  // เฉลี่ยเวลาที่อยู่ในหมู่บ้าน
  String get averageTimeInVillage {
    final completedRecords = records.where((r) => r.exitTime != null).toList();
    if (completedRecords.isEmpty) return '0ชม. 0นาที';

    final totalMinutes = completedRecords.fold<int>(
      0,
      (sum, record) => sum + record.timeInVillage.inMinutes,
    );
    final avgMinutes = totalMinutes ~/ completedRecords.length;

    return '${avgMinutes ~/ 60}ชม. ${avgMinutes % 60}นาที';
  }
}
