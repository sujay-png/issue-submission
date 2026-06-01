import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';
import 'package:issue_submission_interface/screens/technician/addsparepartsform.dart';
import 'package:issue_submission_interface/screens/technician/savedocument.dart';

class JobcaardDescription extends StatefulWidget {
  final String ticketId;
  final TicketModel ticket;

  final Map<String, dynamic> data;
  const JobcaardDescription({
    super.key,
    required this.ticketId,
    required this.data, required this.ticket,
  });

  @override
  State<JobcaardDescription> createState() => _JobcaardDescriptionState();
}

class _JobcaardDescriptionState extends State<JobcaardDescription> {
  bool _isExpanded = false;
  int _repairStatus = 0;
  bool _showAddParts = false;

  @override
  Widget build(BuildContext context) {
    //===========================FORMATING DATE============================
    final dynamic rawDate = widget.data['createdAt'];
    String formattedDate = "Unknown Date";

    if (rawDate is Timestamp) {
      DateTime dt = rawDate.toDate();
      formattedDate =
          "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

    return Center(
      child: SizedBox(
        width: 1500,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
   //===================== Header =======================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBadge(
                        "TICKET #${widget.data['ticketId'] ?? widget.ticketId}",
                        const Color(0xFFE8EAF6),
                        const Color(0xFF5C6BC0),
                      ),
                      const SizedBox(width: 8),
     //============================MARK AS FIXED BUTTON======================================
                      Row(
                        spacing: 15,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          if (_repairStatus < 2 &&
                              widget.data['status']?.toString().toLowerCase() !=
                                  'completed')
                            SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                    _repairStatus++;
                                  });
                                },
                                icon: Icon(
                                  _repairStatus == 0
                                      ? Icons.play_circle_outline
                                      : Icons.check_circle_outline,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _repairStatus == 0
                                      ? "Start Repair"
                                      : "Mark as Fixed",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _repairStatus == 0
                                      ? const Color(0xFF5338F5)
                                      : const Color(0xFF008952),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
   //==========================ADD PARTS BUTTON===================================
                          if (widget.data['status']?.toString().toLowerCase() !='completed')
                            SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showAddParts = !_showAddParts;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5338F5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Add Parts"),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

  //============================= Title & Description=============================================
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Name Title
                  Text(
                    widget.data['brandModel'] ?? "Unknown Device",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

 //==================================Reported Date Row====================================
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Reported on $formattedDate",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

 //=========================== Customer Complaint Box=======================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                      ), // Light border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CUSTOMER COMPLAINT",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "\"${widget.data['description'] ?? 'No description provided'}\"",
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF334155),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
//================= SAVE DOCUMENT BUTTON PAGE===================================
              if (_isExpanded)
              
                Savedocument(ticket: widget.ticketId,
                phoneno: widget.ticket.phone,
                devicename: widget.ticket.brandModel,
                deviceproblem: widget.ticket.description,
                custname: widget.ticket.contactName,
                paymentstatus: widget.ticket.paymentstatus!,
                status: widget.ticket.status,),
              const SizedBox(height: 20),

//===================ADD PARTS BUTTON PAGE===================================

              if (_showAddParts) Addsparepartsform(ticket: widget.ticketId),
            ],
          ),
        ),
      ),
    );
  }
//=========================HELPER FUNCTION=================================
  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
