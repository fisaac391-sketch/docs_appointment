import 'package:docs_appointment/doctor/patient_details_screen.dart';
import 'package:docs_appointment/service/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

class PatientListScreen extends StatefulWidget {
  final String ? initialSearch;
  const PatientListScreen({super.key, this.initialSearch});


  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  //late TextEditingController _searchController;

  late TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Additonal mock patients for doctor directory
  final List<Map<String, String>> _mockDirectoryPatients = [
    {
      "id": "pat_demo",
      "name": "john Doe",
      "email": "John.doe@gmail.com",
      "age": "32",
      "gender": "Male",
    },
    {
      "id": "pat_2",
      "name": "Clara Oswald",
      "email": "clara.oswald@gmail.com",
      "age": "26",
      "gender": "Female",
    },
    {
      "id": "pat_3",
      "name": "Robert Bruce",
      "email": "Robert.bruce@gmail.com",
      "age": "54",
      "gender": "Male",
    }
  ];
  @override
  void iniState() {
    super.initState();
    _searchQuery = widget.initialSearch ?? "";
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose () {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredPatients = _mockDirectoryPatients.where((pat) {
      return pat["name"]!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      pat["email"]!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Directory", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: AppTheme.premiumShadow,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: isDark ? Colors.white : AppTheme.primary),
                decoration: InputDecoration(
                  hintText: "Search patient name...",
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.accent),
                  filled: true,
                  fillColor: isDark ? const Color(0xff0f172a) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // Patients List
          Expanded(
            child: filteredPatients.isEmpty
                ? const Center(
              child: Text("No Patients found"),
            )
               : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                    final pat = filteredPatients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.accent.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppTheme.accent),
                        ),
                        title: Text(pat["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("age: ${pat["age"]}  ${pat["gender"]}  ${pat["emaol"]}"),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatientDetailsScreen(
                                patientId: pat["id"]!,
                                patientName: pat["name"]!,
                                age: pat["age"]!,
                                gender: pat["gender"]!,
                                email: pat["email"]!,
                              ),
                            ),
                          );
                        },
                      ),
                    );
              },
                ),
          ),
        ],
      ),
    );
  }
}
