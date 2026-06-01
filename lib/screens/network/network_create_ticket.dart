import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issue_submission_interface/screens/Report_Problem/report_problem.dart';


class NetworkCreateTicket extends StatelessWidget {
  final String ticketId;
  const NetworkCreateTicket({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {

    void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    
    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket ID copied to clipboard!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
    return   Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Checkmark in a circular background
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDFCF5), // Pale green background
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF1CB17F), // Vivid green checkmark
                      size: 50.0,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                // "Ticket Created!" Title
                Text(
                  'Ticket Created!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A), // Very dark navy/charcoal
                  ),
                ),
                const SizedBox(height: 10.0),

                // Subtitle description
                Text(
                  'Please save this Ticket ID and show it at the service desk.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: const Color(0xFF64748B), // Medium-dark gray-blue text
                  ),
                ),
                const SizedBox(height: 30.0),

                // The Ticket ID container
                InkWell(
                  onTap: () => copyToClipboard(context, ticketId), // Copy ticket ID on tap
                  child: SizedBox(
                    width: 500,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFD1D5DB), // Light gray-blue, perhaps very slightly dashed?
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        children: [
                          // "YOUR TICKET ID" text
                          Text(
                            'YOUR TICKET ID',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF94A3B8), // Gray-blue label
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                    
                          // Ticket ID and Copy Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ticketId,
                                style: TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.w700, // Slightly bolder than just 'bold'
                                  color: const Color(0xFF0F172A), // Matched text color
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Icon(
                                Icons.copy_rounded,
                                color: const Color(0xFF94A3B8), // Icon color to match label
                                size: 24.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                // "Done" Button
                SizedBox(
                  width: 500, // Set width to fill available space
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,   MaterialPageRoute(
                            builder: (context) =>ReportProblem()
                          ));
                      // Action for when button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B), // Very dark navy-charcoal button
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20.0), // Standard padding for content
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}