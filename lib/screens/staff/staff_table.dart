import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';
import 'package:issue_submission_interface/screens/staff/assign_technician.dart';
import 'package:issue_submission_interface/service/firebase_service.dart';

// Staff Center Mapping
const Map<String, String> staffCenterMapping = {
  'mlr@electrocoresystems.in': 'Mangaluru',
  'blr@electrocoresystems.in': 'Bangalore',
  'udupi@electrocoresystems.in': 'Udupi',
};

class StaffTable extends StatelessWidget {
 
  final BuildContext context;
  final Color primaryBlue;
  final Color tableHeaderColor;

  const StaffTable({
    super.key,
    required this.primaryBlue,
    required this.tableHeaderColor,
   
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: tableHeaderColor,
      letterSpacing: 1.1,
    );

    final user = FirebaseAuth.instance.currentUser;
    final staffEmail = user?.email ?? '';
    final staffCenter = staffCenterMapping[staffEmail] ?? 'Unknown';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),

            //======================FETCH TICKECT ID==========================
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading tickets: ${snapshot.error}"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<TicketModel> ticketList = snapshot.data!.docs.map((
                  doc,
                ) {
                  return TicketModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                final filteredTickets = ticketList
                    .where((ticket) => ticket.center == staffCenter)
                    .toList();

                filteredTickets.sort((a, b) {
                  final aDate = a.createdAt as Timestamp?;
                  final bDate = b.createdAt as Timestamp?;

                  if (aDate == null || bDate == null) return 0;
                  return bDate.compareTo(aDate); // Newest first
                });

                if (filteredTickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tickets for $staffCenter',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1500,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.grey.shade100,
                      ),
                      //=========================DATATABLE====================================================
                      child: DataTable(
                        columnSpacing: 10,
                        showCheckboxColumn: false,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF8FAFC),
                        ),
                        dataRowMinHeight: 70,
                        dataRowMaxHeight: 80,
                        horizontalMargin: 15,
                        border: const TableBorder(
                          horizontalInside: BorderSide(
                            color: Color(0xFFF1F5F9),
                          ),
                        ),
                        columns: [
                          DataColumn(
                            label: Text('TICKET ID', style: headerStyle),
                          ),
                          DataColumn(
                            label: Text('CUSTOMER NAME', style: headerStyle),
                          ),
                          DataColumn(
                            label: Text('CUSTOMER PHONENO', style: headerStyle),
                          ),
                          DataColumn(label: Text('DEVICE', style: headerStyle)),
                          DataColumn(
                            label: Text('ASSIGNEE', style: headerStyle),
                          ),
                          DataColumn(
                            label: Text('WORK STATUS', style: headerStyle),
                          ),
                          DataColumn(
                            label: Text(
                              'PARTS REQUIREMENT',
                              style: headerStyle,
                            ),
                          ),
                          DataColumn(
                            label: Text('PAYMENT', style: headerStyle),
                          ),
                        ],
                        // Map the filtered TicketModel list to DataRows
                        rows: filteredTickets.map((ticket) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected != null && selected) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AssignTechnician(ticket: ticket),
                                  ),
                                );
                              }
                            },
                            cells: [
                              DataCell(
                                Text(
                                  ticket.ticketId,
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  ticket.contactName,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  ticket.phone,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ticket.brandModel,
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      ticket.category.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Assignee logic
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.amber[800],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      (ticket.assignee == null ||
                                              ticket.assignee!.isEmpty)
                                          ? 'UNASSIGNED'
                                          : ticket.assignee!.toUpperCase(),
                                      style: TextStyle(
                                        color:
                                            (ticket.assignee == null ||
                                                ticket.assignee!.isEmpty)
                                            ? Colors.amber[800]
                                            : const Color(0xFF192A4E),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                _statusPill(
                                  ticket.contactName.isEmpty
                                      ? 'open'
                                      : ticket.status,
                                ),
                              ),
                              DataCell(
                                Text(
                                  ticket.spareparts ?? 'N/A',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              DataCell(
                                _paymentPill(ticket.paymentstatus ?? 'UNPAID',ticket.id),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  //=====================================STATUS HELPER FUNCTION==========================================
  Widget _statusPill(String status) {
    Color bgColor = const Color(0xFFF1F5F9);
    Color textColor = const Color(0xFF475569);

    String upperStatus = status.toUpperCase();

    if (upperStatus == 'OPEN') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFB45309);
    } else if (upperStatus == 'ASSIGNED') {
      bgColor = const Color(0xFFE0F2FE);
      textColor = const Color(0xFF0369A1);
    } else if (upperStatus == 'IN PROGRESS') {
      bgColor = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF1D4ED8);
    } else if (upperStatus == 'COMPLETED' || upperStatus == 'FIXED') {
      bgColor = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF047857);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        upperStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  //=====================================PAYMENT STATUS HELPER FUNCTION==========================================

  Widget _paymentPill(String status, String docId) {
    // Normalize the status for comparison
    final bool isPaid = status.toUpperCase() == 'PAID';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFCE7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: isPaid ? const Color(0xFF065F46) : const Color(0xFFBE185D),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          //Done Button
          TextButton(
            onPressed: () async {
              debugPrint('ticketId value: "$docId"');
              await DatabaseService().paymentupdate(
                ticketId: docId,
                context: context,
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
