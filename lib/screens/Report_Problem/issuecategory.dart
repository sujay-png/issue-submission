import 'package:flutter/material.dart';
import 'package:issue_submission_interface/components/issuecomponents.dart';
import 'package:issue_submission_interface/screens/laptop_details/laptop.dart';
import 'package:issue_submission_interface/screens/network/network.dart';
import 'package:issue_submission_interface/screens/others/other.dart';
import 'package:issue_submission_interface/screens/printer/printer.dart';

class Issuecategory extends StatelessWidget {
  const Issuecategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'STEP 1 OF 3',
            style: TextStyle(
              color: Color(0xFF4338CA),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'What\'s the issue with?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              width: 700,

              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: IssueComponents(
                          title: 'Laptop',
                          icon: Icons
                              .laptop_mac_outlined, // Outlined matches design better
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Laptop(category: 'Laptop'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: IssueComponents(
                          title: 'Printer',
                          icon: Icons.print_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Printer(category: 'Printer'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: IssueComponents(
                          title: 'Network',
                          icon: Icons.router_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  network(category: 'Network'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: IssueComponents(
                          title: 'Other',
                          icon: Icons.help_outline_rounded,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Other(category: 'Other'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}
