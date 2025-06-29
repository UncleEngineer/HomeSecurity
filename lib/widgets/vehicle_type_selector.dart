// widgets/vehicle_type_selector.dart
import 'package:flutter/material.dart';
import '../models/vehicle_record.dart';

class VehicleTypeSelector extends StatelessWidget {
  final VehicleType selectedType;
  final ValueChanged<VehicleType> onChanged;

  const VehicleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ประเภทรถ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        color: isSelected ? Colors.white : type.color,
                      ),
                      const SizedBox(width: 4),
                      Text(type.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) onChanged(type);
                  },
                  selectedColor: type.color,
                  backgroundColor: type.color.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : type.color,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
