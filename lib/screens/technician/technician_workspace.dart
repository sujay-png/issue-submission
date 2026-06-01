import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';
import 'package:issue_submission_interface/screens/technician/jobcard.dart';
import 'package:issue_submission_interface/service/firebase_service.dart';

class TechnicianWorkspace extends StatefulWidget {
  final String currentUserUid;
  const TechnicianWorkspace({super.key, required this.currentUserUid});

  @override
  State<TechnicianWorkspace> createState() => _TechnicianWorkspaceState();
}

class _TechnicianWorkspaceState extends State<TechnicianWorkspace> {
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    //=============================== Fallback if not logged in==================================
    if (currentUserUid == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Not logged in',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please log in to view your assigned jobs'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
     //========================== Header Section ======================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6347EB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.build_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
 //============================== Title and User====================================
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Technician Workspace',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
//============================SIGNOUT BUTTON===========================================
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: InkWell(
                                    onTap: () => _handleSignOut(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.logout_rounded,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "Sign Out",
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
//==============================GET USERNAME WHEN LOGIN======================================
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: 'Logged in as '),
                                  TextSpan(
                                    text: getNameFromEmail(),
                                    style: const TextStyle(
                                      color: Color(0xFF6347EB),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

  //================================= Section Label===============================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ASSIGNED JOBS',
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9BA4B4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
//=======================GET ALL THE TICKECTS ASSIGNED TO THE TECHNICIAN==============================
                StreamBuilder<QuerySnapshot>(
                  stream: _dbService.getAssignedTickets(currentUserUid),

                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('❌ Snapshot error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('⏳ Loading...');
                    }

                    // Error state
                    if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error, color: Colors.red[700], size: 48),
                            const SizedBox(height: 16),
                            const Text(
                              'Error loading tickets',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => setState(() {}),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              const Text('Loading your assigned jobs...'),
                            ],
                          ),
                        ),
                      );
                    }

                    // Empty state
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_turned_in,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No jobs assigned yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your assigned tasks will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // ElevatedButton.icon(
                            //   onPressed: () =>
                            //       _showDebugDialog(context, currentUserUid),
                            //   icon: const Icon(Icons.help),
                            //   label: const Text('Troubleshoot'),
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: const Color(0xFF6347EB),
                            //   ),
                            // ),
                          ],
                        ),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final id = doc.id;

                        final ticketModel = TicketModel.fromMap(data, id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Jobcard(
                            ticketData: data,
                            ticketId: id,
                            ticket: ticketModel,
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getNameFromEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      String namePart = user.email!.split('@').first;
      namePart = namePart.replaceAll('.', ' ').replaceAll('_', ' ');
      return namePart
          .split(' ')
          .map((word) {
            if (word.isEmpty) return "";
            return word[0].toUpperCase() + word.substring(1);
          })
          .join(' ');
    }
    return "Technician";
  }

 

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      context.go('/staff-login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error signing out: $e")));
    }
  }
}
