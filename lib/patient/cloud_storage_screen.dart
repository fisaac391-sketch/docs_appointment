import 'package:docs_appointment/service/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

class CloudStorageScreen extends StatefulWidget {
  const CloudStorageScreen({super.key});

  @override
  State<CloudStorageScreen> createState() => _CloudStorageScreenState();
}

class _CloudStorageScreenState extends State<CloudStorageScreen> {
  bool _isUploadingFile = false;
  double _uploadProgress = 0.0;
  String _uploadFileName = "";

  void _simulateUpload(String name, String size, String type) async{
    setState(() {
      _isUploadingFile = true;
      _uploadFileName = name;
      _uploadProgress = 0.0;
    });

    // Simulate progress increments
    for (int i = 1; i <= 10; i++ ){
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted){
        setState(() {
          _uploadProgress = i / 10.0;
        });
      }
    }


  }

  void _showFileSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Select File to Upload",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildFileOption(
                icon: Icons.picture_as_pdf_outlined,
                title: "Thyroid_Report_july.pdf",
                size: "1.8 MB",
                color: AppTheme.error,
                onTap: () {
                  Navigator.pop(context);
                  _simulateUpload("Thyroid_Report_july.pdf", "1.8 MB", "pdf");
                },
              ),

              _buildFileOption(
                icon: Icons.image_outlined,
                title: "Derm_skin_Rash.png",
                size: "3.2 MB",
                color: AppTheme.accent,
                onTap: () {
                  Navigator.pop(context);
                  _simulateUpload("Derm_Skin_Rash.png", "3.2 MB", "image");
                },
              ),

              _buildFileOption(
                icon: Icons.article_outlined,
                title: "Anamnesis_Intake_Form.docx",
                size: "720 KB",
                color: AppTheme.accent,
                onTap: () {
                  Navigator.pop(context);
                  _simulateUpload("Anamnesis_Intake_Form","720 KB", "doc" );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileOption({
    required IconData icon,
  required String title,
  required String size,
  required Color color,
  required VoidCallback onTap,

  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(size),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate total size in MB (mock analysis)
    double totalSize =  8.3;
    if (appState.cloudFiles.length > 3) {
      totalSize += (appState.cloudFiles.length - 3) * 2.1;
    }
    final double storageUserPercent = totalSize / 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Medical Files", style: TextStyle(fontWeight: FontWeight.bold)),
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
            // Storage Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Circular progress Indicators
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: storageUserPercent,
                            strokeWidth: 8,
                            backgroundColor: isDark ? Colors.white10 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                          ),
                        ),
                        Text(
                          "${(storageUserPercent * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text ("Secure Cloud Storage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            "${totalSize.toStringAsFixed(1)} MB of 100  MB used",
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "HIPAA Secure Encryption",
                              style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upload Status Animation
            if (_isUploadingFile)...[
              Card(
                color: AppTheme.accent.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Upoload: $_isUploadingFile",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text("${(_uploadProgress * 100).toInt()}%"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Files Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Uploaded Records", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${appState.cloudFiles.length}files", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),

            // File items
            appState.cloudFiles.isEmpty
            ? Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text("No Clinical documents found"),
            )
            : ListView.builder(
              shrinkWrap: true,
              itemCount: appState.cloudFiles.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final file = appState.cloudFiles[index];
                IconData fileIcon = Icons.insert_drive_file_outlined;
                Color iconColor = Colors.grey;

                if (file.fileType == "pdf") {
                  fileIcon = Icons.picture_as_pdf_outlined;
                  iconColor = AppTheme.error;
                } else if (file.fileType == "image" || file.fileType == "jng" || file.fileType == "png") {
                  fileIcon = Icons.image_outlined;
                  iconColor = Colors.green;
                } else if (file.fileType == "doc" || file.fileType == "docx") {
                  fileIcon = Icons.article_outlined;
                  iconColor = AppTheme.accent;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(fileIcon, color: iconColor),
                    ),
                    title: Text(
                    file.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                  ),
                    subtitle: Text(
                      "${file.size}.Upload ${file.uploadDate}",
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                      onPressed: () {
                        appState.deleteMedicalFile(file.id);
                      },
                    ),
                  ),
                );
},

    ),
          const  SizedBox(height: 100), // Spacing for fab
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFileSelectionSheet,
        backgroundColor: AppTheme.accent,
        label: const Text("Upload Document", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.cloud_upload_rounded,  color: Colors.white),
      ),
    );
  }
}
