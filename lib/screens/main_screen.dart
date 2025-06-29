// screens/main_screen.dart (อัพเดทให้ใช้ Database)
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import '../services/database_helper.dart';
import 'security_guard_screen.dart';
import 'vehicles_list_screen.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<VehicleRecord> _records = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  // โหลดข้อมูลจากฐานข้อมูล
  Future<void> _loadRecords() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final records = await _databaseHelper.getAllVehicleRecords();

      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading records: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // เพิ่มข้อมูลใหม่
  Future<void> _addRecord(VehicleRecord record) async {
    try {
      await _databaseHelper.insertVehicleRecord(record);
      await _loadRecords(); // โหลดข้อมูลใหม่

      if (mounted) {
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
    } catch (e) {
      print('Error adding record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึก: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // อัพเดทข้อมูล
  Future<void> _updateRecord(int index, VehicleRecord updatedRecord) async {
    try {
      await _databaseHelper.updateVehicleRecord(updatedRecord);
      await _loadRecords(); // โหลดข้อมูลใหม่

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('แก้ไขข้อมูลเรียบร้อยแล้ว'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error updating record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการแก้ไข: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ลบข้อมูล
  Future<void> _deleteRecord(int index) async {
    try {
      if (index >= 0 && index < _records.length) {
        final recordId = _records[index].id;
        await _databaseHelper.deleteVehicleRecord(recordId);
        await _loadRecords(); // โหลดข้อมูลใหม่

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลบข้อมูลเรียบร้อยแล้ว'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการลบ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // บันทึกเวลาออก
  Future<void> _recordExit(int index) async {
    try {
      if (index >= 0 && index < _records.length) {
        final updatedRecord = _records[index].copyWith(
          exitTime: DateTime.now(),
          status: VehicleStatus.exited,
        );

        await _databaseHelper.updateVehicleRecord(updatedRecord);
        await _loadRecords(); // โหลดข้อมูลใหม่

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บันทึกเวลาออกเรียบร้อยแล้ว'),
              backgroundColor: Colors.purple,
            ),
          );
        }
      }
    } catch (e) {
      print('Error recording exit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึกเวลาออก: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // เก็บประวัติ
  Future<void> _archiveRecord(int index) async {
    try {
      if (index >= 0 && index < _records.length) {
        final updatedRecord = _records[index].copyWith(
          status: VehicleStatus.archived,
        );

        await _databaseHelper.updateVehicleRecord(updatedRecord);
        await _loadRecords(); // โหลดข้อมูลใหม่

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เก็บประวัติเรียบร้อยแล้ว'),
              backgroundColor: Colors.brown,
            ),
          );
        }
      }
    } catch (e) {
      print('Error archiving record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเก็บประวัติ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ฟังก์ชันรีเฟรชข้อมูล
  Future<void> _refreshData() async {
    await _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    // แสดง Loading Screen ขณะโหลดข้อมูล
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('กำลังโหลดข้อมูล...'),
            ],
          ),
        ),
      );
    }

    final List<Widget> pages = [
      SecurityGuardScreen(onAddRecord: _addRecord),
      VehiclesListScreen(
        records: _records,
        onUpdateRecord: _updateRecord,
        onDeleteRecord: _deleteRecord,
        onRecordExit: _recordExit,
        onArchive: _archiveRecord,
        onRefresh: _refreshData,
      ),
      DashboardScreen(
        records: _records,
        onDeleteRecord: _deleteRecord,
        onRefresh: _refreshData,
      ),
    ];

    // นับจำนวนรถที่อยู่ในหมู่บ้าน
    final activeVehiclesCount =
        _records.where((r) => r.status == VehicleStatus.inside).length;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'บันทึกข้อมูล',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.directions_car),
                if (activeVehiclesCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$activeVehiclesCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'รถในหมู่บ้าน',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
