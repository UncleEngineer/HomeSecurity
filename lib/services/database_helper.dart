// services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'vehicle_records.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicle_records (
        id TEXT PRIMARY KEY,
        license_plate TEXT NOT NULL,
        house_number TEXT NOT NULL,
        vehicle_type TEXT NOT NULL,
        entry_time INTEGER NOT NULL,
        exit_time INTEGER,
        status TEXT NOT NULL DEFAULT 'inside',
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      )
    ''');

    // สร้าง index สำหรับการค้นหาที่เร็วขึ้น
    await db.execute('''
      CREATE INDEX idx_vehicle_records_status ON vehicle_records(status)
    ''');

    await db.execute('''
      CREATE INDEX idx_vehicle_records_entry_time ON vehicle_records(entry_time)
    ''');
  }

  // แปลง VehicleType enum เป็น String
  String _vehicleTypeToString(VehicleType type) {
    switch (type) {
      case VehicleType.delivery:
        return 'delivery';
      case VehicleType.passenger:
        return 'passenger';
      case VehicleType.visitor:
        return 'visitor';
    }
  }

  // แปลง String เป็น VehicleType enum
  VehicleType _stringToVehicleType(String type) {
    switch (type) {
      case 'delivery':
        return VehicleType.delivery;
      case 'passenger':
        return VehicleType.passenger;
      case 'visitor':
        return VehicleType.visitor;
      default:
        return VehicleType.visitor;
    }
  }

  // แปลง VehicleStatus enum เป็น String
  String _vehicleStatusToString(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.inside:
        return 'inside';
      case VehicleStatus.exited:
        return 'exited';
      case VehicleStatus.archived:
        return 'archived';
    }
  }

  // แปลง String เป็น VehicleStatus enum
  VehicleStatus _stringToVehicleStatus(String status) {
    switch (status) {
      case 'inside':
        return VehicleStatus.inside;
      case 'exited':
        return VehicleStatus.exited;
      case 'archived':
        return VehicleStatus.archived;
      default:
        return VehicleStatus.inside;
    }
  }

  // แปลง VehicleRecord เป็น Map สำหรับบันทึกลงฐานข้อมูล
  Map<String, dynamic> _vehicleRecordToMap(VehicleRecord record) {
    return {
      'id': record.id,
      'license_plate': record.licensePlate,
      'house_number': record.houseNumber,
      'vehicle_type': _vehicleTypeToString(record.vehicleType),
      'entry_time': record.entryTime.millisecondsSinceEpoch,
      'exit_time': record.exitTime?.millisecondsSinceEpoch,
      'status': _vehicleStatusToString(record.status),
    };
  }

  // แปลง Map เป็น VehicleRecord
  VehicleRecord _mapToVehicleRecord(Map<String, dynamic> map) {
    return VehicleRecord(
      id: map['id'],
      licensePlate: map['license_plate'],
      houseNumber: map['house_number'],
      vehicleType: _stringToVehicleType(map['vehicle_type']),
      entryTime: DateTime.fromMillisecondsSinceEpoch(map['entry_time']),
      exitTime:
          map['exit_time'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['exit_time'])
              : null,
      status: _stringToVehicleStatus(map['status']),
    );
  }

  // บันทึกข้อมูลรถใหม่
  Future<int> insertVehicleRecord(VehicleRecord record) async {
    final db = await database;
    return await db.insert(
      'vehicle_records',
      _vehicleRecordToMap(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // อัพเดทข้อมูลรถ
  Future<int> updateVehicleRecord(VehicleRecord record) async {
    final db = await database;
    return await db.update(
      'vehicle_records',
      _vehicleRecordToMap(record),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // ลบข้อมูลรถ
  Future<int> deleteVehicleRecord(String id) async {
    final db = await database;
    return await db.delete('vehicle_records', where: 'id = ?', whereArgs: [id]);
  }

  // ดึงข้อมูลรถทั้งหมด (เรียงตามเวลาเข้าล่าสุด)
  Future<List<VehicleRecord>> getAllVehicleRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicle_records',
      orderBy: 'entry_time DESC',
    );

    return List.generate(maps.length, (i) => _mapToVehicleRecord(maps[i]));
  }

  // ดึงข้อมูลรถตามสถานะ
  Future<List<VehicleRecord>> getVehicleRecordsByStatus(
    VehicleStatus status,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicle_records',
      where: 'status = ?',
      whereArgs: [_vehicleStatusToString(status)],
      orderBy: 'entry_time DESC',
    );

    return List.generate(maps.length, (i) => _mapToVehicleRecord(maps[i]));
  }

  // ดึงข้อมูลรถในวันที่กำหนด
  Future<List<VehicleRecord>> getVehicleRecordsByDate(DateTime date) async {
    final db = await database;

    // หาช่วงเวลาของวันที่กำหนด (00:00:00 - 23:59:59)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'vehicle_records',
      where: 'entry_time BETWEEN ? AND ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'entry_time DESC',
    );

    return List.generate(maps.length, (i) => _mapToVehicleRecord(maps[i]));
  }

  // ค้นหาข้อมูลรถตามป้ายทะเบียน
  Future<List<VehicleRecord>> searchVehicleRecords(String licensePlate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicle_records',
      where: 'license_plate LIKE ?',
      whereArgs: ['%$licensePlate%'],
      orderBy: 'entry_time DESC',
    );

    return List.generate(maps.length, (i) => _mapToVehicleRecord(maps[i]));
  }

  // นับจำนวนรถตามสถานะ
  Future<int> countVehiclesByStatus(VehicleStatus status) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vehicle_records WHERE status = ?',
      [_vehicleStatusToString(status)],
    );
    return result.first['count'] as int;
  }

  // นับจำนวนรถทั้งหมดในวันนี้
  Future<int> countTodayVehicles() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vehicle_records WHERE entry_time BETWEEN ? AND ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return result.first['count'] as int;
  }

  // ดึงสถิติการใช้งานตามประเภทรถ
  Future<Map<VehicleType, int>> getVehicleTypeStatistics() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT vehicle_type, COUNT(*) as count FROM vehicle_records GROUP BY vehicle_type',
    );

    Map<VehicleType, int> statistics = {
      VehicleType.delivery: 0,
      VehicleType.passenger: 0,
      VehicleType.visitor: 0,
    };

    for (var row in result) {
      final type = _stringToVehicleType(row['vehicle_type'] as String);
      statistics[type] = row['count'] as int;
    }

    return statistics;
  }

  // ลบข้อมูลเก่าที่เก็บไว้นานเกินกำหนด (เช่น 30 วัน)
  Future<int> deleteOldArchivedRecords({int daysToKeep = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    return await db.delete(
      'vehicle_records',
      where: 'status = ? AND entry_time < ?',
      whereArgs: [
        _vehicleStatusToString(VehicleStatus.archived),
        cutoffDate.millisecondsSinceEpoch,
      ],
    );
  }

  // ปิดฐานข้อมูล
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // เคลียร์ข้อมูลทั้งหมด (ใช้สำหรับการทดสอบ)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('vehicle_records');
  }

  // Export ข้อมูลเป็น JSON สำหรับการ backup
  Future<List<Map<String, dynamic>>> exportToJson() async {
    final db = await database;
    return await db.query('vehicle_records', orderBy: 'entry_time DESC');
  }

  // Import ข้อมูลจาก JSON backup
  Future<void> importFromJson(List<Map<String, dynamic>> jsonData) async {
    final db = await database;

    await db.transaction((txn) async {
      for (var record in jsonData) {
        await txn.insert(
          'vehicle_records',
          record,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
