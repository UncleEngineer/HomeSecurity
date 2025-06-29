// screens/main_screen.dart (แก้ไข)
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
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
  final List<VehicleRecord> _records = [];

  void _addRecord(VehicleRecord record) {
    setState(() {
      _records.insert(0, record);
    });
  }

  void _updateRecord(int index, VehicleRecord updatedRecord) {
    setState(() {
      _records[index] = updatedRecord;
    });
  }

  void _deleteRecord(int index) {
    setState(() {
      _records.removeAt(index);
    });
  }

  void _recordExit(int index) {
    setState(() {
      _records[index] = _records[index].copyWith(
        exitTime: DateTime.now(),
        status: VehicleStatus.exited,
      );
    });
  }

  void _archiveRecord(int index) {
    setState(() {
      _records[index] = _records[index].copyWith(
        status: VehicleStatus.archived,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      SecurityGuardScreen(onAddRecord: _addRecord),
      VehiclesListScreen(
        records: _records,
        onUpdateRecord: _updateRecord,
        onDeleteRecord: _deleteRecord,
        onRecordExit: _recordExit,
        onArchive: _archiveRecord,
      ),
      DashboardScreen(records: _records, onDeleteRecord: _deleteRecord),
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
