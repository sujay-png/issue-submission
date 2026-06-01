import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffSidebar extends StatefulWidget {
  final Widget child;

  const StaffSidebar({super.key, required this.child});

  @override
  State<StaffSidebar> createState() => _StaffSidebarState();
}

class _StaffSidebarState extends State<StaffSidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Widget _navItem(
    BuildContext context, {
    required String route,
    required IconData icon,
    required String label,
  }) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isSelected = currentPath == route;

    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Design uses a solid blue for the selected item
          color: isSelected ? const Color(0xFF1D4ED8) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAFBFC,
      ), // Added Scaffold to provide a proper layout structure
      body: Row(
        children: [
          // 1. Fixed Sidebar
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              children: [
                // Header with Logo
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF1D4ED8),
                        size: 28,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Electrocore Systems",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value
                            .toLowerCase(); // Lowercase for case-insensitive search
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search Ticket ID...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = "");
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // Navigation Items
                Expanded(
                  child: ListView(
                    children: [
                      _navItem(
                        context,
                        route: '/tickets',
                        icon: Icons.assignment_outlined,
                        label: "Service Tickets",
                      ),
                      _navItem(
                        context,
                        route: '/fleet',
                        icon: Icons.build_circle_outlined,
                        label: "Technician Fleet",
                      ),
                    ],
                  ),
                ),

               
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: InkWell(
                        onTap: () => _handleSignOut(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
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
              
              
            
          ),

          // 2. The Main Content Area (Next to Sidebar)
          Expanded(
            child: widget.child, // This will now display on the right side
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    context.go('/staff-login');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error signing out: $e")),
    );
  }
}
}
