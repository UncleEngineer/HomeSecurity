// widgets/vehicle_type_selector.dart (แก้ไขให้รองรับ onChanged เป็น null)
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';

class VehicleTypeSelector extends StatelessWidget {
  final VehicleType selectedType;
  final ValueChanged<VehicleType>? onChanged; // เปลี่ยนเป็น nullable

  const VehicleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onChanged != null; // ตรวจสอบว่า enabled หรือไม่

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ประเภทรถ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                isEnabled
                    ? Colors.black
                    : Colors.grey, // เปลี่ยนสีเมื่อ disabled
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              VehicleType.values.map((type) {
                final isSelected = selectedType == type;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 18,
                        color:
                            isEnabled
                                ? (isSelected ? Colors.white : type.color)
                                : Colors.grey, // เปลี่ยนสีเมื่อ disabled
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type.label,
                        style: TextStyle(
                          color:
                              isEnabled
                                  ? (isSelected ? Colors.white : type.color)
                                  : Colors.grey, // เปลี่ยนสีเมื่อ disabled
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected:
                      isEnabled
                          ? (selected) {
                            if (selected && onChanged != null) {
                              onChanged!(type);
                            }
                          }
                          : null, // null เมื่อ disabled
                  selectedColor: isEnabled ? type.color : Colors.grey,
                  backgroundColor:
                      isEnabled
                          ? type.color.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color:
                        isEnabled
                            ? (isSelected ? Colors.white : type.color)
                            : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  disabledColor: Colors.grey.withOpacity(
                    0.1,
                  ), // สีเมื่อ disabled
                );
              }).toList(),
        ),
      ],
    );
  }
}
