import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import 'package:issue_submission_interface/screens/Report_Problem/report_problem.dart';
import 'package:issue_submission_interface/screens/navigation/shell.dart';
import 'package:issue_submission_interface/screens/staff/staff_hub.dart';
import 'package:issue_submission_interface/screens/staff/staff_login.dart';
import 'package:issue_submission_interface/screens/staff/technician.dart';
import 'package:issue_submission_interface/screens/technician/technician_login.dart';
import 'package:issue_submission_interface/screens/technician/technician_workspace.dart';

// Staff Center Mapping
const Map<String, String> staffCenterMapping = {
  'mlr@electrocoresystems.in': 'Mangaluru',
  'blr@electrocoresystems.in': 'Bangalore',
  'udupi@electrocoresystems.in': 'Udupi',
};

// Authorized Staff Emails
const List<String> staffEmails = [
  'mlr@electrocoresystems.in',
  'blr@electrocoresystems.in',
  'udupi@electrocoresystems.in',
];

final _authListenable = FirebaseAuthListenable();
final FirebaseAuth _auth = FirebaseAuth.instance;

class FirebaseAuthListenable extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;
  FirebaseAuthListenable() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen(
      (_) => notifyListeners(),
    );
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _authListenable,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final bool loggedIn = user != null;
    final String path = state.uri.path;

    // Define route groups
    final isAuthRoute = path == '/staff-login' || path == '/technician-login';
    final isPublicRoute = path == '/' || isAuthRoute;

    // 1. Guest Access
    if (!loggedIn) {
      return isPublicRoute ? null : '/staff-login';
    }

    // 2. Role Determination
    final String userEmail = user.email ?? "";
    final bool isStaffUser = staffEmails.contains(userEmail);
    final String dashboard = isStaffUser ? '/tickets' : '/workspace';

    // 3. Prevent Logged-in users from seeing login pages
    if (isAuthRoute || path == '/') {
      return dashboard;
    }

    // 4. Role-Based Access Control (RBAC)
    if (path.startsWith('/tickets') && !isStaffUser) return '/tickets';
    if (path.startsWith('/workspace') && isStaffUser) return '/workspace';

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ReportProblem(key: ValueKey('report')),
    ),
    GoRoute(
      path: '/technician-login',
      builder: (context, state) =>
          const TechnicianLogin(key: ValueKey('tech-login')),
    ),
    GoRoute(
      path: '/staff-login',
      builder: (context, state) =>
          const StaffLogin(key: ValueKey('staff-login')),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          ShellPage(key: state.pageKey, child: child),
      routes: [
      GoRoute(
  path: '/tickets',
  builder: (context, state) {
    final extra = state.extra;

    String ticketId = '';
    String docId = '';

    if (extra is Map<String, dynamic>) {
      ticketId = extra['ticketId']?.toString() ?? '';
      docId = extra['docId']?.toString() ?? '';
    }

    return StaffHub(
      key: const ValueKey('staff-hub'),
      ticketId:ticketId ,
      docId: docId,
    );
  },
),
        GoRoute(
          path: '/fleet',
          builder: (context, state) => Technician(key: const ValueKey('fleet')),
        ),
        GoRoute(
          path: '/workspace',
          builder: (context, state) => TechnicianWorkspace(
            key: const ValueKey('tech-work'),
            currentUserUid: _auth.currentUser!.uid,
          ),
        ),
      ],
    ),
  ],
);
