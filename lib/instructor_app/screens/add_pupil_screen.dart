import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pupil_provider.dart';
import '../services/pupil_service.dart';
import '../services/instructor_service.dart';
import '../services/branch_service.dart';
import '../services/package_service.dart';

class AddPupilScreen extends StatefulWidget {
  final Map<String, dynamic>? pupil;

  const AddPupilScreen({super.key, this.pupil});

  @override
  State<AddPupilScreen> createState() => _AddPupilScreenState();
}

class _AddPupilScreenState extends State<AddPupilScreen> {
  final _formKey = GlobalKey<FormState>();
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
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load dropdowns
    instructors = await InstructorService.getAllInstructors();
    areas = await BranchService.getBranches();
    packages = await PackageService.getPackages();

    // 2. If editing, pre-fill form
    if (widget.pupil != null) {
      final p = widget.pupil!;
      nameCtrl.text = p['full_name'] ?? '';
      phoneCtrl.text = p['phone'] ?? '';
      emailCtrl.text = p['email'] ?? '';

      // IDs might be objects or strings depending on API population
      if (p['instructor_id'] is Map) {
        instructorId = p['instructor_id']['_id'];
      } else {
        instructorId = p['instructor_id'];
      }

      if (p['area_id'] is Map) {
         areaId = p['area_id']['_id'];
      } else {
         areaId = p['area_id'];
      }

      if (p['package_id'] is Map) {
         packageId = p['package_id']['_id'];
      } else {
         packageId = p['package_id'];
      }
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> _savePupil() async {
    if (!_formKey.currentState!.validate()) return;

    if (instructorId == null || areaId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an instructor and area', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    final data = {
      "full_name": nameCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "instructor_id": instructorId,
      "area_id": areaId,
      if (packageId != null) "package_id": packageId,
      "active": widget.pupil?['active'] ?? 1,
      "payment_status": widget.pupil?['payment_status'] ?? 'unpaid',
      "progress": widget.pupil?['progress'] ?? 0,
    };

    try {
      if (widget.pupil != null) {
        // Update
        await context.read<PupilProvider>().updatePupil(widget.pupil!['_id'], data);
      } else {
        // Create
        await PupilService.createPupil(data);
        if (mounted) {
           await context.read<PupilProvider>().fetchPupils();
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMsg', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.pupil != null ? 'Edit Pupil' : 'Add Pupil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl, 
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(), errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red))),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter Full Name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneCtrl, 
              decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red))),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter Phone' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailCtrl, 
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red))),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter Email' : null,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: instructorId, // changed from initialValue to value for reactive updates
              decoration: const InputDecoration(labelText: 'Instructor', border: OutlineInputBorder()),
              validator: (v) => v == null ? 'Please select an Instructor' : null,
              items: instructors.map<DropdownMenuItem<String>>((i) {
                return DropdownMenuItem(
                  value: i.id,
                  child: Text(i.email),
                );
              }).toList(),
              onChanged: (v) => setState(() => instructorId = v),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: areaId,
              decoration: const InputDecoration(labelText: 'Area', border: OutlineInputBorder()),
              validator: (v) => v == null ? 'Please select an Area' : null,
              items: areas.map<DropdownMenuItem<String>>((a) {
                return DropdownMenuItem(
                  value: a['_id'],
                  child: Text(a['name']),
                );
              }).toList(),
              onChanged: (v) => setState(() => areaId = v),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: packageId,
              decoration: const InputDecoration(labelText: 'Package (Optional)', border: OutlineInputBorder()),
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
              label: Text(widget.pupil != null ? 'Update Pupil' : 'Create Pupil'),
            ),
          ],
        ),
      ),
    );
  }
}
