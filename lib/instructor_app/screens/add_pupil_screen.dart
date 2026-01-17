import 'package:flutter/material.dart';
import '../services/pupil_service.dart';
import '../services/instructor_service.dart';
import '../services/branch_service.dart';
import '../services/package_service.dart';

class AddPupilScreen extends StatefulWidget {
  const AddPupilScreen({super.key});

  @override
  State<AddPupilScreen> createState() => _AddPupilScreenState();
}

class _AddPupilScreenState extends State<AddPupilScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String? instructorId;
  String? areaId;
  String? packageId;

  List instructors = [];
  List areas = [];
  List packages = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    instructors = await InstructorService.getAllInstructors();
    areas = await BranchService.getBranches();
    packages = await PackageService.getPackages();

    setState(() => loading = false);
  }

  Future<void> _savePupil() async {
    if (instructorId == null || areaId == null) return;

    await PupilService.createPupil({
      "full_name": nameCtrl.text,
      "phone": phoneCtrl.text,
      "email": emailCtrl.text,
      "instructor_id": instructorId,
      "area_id": areaId,
      "package_id": packageId,
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Pupil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),

          const SizedBox(height: 16),

          DropdownButtonFormField(
            value: instructorId,
            decoration: const InputDecoration(labelText: 'Instructor'),
            items: instructors.map<DropdownMenuItem<String>>((i) {
              return DropdownMenuItem(
                value: i.id,
                child: Text(i.email),
              );
            }).toList(),
            onChanged: (v) => setState(() => instructorId = v),
          ),

          DropdownButtonFormField(
            value: areaId,
            decoration: const InputDecoration(labelText: 'Area'),
            items: areas.map<DropdownMenuItem<String>>((a) {
              return DropdownMenuItem(
                value: a['_id'],
                child: Text(a['name']),
              );
            }).toList(),
            onChanged: (v) => setState(() => areaId = v),
          ),

          DropdownButtonFormField(
            value: packageId,
            decoration: const InputDecoration(labelText: 'Package'),
            items: packages.map<DropdownMenuItem<String>>((p) {
              return DropdownMenuItem(
                value: p['_id'],
                child: Text('${p['package_name']} (${p['duration']} hrs)'),
              );
            }).toList(),
            onChanged: (v) => setState(() => packageId = v),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _savePupil,
            icon: const Icon(Icons.save),
            label: const Text('Create Pupil'),
          ),
        ],
      ),
    );
  }
}
