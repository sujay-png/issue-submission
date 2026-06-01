import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';
import 'package:issue_submission_interface/screens/navigation/primary_scaffold.dart';
import 'package:issue_submission_interface/screens/staff/staff_table.dart';

// ==========================STAFF LOGIN EMAIL====================================
const Map<String, String> staffCenterMapping = {
  'mlr@electrocoresystems.in': 'Mangaluru',
  'blr@electrocoresystems.in': 'Bangalore',
  'udupi@electrocoresystems.in': 'Udupi',
};

class StaffHub extends StatefulWidget {
   final String  ticketId;
    final String docId;
  const StaffHub({super.key, required this.ticketId, required this.docId});

  @override
  State<StaffHub> createState() => _StaffHubState();
}

class _StaffHubState extends State<StaffHub> {
  final String _selectedStatus = 'All';
  late String _staffCenter;
  late String _staffEmail;

  @override
  void initState() {
    super.initState();
    _initializeStaffInfo();
  }

  /// =====================Initialize staff email and center=======================================
  void _initializeStaffInfo() {
    final user = FirebaseAuth.instance.currentUser;
    _staffEmail = user?.email ?? '';
    _staffCenter = staffCenterMapping[_staffEmail] ?? 'Unknown';
    
   
  }

  @override
  Widget build(BuildContext context) {
   
 
    const Color primaryBlue = Color(0xFF1D4ED8); 
    const Color titleColor = Color(0xFF0F172A); 
    const Color labelColor = Color(0xFF64748B);
    const Color tableHeaderColor = Color(0xFF94A3B8); 

    return StaffSidebar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================== Header Section============================================
            const Text(
              'Service Queue',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Real-time status of all active repair tickets in $_staffCenter.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: labelColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 40),
               
              ],
            ),

            const SizedBox(height: 32),

            // =================================== Data Table Section==================================================
            StaffTable(
              primaryBlue: primaryBlue,
              tableHeaderColor: tableHeaderColor,
              
              context: context,
            ),
          ],
        ),
      ),
    );
  }

 
 

}