import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';

class ReportHelper {
  /// Fetches the user's full name from Firestore or from the Google account.
  static Future<String> fetchUserName(String userId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.providerData[0].providerId == "google.com") {
        return user.displayName ?? "No Google username";
      } else {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("Users").doc(userId).get();
        if (userDoc.exists) {
          return "${userDoc['firstName']} ${userDoc['lastName']}";
        } else {
          return "User not found";
        }
      }
    } catch (e) {
      return "Error fetching name";
    }
  }

  /// Loads logo bytes from assets.
  static Future<Uint8List?> loadLogoBytes() async {
    try {
      final data = await rootBundle.load('Asset/images/logo1.jpeg');
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Requests storage permission required for PDF download.
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid && (await _isAndroid11OrAbove())) {
      PermissionStatus status = await Permission.manageExternalStorage.status;
      if (status.isGranted) return true;
      if (status.isDenied) status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required to download.')),
      );
      return false;
    } else {
      PermissionStatus status = await Permission.storage.status;
      if (status.isGranted) return true;
      if (status.isDenied) status = await Permission.storage.request();
      if (status.isGranted) return true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required to download.')),
      );
      return false;
    }
  }

  static Future<bool> _isAndroid11OrAbove() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 30;
  }

  /// Generates and downloads the PDF report.
  /// Returns a Future that completes when the process is done.
  static Future<void> downloadPDF(
      BuildContext context,
      String nameToShow,
      String imageUrl,
      String? status,
      String? result,
      String gender,
      String age,
      String history,
      Uint8List? logoBytes,
      List<String> dateTimeParts,
      ) async {
    try {
      if (!await requestStoragePermission(context)) return;

      final pdf = pw.Document();
      final datePart = dateTimeParts[0];
      final timePart = dateTimeParts[1];

      // Fetch image bytes from network if available.
      pw.MemoryImage? pdfImage;
      if (imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          pdfImage = pw.MemoryImage(response.bodyBytes);
        }
      }

      // Convert logo bytes to PDF image.
      pw.MemoryImage? logoImage;
      if (logoBytes != null) {
        logoImage = pw.MemoryImage(logoBytes);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // ----------------- Header Section -----------------
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 70,
                      height: 70,
                      child: pw.ClipOval(
                        child: pw.Image(logoImage, fit: pw.BoxFit.cover),
                      ),
                    )
                  else
                    pw.Container(width: 50, height: 50),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Text(
                        "PneumoScan",
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ),
                  pw.Container(width: 50, height: 50),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "MEDICAL REPORT",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              // ----------------- Patient Info Table -----------------
              _buildLabelValueRow("Name", nameToShow),
              _buildLabelValueRow("Date", datePart),
              _buildLabelValueRow("Time", timePart),
              _buildLabelValueRow("Sex", gender),
              _buildLabelValueRow("Age", age),
              _buildLabelValueRow("Previous Disease", history),
              pw.SizedBox(height: 10),
              // ----------------- Status & Result -----------------
              pw.Text(
                "Diagnosis Details",
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              _buildLabelValueRow("Status", status ?? "No Status"),
              _buildLabelValueRow("Result", result ?? "No Result"),
              pw.SizedBox(height: 10),
              // ----------------- X-Ray Image -----------------
              if (pdfImage != null) ...[
                pw.Text(
                  "Attached X-ray",
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Container(
                    width: 200,
                    height: 200,
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                    child: pw.Image(pdfImage, fit: pw.BoxFit.cover),
                  ),
                ),
                pw.SizedBox(height: 10),
              ],
              // ----------------- Footer Section -----------------
              pw.SizedBox(height: 20),
              pw.SizedBox(height: 150),
              pw.Text("Name of Doctor: ____________________", style: pw.TextStyle(fontSize: 10)),
              pw.Text("Signature: _________________________", style: pw.TextStyle(fontSize: 10)),
            ];
          },
        ),
      );

      // Create a unique filename using current timestamp.
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String pdfFileName = 'PneumoScan_Report_$timestamp.pdf';

      // Choose download directory.
      Directory downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        downloadDir = await getApplicationDocumentsDirectory();
      }
      final File file = File('${downloadDir.path}/$pdfFileName');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved at ${file.path}')),
      );
      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  static pw.Widget _buildLabelValueRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text("$label:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Text(value, style: pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
