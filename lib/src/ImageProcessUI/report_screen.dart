import 'dart:typed_data';

import 'package:finalfyp/src/ImageProcessUI/report_helper.dart';
import 'package:finalfyp/src/WelcomeHome/home_screen.dart';
import 'package:finalfyp/src/Widgets/CustomButtons.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  final String userId;
  final String? imageUrl;
  final String? status;
  final String? result;
  final String? timestamp;

  const ReportScreen({
    super.key,
    required this.userId,
    this.imageUrl,
    this.status,
    this.result,
    this.timestamp,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String userName = "Fetching name...";
  String googleUserName = "";
  final TextEditingController ageController = TextEditingController();
  String gender = "Male";
  final TextEditingController diseaseHistoryController = TextEditingController();
  bool isFormSubmitted = false;
  Uint8List? logoBytes;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _loadLogoBytes();
  }

  Future<void> _fetchUserName() async {
    String name = await ReportHelper.fetchUserName(widget.userId);
    setState(() {
      userName = name;
    });
  }

  Future<void> _loadLogoBytes() async {
    Uint8List? bytes = await ReportHelper.loadLogoBytes();
    setState(() {
      logoBytes = bytes;
    });
  }

  void _submitForm() {
    if (ageController.text.isNotEmpty && diseaseHistoryController.text.isNotEmpty) {
      setState(() {
        isFormSubmitted = true;
      });
    }
  }

  List<String> _getDateTimeParts() {
    final safeTimestamp = widget.timestamp?.trim() ?? "Unknown Unknown";
    if (!safeTimestamp.contains(' ')) {
      return ["Unknown", "Unknown"];
    }
    final parts = safeTimestamp.split(' ');
    String datePart = parts.isNotEmpty ? parts[0] : "Unknown";
    String timePart = parts.length > 1 ? parts[1] : "Unknown";
    return [datePart, timePart];
  }

  void _downloadPDF() async {
    await ReportHelper.downloadPDF(
      context,
      googleUserName.isNotEmpty ? googleUserName : userName,
      widget.imageUrl ?? "",
      widget.status,
      widget.result,
      gender,
      ageController.text,
      diseaseHistoryController.text,
      logoBytes,
      _getDateTimeParts(),
    );
    // When PDF download is complete, pop this screen with a result.
    Navigator.pop(context, "downloadCompleted");
  }

  @override
  Widget build(BuildContext context) {
    final String nameToShow = googleUserName.isNotEmpty ? googleUserName : userName;
    final List<String> dateTimeParts = _getDateTimeParts();
    final String datePart = dateTimeParts[0];
    final String timePart = dateTimeParts[1];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Asset/images/welcome.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: isFormSubmitted
                    ? _buildReportUI(nameToShow, datePart, timePart)
                    : _buildForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 5,
      color: const Color(0xFFB0BEC5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Enter Details",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: gender,
              items: ["Male", "Female", "Other"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  gender = newValue!;
                });
              },
              decoration: const InputDecoration(labelText: "Gender"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: diseaseHistoryController,
              decoration: const InputDecoration(labelText: "Previous Disease"),
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              width: 300,
              onPressed: _submitForm,
              label: 'Generate Report',
              isIconButton: false,
              backgroundColor: const Color(0xFF0D2962),
              borderRadius: 30,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              textStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReportUI(String nameToShow, String datePart, String timePart) {
    return Card(
      elevation: 5,
      color: const Color(0xFFB0BEC5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'Asset/images/logo1.jpeg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "PneumoScan",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D2962)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "MEDICAL REPORT",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF010713)),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "This report is generated by PneumoScan to provide a preliminary review.\nIt is not a substitute for clinical findings. Please consult a doctor for a thorough evaluation.",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text("Name: $nameToShow", style: const TextStyle(fontSize: 14, color: Colors.black)),
            Text("Date: $datePart", style: const TextStyle(fontSize: 14, color: Colors.black)),
            Text("Time: $timePart", style: const TextStyle(fontSize: 14, color: Colors.black)),
            Text("Gender: $gender", style: const TextStyle(fontSize: 14, color: Colors.black)),
            Text("Age: ${ageController.text}", style: const TextStyle(fontSize: 14, color: Colors.black)),
            Text("Previous Disease: ${diseaseHistoryController.text}", style: const TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 20),
            const Text(
              "Status & Result",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D2962)),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2962))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text("Result", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2962))),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(widget.status ?? "No Status"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(widget.result ?? "No Result"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if ((widget.imageUrl ?? "").isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Attached X-ray",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D2962)),
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    widget.imageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                CustomElevatedButton(
                  width: 200,
                  onPressed: _downloadPDF,
                  label: "Download PDF",
                  isIconButton: false,
                  backgroundColor: const Color(0xFF0D2962),
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
                ),
                const Spacer(),
                CustomElevatedButton(
                  width: 100,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen(fromLogin: widget.userId != "guest")),
                          (Route<dynamic> route) => false,
                    );
                  },
                  label: "Done",
                  isIconButton: false,
                  backgroundColor: const Color(0xFF0D2962),
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
