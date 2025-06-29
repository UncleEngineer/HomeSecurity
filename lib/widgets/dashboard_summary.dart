// widgets/dashboard_summary.dart
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';
import '../models/dashboard_data.dart';

class DashboardSummary extends StatelessWidget {
  final DashboardData dashboardData;

  const DashboardSummary({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สรุปข้อมูลรถในหมู่บ้าน',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // สรุปรถที่อยู่ในหมู่บ้านตามประเภท
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
                  Icon(Icons.home, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'รถที่อยู่ในหมู่บ้านขณะนี้',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...VehicleType.values.map((type) {
                final count = dashboardData.vehicleCountByType[type] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(type.icon, color: type.color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(type.label)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: type.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count คัน',
                          style: TextStyle(
                            color: type.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // สถิติรวม
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'รถทั้งหมดวันนี้',
                '${dashboardData.records.length} คัน',
                Icons.directions_car,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'เฉลี่ยเวลาอยู่',
                dashboardData.averageTimeInVillage,
                Icons.timer,
                Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'ในหมู่บ้าน',
                '${dashboardData.vehiclesInside.length} คัน',
                Icons.home,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'เก็บประวัติแล้ว',
                '${dashboardData.archivedVehicles.length} คัน',
                Icons.archive,
                Colors.brown,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
