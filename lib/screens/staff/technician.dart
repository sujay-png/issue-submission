import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:issue_submission_interface/components/technician_component.dart';
import 'package:issue_submission_interface/models/technicianmodel.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';
import 'package:issue_submission_interface/screens/navigation/primary_scaffold.dart';
import 'package:issue_submission_interface/service/firebase_service.dart';

class Technician extends StatefulWidget {
  const Technician({super.key});

  @override
  State<Technician> createState() => _TechnicianState();
}

class _TechnicianState extends State<Technician> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  String? _selectedDepartment;
  String? _currentEditingTech;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _specialtyController.clear();
      _selectedDepartment = null;
      _currentEditingTech=null;
      _isSaving = false;
    });
  }

 Future<void> _registerTechnician() async {
  final String name = _nameController.text.trim();
  final String specialty = _specialtyController.text.trim();
  final String department = _selectedDepartment ?? '';
  final String status = 'AVAILABLE'; 

  if (name.isEmpty || department.isEmpty || specialty.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields')),
    );
    return;
  }

  try {
    if (_currentEditingTech != null) {
    
      await FirebaseFirestore.instance
          .collection('technicians')
          .doc(_currentEditingTech) 
          .update({
        'fullname': name,
        'speciality': specialty,
        'department': department,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Technician updated successfully'), backgroundColor: Colors.green),
      );

    } else {
      // --- REGISTRATION LOGIC ---
      final String email = '${name.toLowerCase().replaceAll(' ', '.')}@technician.local';
      final String password = _generateRandomPassword();

      await DatabaseService().registerTechnician(
        name: name,
        department: department,
        specialty: specialty,
        email: email,
        password: password,
        status: status,
      );

      if (!mounted) return;
      _showSuccessDialog(name, email, password);
    }

    _clearForm(); 
    
  } catch (e) {
    _showErrorSnackBar('Operation failed: $e');
  } finally {
    if (mounted) {

      setState(() => _isSaving = false);
    }
  }
}
  String _generateRandomPassword() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%';
    final Random random = Random();
    return List.generate(
      12,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success dialog with credentials
  void _showSuccessDialog(String name, String email, String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Technician Registered Successfully!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Share these credentials with the technician:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _credentialRow('Name:', name),
                    const SizedBox(height: 8),
                    _credentialRow('Email:', email),
                    const SizedBox(height: 8),
                    _credentialRow('Password:', password),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Text(
                  '💡 The technician can log in using these credentials on the Technician Login screen.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _credentialRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Defining specific colors from your design
    const Color titleColor = Color(0xFF0F172A);
    const Color subtitleColor = Color(0xFF64748B);
    const Color primaryBlue = Color(0xFF1D4ED8);

    return StaffSidebar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technician Fleet',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage specialist staff and assignments.',
                      style: TextStyle(
                        fontSize: 16,
                        color: subtitleColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                // Right Side: Styled "Add Technician" Button
                ElevatedButton.icon(
                  onPressed: () => _showRegisterTechnicianDialog(context),
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label: const Text(
                    'Add Technician',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Technician List
            Expanded(
              flex: 3,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('technicians')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Convert Firestore docs to TechnicianModel list
                  final techs = snapshot.data!.docs.map((doc) {
                    return TechnicianModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                  }).toList();

                  if (techs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            color: Colors.grey,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No technicians registered yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showRegisterTechnicianDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Register First Technician'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisExtent: 310,
                          crossAxisSpacing: 25,
                          mainAxisSpacing: 15,
                        ),
                    itemCount: techs.length,
                    itemBuilder: (context, index) {
                      final tech = techs[index];

                      return Stack(
                        children: [
                          TechnicianComponent(
                            name: tech.fullname,
                            id: int.tryParse(tech.id),
                            category: tech.department,
                            specialty: tech.speciality,
                            status: tech.techstatus,
                            icon: Icons.person,
                            techdata: tech.toMap(),
                            iconcolor: const Color(0xFF2563EB),
                            containercolor: const Color(0xFFEFF6FF),
                            categoryicon: Icons.settings,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: PopupMenuButton<SampleItem>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Color(0xFF6B7280),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (SampleItem item) {
                                if (item == SampleItem.edit) {
                               _showRegisterTechnicianDialog(context, techToEdit: tech);
                                } else if (item == SampleItem.block) {
                                  _showBlockDialog(context, tech.id, tech.fullname, tech.techstatus);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                final status = tech.techstatus ?? 'AVAILABLE';
                                final isBlocked = status == 'BLOCKED';

                                return <PopupMenuEntry<SampleItem>>[
                                  const PopupMenuItem<SampleItem>(
                                    value: SampleItem.edit,
                                    child: ListTile(
                                      leading: Icon(Icons.edit_outlined,
                                          size: 20),
                                      title: Text('Edit Profile'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  PopupMenuItem<SampleItem>(
                                    value: SampleItem.block,
                                    child: ListTile(
                                      leading: Icon(
                                        isBlocked
                                            ? Icons.lock_open
                                            : Icons.block,
                                        size: 20,
                                        color: isBlocked
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      title: Text(
                                        isBlocked
                                            ? 'Unblock Technician'
                                            : 'Block Technician',
                                        style: TextStyle(
                                          color: isBlocked
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, String techId, String techName, String? currentStatus) {
    final bool isBlocked = currentStatus == 'BLOCKED';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isBlocked ? "Unblock Technician?" : "Block Technician?"),
          content: Text(
            isBlocked
                ? "Are you sure you want to unblock $techName?"
                : "Are you sure you want to block $techName?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (techId.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Error: Invalid technician ID")),
                    );
                  }
                  return;
                }

                try {
                  if (isBlocked) {
                    await DatabaseService().unblockTech(techId: techId);
                  } else {
                    await DatabaseService().blocktech(techId: techId);
                  }

                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isBlocked
                            ? "$techName has been unblocked"
                            : "$techName has been blocked"),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Backend Error: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                isBlocked ? "UNBLOCK" : "BLOCK",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show the "Register Technician" dialog
  void _showRegisterTechnicianDialog(BuildContext context, {TechnicianModel? techToEdit}) {
  // 1. Reset/Populate form values BEFORE showing the dialog
  _nameController.clear();
  _specialtyController.clear();
  _selectedDepartment = null;
  _currentEditingTech = null;

  if (techToEdit != null) {
    _nameController.text = techToEdit.fullname;
    _specialtyController.text = techToEdit.speciality;
    _selectedDepartment = techToEdit.department;
    _currentEditingTech = techToEdit.id; 
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          // ADDED 'return' HERE - This fixes your main error
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            techToEdit != null ? 'Edit Technician' : 'Register Technician',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            techToEdit != null
                                ? 'Update specialist information.'
                                : 'Add a new specialist to the service fleet.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          _clearForm();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildFieldLabel('FULL NAME'),
                  _buildTextField(hint: '', controller: _nameController),
                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Department StreamBuilder
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
                          builder: (context, snapshot) {
                            List<String> categories = [];
                            if (snapshot.hasData) {
                              categories = snapshot.data!.docs
                                  .map((doc) => TicketModel.fromMap(
                                        doc.data() as Map<String, dynamic>,
                                        doc.id,
                                      ).category)
                                  .where((category) => category.isNotEmpty)
                                  .toSet()
                                  .toList();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DEPARTMENT'),
                                _buildDropdownField(
                                  hint: snapshot.connectionState == ConnectionState.waiting
                                      ? 'Loading...'
                                      : 'Select Department',
                                  items: categories,
                                  value: _selectedDepartment,
                                  onChanged: (value) {
                                    // Use setDialogState to refresh the dropdown inside the dialog
                                    setDialogState(() {
                                      _selectedDepartment = value;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Specialty Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('SPECIALTY'),
                            _buildTextField(
                              hint: '',
                              controller: _specialtyController,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // Wrap _registerTechnician in setDialogState so the spinner shows
                     onPressed: _isSaving 
  ? null 
  : () async {
      setDialogState(() => _isSaving = true);

      await _registerTechnician();

    if (_currentEditingTech != null) {
              Navigator.pop(context); 
            }
    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                             _currentEditingTech != null ? 'Update Technician' : 'Register Technician',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Update the dropdown helper to accept current value
Widget _buildDropdownField({
  required String hint,
  required List<String> items,
  String? value,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    initialValue: value,
    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
    isExpanded: true,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    dropdownColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    items: items.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
        ),
      );
    }).toList(),
    onChanged: onChanged,
  );
}

  // Helper for labels
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  

  // Helper for text fields
  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1),
        ),
      ),
    );
  }
}

enum SampleItem { edit, block }