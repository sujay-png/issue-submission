import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';
import 'package:issue_submission_interface/screens/technician/jobcaard_description.dart';

class Jobcard extends StatefulWidget {
  final Map<String, dynamic> ticketData;
  final TicketModel ticket;

  final String ticketId;

  const Jobcard({super.key, 
  required this.ticketData,
  required this.ticketId,
  required this.ticket});

  @override
  State<Jobcard> createState() => _JobcardState();
}

class _JobcardState extends State<Jobcard> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
//===================== Assigning Variable=============================

    final String displayId =
        widget.ticketData['ticketId']?.toString() ?? widget.ticketId;
    final status = widget.ticketData['status'] ?? 'UNKNOWN';
    final deviceName =
        widget.ticketData['description'] ?? 'Problem not defined';
    final brandname =
        widget.ticketData['brandModel'] ?? 'brandname not defined';
    final Category = widget.ticketData['category'] ?? 'category not defined';
    final customername = widget.ticketData['contactName'] ?? 'Not defined';


    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================LEFT SIDE JOBCARD=======================================
          SizedBox(
            width: 700,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        //==============================DISPLAY ID=========================
                          //
                          child: Text(
                            displayId,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        //==============================STATUS=========================
                        const Spacer(),
                        Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 10, 231, 17),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                //==================CUSTOMER DETAILS INSIDE JOB CARD=======================
                    
                    Row(
                      children: [
                        Text(
                          'Customer Name:- ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          customername,
                          style:  TextStyle(
                             color: Colors.cyanAccent.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),


                    Row(
                      children: [
                        Text(
                          'Brand Name:- ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          brandname,
                          style:  TextStyle(
                            color: Colors.cyanAccent.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Category Type:- ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          Category,
                          style: TextStyle(
                            color: Colors.cyanAccent.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'Device Name:- ',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          deviceName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          //==========================RIGHT SIDE DESCRIPTION===================================
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isExpanded
                  ? JobcaardDescription(
                      key: ValueKey(widget.ticketId),
                      ticketId: widget.ticketId,
                      data: widget.ticketData, ticket: widget.ticket,
                    )
                  : Container(
                      height: 250,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'Click a job card to view details',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
