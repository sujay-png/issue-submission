import 'dart:io';
import 'package:flutter/material.dart';
import 'package:issue_submission_interface/screens/laptop_details/create_ticket.dart';
import 'package:issue_submission_interface/screens/others/create_ticket_other.dart';

import 'package:issue_submission_interface/service/firebase_service.dart';

class OtherFinalDetails extends StatefulWidget {
  final String brandmodel;
  final String category;
  const OtherFinalDetails({
    super.key,
    required this.brandmodel,
    required this.category,
  });

  @override
  State<OtherFinalDetails> createState() => _FinalDetailsState();
}

class _FinalDetailsState extends State<OtherFinalDetails> {
  bool _hasInvoice = false;
  String? _selectedCenter;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _issueImage;
  File? _invoiceImage;
  String generatedId =
      'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  final DatabaseService _dbService = DatabaseService();
  final DatabaseService _firebaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'STEP 3 OF 3',
            style: TextStyle(
              color: Color(0xFF4338CA),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SizedBox(
            width: 800,
            child: Container(
              padding: EdgeInsets.all(15),
                    
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        border: Border.all(color: Colors.blueAccent, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    // Title
                    child: Text(
                      'Final Details',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
              
                  // Problem Description Section
                  buildSectionTitle('Problem Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue',
                      fillColor: const Color(0xFFF1F5F9),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
              
                  // Add Photo Button
                  _imageUploadButton(
                    label: _issueImage == null
                        ? 'Add Issue Photo'
                        : 'Issue Photo Added',
                    onPressed: () async {
                      // 1. Call the service and wait for the file
                      File? pickedFile = await _firebaseService
                          .pickImageFromGallery();
              
                      // 2. Update the UI state with the new file
                      if (pickedFile != null) {
                        setState(() {
                          _issueImage = pickedFile;
                        });
                      }
                    },
                    isComplete: _issueImage != null,
                  ),
              
                  if (!_hasInvoice)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),
              
                  // Checkbox Section
                  Row(
                    children: [
                      Checkbox(
                        value: _hasInvoice,
                        activeColor: const Color(0xFF3B82F6),
                        onChanged: (val) {
                          setState(() {
                            _hasInvoice = val!;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Text(
                        'I have a bill / invoice',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
              
                  // 2. Conditional Photo Field
                  // This uses the "if" collection operator inside the List
                  if (_hasInvoice) ...[
                    const SizedBox(height: 16),
                    buildSectionTitle('Upload Bill Photo'),
                    const SizedBox(height: 8),
                    _imageUploadButton(
                      label: _invoiceImage == null
                          ? 'Attach Invoice'
                          : 'Invoice Attached',
                      onPressed: () async {
                        final pickedFile = await _dbService.pickImageFromGallery();
              
                        if (pickedFile != null) {
                          setState(() {
                            _invoiceImage = pickedFile;
                          });
                        }
                      },
                      isComplete: _invoiceImage != null,
                    ),
                  ],
              
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
              
                  // Contact Info Section
                  buildSectionTitle('Contact Information'),
                  const SizedBox(height: 12),
                  buildInfoTextField(
                    controller: _nameController,
                    hint: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  buildInfoTextField(
                    controller: _phoneController,
                    hint: 'Phone Number',
                    icon: Icons.phone_android_outlined,
                  ),
              
                  const SizedBox(height: 24),
              
                  // Service Center Section
                  buildSectionTitle('Service Center'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF3B82F6),
                      ),
                      fillColor: const Color(0xFFF1F5F9),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text('Select nearest center'),
                    items: [
                      'Bangalore',
                      'Mangaluru',
                      'Udupi',
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _selectedCenter = val),
                  ),
              
                  const SizedBox(height: 40),
              
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _dbService.submitOtherTicket(
                          context: context,
                          isMounted: mounted,
                          issueImage: _issueImage,
                          invoiceImage: _invoiceImage,
                          category: widget.category,
                          brandModel: widget.brandmodel,
                          description: _descController.text,
                          contactName: _nameController.text,
                          phone: _phoneController.text,
                          selectedCenter: _selectedCenter,
                          onSuccess: (ticketId) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateTicketOther(ticketId: ticketId),
                              ),
                            );
                          },
                         
                          onError: (error) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('Error: $error')));
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Ticket',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _imageUploadButton({
  required String label,
  required VoidCallback onPressed,
  required bool isComplete,
}) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(
      isComplete ? Icons.check_circle : Icons.add_a_photo_outlined,
      size: 20,
    ),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 48),
      foregroundColor: isComplete ? Colors.green : const Color(0xFF6366F1),
      side: BorderSide(
        color: isComplete ? Colors.green : const Color(0xFF6366F1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// Reusable Section Title
// Helper function for Section Title
Widget buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFF334155),
    ),
  );
}

// Helper function for Contact Info TextField
Widget buildInfoTextField({
  required String hint,
  required IconData icon,
  TextEditingController? controller, // Added controller for backend use
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
