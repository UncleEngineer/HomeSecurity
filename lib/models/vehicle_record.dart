import 'package:flutter/material.dart';

// models/vehicle_record.dart
enum VehicleType {
  delivery('ส่งอาหาร/พัสดุ', Icons.delivery_dining, Colors.orange),
  passenger('ส่งผู้โดยสาร', Icons.person, Colors.blue),
  visitor('แขกลูกบ้าน', Icons.home, Colors.green);

  const VehicleType(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum VehicleStatus {
  inside('ในหมู่บ้าน'),
  exited('ออกแล้ว'),
  archived('เก็บประวัติ');

  const VehicleStatus(this.label);
  final String label;
}

class VehicleRecord {
  final String id;
  String licensePlate;
  String houseNumber;
  VehicleType vehicleType;
  final DateTime entryTime;
  DateTime? exitTime;
  VehicleStatus status;

  VehicleRecord({
    required this.id,
    required this.licensePlate,
    required this.houseNumber,
    required this.vehicleType,
    required this.entryTime,
    this.exitTime,
    this.status = VehicleStatus.inside,
  });

  // คำนวณระยะเวลาที่อยู่ในหมู่บ้าน
  Duration get timeInVillage {
    final endTime = exitTime ?? DateTime.now();
    return endTime.difference(entryTime);
  }

  String get formattedTimeInVillage {
    final duration = timeInVillage;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}ชม. ${minutes}นาที';
  }

  VehicleRecord copyWith({
    String? licensePlate,
    String? houseNumber,
    VehicleType? vehicleType,
    DateTime? exitTime,
    VehicleStatus? status,
  }) {
    return VehicleRecord(
      id: id,
      licensePlate: licensePlate ?? this.licensePlate,
      houseNumber: houseNumber ?? this.houseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      entryTime: entryTime,
      exitTime: exitTime ?? this.exitTime,
      status: status ?? this.status,
    );
  }
}
