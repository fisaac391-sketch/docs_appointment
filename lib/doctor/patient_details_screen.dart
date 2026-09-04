import 'package:docs_appointment/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/app_state.dart';
import '../theme/app_theme.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String age;
  final String gender;
  final String email;
  const PatientDetailsScreen({super.key, required this.patientId, required this.patientName, required this.age, required this.gender, required this.email});


  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool _isEditinHistory = false;
  //late TextEditingController _historyController;
   late TextEditingController _historyController = TextEditingController();
  void iniState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final patient = appState.getPatientDetails(widget.patientId);
    _historyController = TextEditingController(
      text: patient?.medicalHistory ?? "No clinical background registered",
    );
  }

  @override
  void dispose() {
    _historyController.dispose();
    super.dispose();
  }

  void _saveMedicalHistory() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.updatePatientHistory(widget.patientId, _historyController.text);
    setState(() {
      _isEditinHistory = false;
    });
  }
  void _simulateUploadReport() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Upload Clinical Document",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: AppTheme.error),
                title: const Text("Cardiac_Echo_Report.pdf"),
                onTap: () {
                  Navigator.pop(context);
                  final appState = Provider.of<AppState>(context, listen: false);
                  appState.uploadMedicalFile("Cardiac_Echo_Report.pdf", "3,4 MB", "pdf");
                },
              ),
              ListTile(
                leading: const Icon(Icons.article, color: AppTheme.accent),
                title: const Text("Lab_Prescription.docx"),
                onTap: () {
                  Navigator.pop(context);
                  final appState = Provider.of<AppState>(context, listen: false);
                  appState.uploadMedicalFile("Lab_Prescription.docx", "850 KB", "doc");
                },
              ),
            ],
          ),
        );

    },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Look up deatiled patient or create placeholder if not present
    final patient = appState.getPatientDetails(widget.patientId) ?? Patient(
      id: widget.patientId,
      name: widget.patientName,
      email: widget.email,
      age: widget.age,
      gender: widget.gender,
      medicalHistory: "No history found",
      files: [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patirnt Chart", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Demographics Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.accent.withOpacity(0.1),
                      child: const Icon(Icons.person, color: AppTheme.accent, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patientName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            "Age: ${widget.age} Gender:${widget.gender}",
                            style: TextStyle(color: isDark ? Colors.white10 : Colors.black54, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.email,
                            style: const TextStyle(fontSize: 12, color: AppTheme.accent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Clinical Notes Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Clinical Notes & Background", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(_isEditinHistory ? Icons.save : Icons.edit_note, color: AppTheme.accent),
                  onPressed: () {
                    if (_isEditinHistory) {
                      _saveMedicalHistory();
                      } else {
                      setState(() {
                        _isEditinHistory = true;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Edit area
            _isEditinHistory
            ? Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff0f172a) : const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accent, width: 1.5),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _historyController,
                maxLines: 6,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.primary, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter clinical diagnosis, history...",
                ),
              ),
            )
                : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff0f172a) : const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              ),
              child: Text(
                patient.medicalHistory,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Shared Records Files
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Patient Clinical Folder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _simulateUploadReport,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Document"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            patient.files.isEmpty
            ? Container(
              height: 120,
              alignment: Alignment.center,
              child: const Text("No uploaded documents in patient file."),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: patient.files.length,
              itemBuilder: (context, index) {
                final file = patient.files[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.description, color: AppTheme.accent),
                    title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Size: ${file.size} Uploaded: ${file.uploadDate}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.download_rounded),
                      onPressed: () {
                        appState.triggerPushNotification(
                          "Downloading File",
                          "Downloading ${file.name} to local device folders",
                        );
                      }
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
