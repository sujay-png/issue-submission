import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Reusable widget to display assigned technician information
/// Shows technician name and department, or "Waiting for Assignment" if not assigned
class TechnicianDisplay extends StatelessWidget {
  final String? assignedTechnicianId;
  final TextStyle? loadingStyle;
  final TextStyle? waitingStyle;
  final TextStyle? assignedStyle;

  const TechnicianDisplay({
    super.key,
    required this.assignedTechnicianId,
    this.loadingStyle,
    this.waitingStyle,
    this.assignedStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Check if ID is null or empty
    if (assignedTechnicianId == null || assignedTechnicianId!.isEmpty) {
      return Text(
        'Waiting for Assignment',
        style: waitingStyle ??
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E88E5),
            ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('technicians')
          .doc(assignedTechnicianId)
          .get(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            'Loading...',
            style: loadingStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Text(
            'Error loading technician',
            style: waitingStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
          );
        }

        // Not found state
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            'Waiting for Assignment',
            style: waitingStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E88E5),
                ),
          );
        }

        // Success state - data found
        final techData = snapshot.data!.data() as Map<String, dynamic>;
        final String techName = techData['fullname'] ?? 'Unknown';
        final String techDept = techData['department'] ?? 'General';

        return Text(
          '$techName ($techDept)',
          style: assignedStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.green[700],
              ),
        );
      },
    );
  }
}