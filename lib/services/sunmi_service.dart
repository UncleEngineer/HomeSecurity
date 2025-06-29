// services/sunmi_service.dart (แก้ไขเป็น string บรรทัดเดียว)
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import '../models/vehicle_record.dart';

class SunmiService {
  // ความกว้างกระดาษ 58mm = ประมาณ 32 ตัวอักษร
  static const int paperWidth = 32;

  Future<void> initialize() async {
    await SunmiPrinter.bindingPrinter();
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  }

  Future<void> printText(
    String text, {
    bool bold = true,
    SunmiFontSize fontSize = SunmiFontSize.MD,
    SunmiPrintAlign align = SunmiPrintAlign.CENTER,
  }) async {
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.printText(
      text,
      style: SunmiStyle(fontSize: fontSize, bold: bold, align: align),
    );
  }

  // สร้างเส้นแบ่ง
  Future<void> printDivider({String char = "-"}) async {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText(
      char * paperWidth,
      style: SunmiStyle(
        fontSize: SunmiFontSize.XS,
        bold: false,
        align: SunmiPrintAlign.CENTER,
      ),
    );
  }

  Future<void> closePrinter() async {
    await SunmiPrinter.unbindingPrinter();
  }

  // สำหรับพิมพ์จริงผ่านเครื่อง Sunmi 58mm
  Future<void> printVehicleRecord(VehicleRecord record) async {
    try {
      await initialize();

      // Header
      await printText("บันทึกข้อมูลรถ", fontSize: SunmiFontSize.LG, bold: true);
      await printDivider();

      // Vehicle Type
      String typeText = '';
      switch (record.vehicleType) {
        case VehicleType.delivery:
          typeText = 'ส่งอาหาร/พัสดุ';
          break;
        case VehicleType.passenger:
          typeText = 'ส่งผู้โดยสาร';
          break;
        case VehicleType.visitor:
          typeText = 'แขกลูกบ้าน';
          break;
      }
      await printText("[$typeText]", fontSize: SunmiFontSize.MD, bold: true);
      await SunmiPrinter.lineWrap(1);

      // ข้อมูลหลัก - แต่ละบรรทัดเป็น string เดียว
      await printText(
        "ป้าย: ${record.licensePlate}",
        fontSize: SunmiFontSize.MD,
        bold: false,
        align: SunmiPrintAlign.LEFT,
      );

      await printText(
        "บ้านเลขที่: ${record.houseNumber}",
        fontSize: SunmiFontSize.MD,
        bold: false,
        align: SunmiPrintAlign.LEFT,
      );

      // วันที่และเวลาเข้า
      final entryDate =
          "${record.entryTime.day}/${record.entryTime.month}/${record.entryTime.year}";
      final entryTime =
          "${record.entryTime.hour.toString().padLeft(2, '0')}:${record.entryTime.minute.toString().padLeft(2, '0')}";

      await printText(
        "วันที่: $entryDate",
        fontSize: SunmiFontSize.MD,
        bold: false,
        align: SunmiPrintAlign.LEFT,
      );

      await printText(
        "เวลาเข้า: $entryTime",
        fontSize: SunmiFontSize.MD,
        bold: false,
        align: SunmiPrintAlign.LEFT,
      );

      // ข้อมูลเวลาออก (ถ้ามี)
      if (record.exitTime != null) {
        await SunmiPrinter.lineWrap(1);
        await printDivider(char: "=");
        await printText("ข้อมูลการออก", fontSize: SunmiFontSize.SM, bold: true);

        final exitTime =
            "${record.exitTime!.hour.toString().padLeft(2, '0')}:${record.exitTime!.minute.toString().padLeft(2, '0')}";

        await printText(
          "เวลาออก: $exitTime",
          fontSize: SunmiFontSize.MD,
          bold: false,
          align: SunmiPrintAlign.LEFT,
        );

        await printText(
          "ระยะเวลา: ${record.formattedTimeInVillage}",
          fontSize: SunmiFontSize.MD,
          bold: false,
          align: SunmiPrintAlign.LEFT,
        );
      }

      // Footer
      await SunmiPrinter.lineWrap(1);
      await printDivider();
      await printText("ขอบคุณครับ", fontSize: SunmiFontSize.SM, bold: false);
      await printText(
        "ระบบรปภ.อัตโนมัติ",
        fontSize: SunmiFontSize.XS,
        bold: false,
      );

      // เพิ่มเวลาพิมพ์
      final now = DateTime.now();
      final printTime =
          "${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      await SunmiPrinter.lineWrap(1);
      await printText(
        "พิมพ์: $printTime",
        fontSize: SunmiFontSize.XS,
        bold: false,
      );

      await SunmiPrinter.lineWrap(3);

      // ตัดกระดาษ (ถ้าเครื่องรองรับ)
      try {
        await SunmiPrinter.cut();
      } catch (e) {
        print('Cut paper not supported: $e');
      }

      await closePrinter();
    } catch (e) {
      print('Error printing: $e');
      await closePrinter();
      rethrow;
    }
  }

  // สำหรับแสดง Preview ก่อนพิมพ์
  String generatePrintPreview(VehicleRecord record) {
    String typeText = '';
    switch (record.vehicleType) {
      case VehicleType.delivery:
        typeText = 'ส่งอาหาร/พัสดุ';
        break;
      case VehicleType.passenger:
        typeText = 'ส่งผู้โดยสาร';
        break;
      case VehicleType.visitor:
        typeText = 'แขกลูกบ้าน';
        break;
    }

    final now = DateTime.now();
    final printTime =
        "${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    String preview = '''
      บันทึกข้อมูลรถ
${'-' * 32}
      [$typeText]

ป้าย: ${record.licensePlate}
บ้านเลขที่: ${record.houseNumber}
วันที่: ${record.entryTime.day}/${record.entryTime.month}/${record.entryTime.year}
เวลาเข้า: ${record.entryTime.hour.toString().padLeft(2, '0')}:${record.entryTime.minute.toString().padLeft(2, '0')}''';

    if (record.exitTime != null) {
      preview += '''

${'=' * 32}
     ข้อมูลการออก
เวลาออก: ${record.exitTime!.hour.toString().padLeft(2, '0')}:${record.exitTime!.minute.toString().padLeft(2, '0')}
ระยะเวลา: ${record.formattedTimeInVillage}''';
    }

    preview += '''

${'-' * 32}
      ขอบคุณครับ
   ระบบรปภ.อัตโนมัติ

พิมพ์: $printTime
    ''';

    return preview;
  }

  // ตรวจสอบสถานะเครื่องพิมพ์
  Future<bool> checkPrinterStatus() async {
    try {
      await SunmiPrinter.bindingPrinter();
      return true;
    } catch (e) {
      print('Printer not available: $e');
      return false;
    }
  }
}
