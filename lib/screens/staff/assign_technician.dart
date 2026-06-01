import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';
import 'package:issue_submission_interface/screens/staff/addprice_form.dart';
import 'package:issue_submission_interface/service/assigntechstore.dart';
import 'package:issue_submission_interface/service/firebase_service.dart';
import 'package:issue_submission_interface/service/generate_pdf.dart';
import 'package:issue_submission_interface/service/paymentsetup.dart';

class AssignTechnician extends StatefulWidget {
  final TicketModel ticket;
  final Map<String, dynamic>? techdata;

  const AssignTechnician({super.key, required this.ticket, this.techdata});

  @override
  State<AssignTechnician> createState() => _AssignTechnicianState();
}

class _AssignTechnicianState extends State<AssignTechnician> {
  final ValueNotifier<Set<String>> pricedItemsTracker = ValueNotifier<Set<String>>({});
  final TextEditingController _serviceChargeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (widget.ticket.serviceCharge != null &&
        widget.ticket.serviceCharge! > 0) {
      _serviceChargeController.text = widget.ticket.serviceCharge!
          .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _serviceChargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.techdata?['techstatus'] ?? 'AVAILABLE';
    final isBlocked = status == 'BLOCKED';

// --- Calculate amount dynamically ---
double total = double.tryParse(widget.ticket.serviceCharge?.toString() ?? '0') ?? 0.0;
  final String sparePartsData = widget.ticket.spareparts?.toString() ?? '';

  if (sparePartsData.isNotEmpty) {   
    final RegExp regExp = RegExp(r'₹?(\d+)'); 
    final Iterable<RegExpMatch> matches = regExp.allMatches(sparePartsData);

    for (final match in matches) {
      total += double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
  }
  String finalAmount = total.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        //=======================DISPLAY TICKET ID============================
        title: Text(
          widget.ticket.ticketId,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: widget.ticket.status == 'COMPLETED'
                ? Column(
                    children: [
 //=======================SEND SUMMARY BUTTON=======================================
                      ElevatedButton.icon(
                        onPressed: () {
 //=================IF STATUS COMPLETED SEND WHATSAPP MESSEAGE FOR PAYMENT WITH ALL THE DETAILS=======================

                          UPIPaymentService.openWhatsAppWeb(
                            context: context,
                            ticketId: widget.ticket.ticketId,
                            phone: widget.ticket.phone,
                            deviceproblem: widget.ticket.description,
                            brandname: widget.ticket.brandModel,
                            devicename: widget.ticket.category,
                            amount: finalAmount
                          );
                        },
                        icon: const Icon(
                          Icons.receipt_long,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Send Summary & Pay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  )
                //==============================ASSIGN TECH BUTTON ===================================
                : ElevatedButton.icon(
                    onPressed: () => _showAssignTechDialog(context),
                    icon: const Icon(Icons.add, size: 20, color: Colors.white),
                    label: const Text(
                      'Assign Technician',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
   // ============================Status badges=====================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.ticket.status == 'OPEN'
                          ? const Color(0xFFFEF3C7)
                          : widget.ticket.status == 'IN PROGRESS'
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.ticket.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.ticket.status == 'OPEN'
                            ? const Color(0xFFB45309)
                            : widget.ticket.status == 'IN PROGRESS'
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF047857),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  //==========================PAYMENT STATUS ======================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE7F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.ticket.paymentstatus!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xBE831843),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //=============================== Problem details=========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROBLEM DETAILS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 800,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.ticket.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Technician and Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  //==================================Assigned Technician Card=======================================
                  SizedBox(
                    width: 500,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ASSIGNED TECH",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TechnicianDisplay(
                            assignedTechnicianId:
                                widget.ticket.assignedTechnicianId,
                            assignedStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[700],
                            ),
                            waitingStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E88E5),
                            ),
                            loadingStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  //=======================================Submission Date Card===================================
                  SizedBox(
                    width: 500,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SUBMISSION DATE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(widget.ticket.createdAt),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            //============================================ Asset Info Card =======================================
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 500,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF60A5FA),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ASSET INFO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF60A5FA),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'MANUFACTURER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.ticket.brandModel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'DEVICE CATEGORY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.ticket.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                //============================= Track pricing completion states ==============================
                Column(
                  children: [
                    ValueListenableBuilder<Set<String>>(
                      valueListenable: pricedItemsTracker,
                      builder: (context, pricedItems, child) {
                        final List<String> partsList =
                            (widget.ticket.spareparts ?? '')
                                .split(',')
                                .map((item) => item.trim())
                                .where((item) => item.isNotEmpty)
                                .toList();

                        // The Send Quotation button shows if AT LEAST one item has a price assigned to it
                        final serviceCharge =
                            double.tryParse(
                              _serviceChargeController.text.trim(),
                            ) ??
                            0.0;
                        final bool showQuotationButton =
                            (pricedItems.isNotEmpty && partsList.isNotEmpty) ||
                            serviceCharge > 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 500,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.settings_input_component_sharp,
                                        color: Color(0xFF60A5FA),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Parts Requirements',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF60A5FA),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Parts List',
                                    style: TextStyle(
                                      fontSize: 11,

                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  partsList.isEmpty
                                      ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'n/a',
                                            style: TextStyle(
                                              color: Color(0xFF4B5563),
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: partsList.map((part) {
                                            return InlinePartCard(
                                              part: part,
                                              allParts: partsList,
                                              ticketId: widget.ticket.id,
                                              onPriceChecked: (hasPrice) {
                                                final currentSet =
                                                    Set<String>.from(
                                                      pricedItemsTracker.value,
                                                    );
                                                if (hasPrice) {
                                                  if (currentSet.add(part)) {
                                                    pricedItemsTracker.value =
                                                        currentSet;
                                                  }
                                                } else {
                                                  if (currentSet.remove(part)) {
                                                    pricedItemsTracker.value =
                                                        currentSet;
                                                  }
                                                }
                                              },
                                            );
                                          }).toList(),
                                        ),
                                  //SERVICE CHARGE LOGIC & DESIGN
                                  // --- SERVICE CHARGE INPUT ---
                                  const SizedBox(height: 20),
                                  const Divider(
                                    color: Color(0xFF1E293B),
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Service Charge',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: TextField(
                                            controller:
                                                _serviceChargeController,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}'),
                                              ),
                                            ],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF0F172A),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Enter amount',
                                              hintStyle: const TextStyle(
                                                color: Color(0xFF9CA3AF),
                                                fontSize: 13,
                                              ),
                                              // ✅ Rupee symbol
                                              prefixText: '₹ ',
                                              prefixStyle: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                              
                                      ValueListenableBuilder<TextEditingValue>(
                                        valueListenable:
                                            _serviceChargeController,
                                        builder: (context, value, _) {
                                          final amount =
                                              double.tryParse(
                                                value.text.trim(),
                                              ) ??
                                              0.0;
                                          final savedAmount =
                                              widget.ticket.serviceCharge ??
                                              0.0;
                                         
                                          final bool canSave =
                                              amount > 0 &&
                                              amount != savedAmount;

                                          return ElevatedButton(
                                            onPressed: canSave
                                                ? () async {
                                                    try {
                                                      await DatabaseService()
                                                          .saveServiceCharge(
                                                            ticketDocId: widget
                                                                .ticket
                                                                .id,
                                                            amount: amount,
                                                          );
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Service charge saved',
                                                            ),
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF047857,
                                                                ),
                                                            duration: Duration(
                                                              seconds: 2,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Failed to save: $e',
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF1D4ED8,
                                              ),
                                              disabledBackgroundColor:
                                                  const Color(0xFF334155),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              canSave
                                                  ? 'Save'
                                                  : (amount > 0
                                                        ? 'Saved ✓'
                                                        : 'Save'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          
                            if (showQuotationButton) ...[
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: SizedBox(
                                  width: 500,
                                  height: 48,

                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final RegExp priceRegex = RegExp(
                                        r'\(₹(\d+(?:\.\d+)?)\)$',
                                      );
                                      double grandTotal = 0.0;
                                      final List<Map<String, Object>>
                                      structuredItems = <Map<String, Object>>[];

                                     
                                      for (final rawPart in partsList) {
                                        final Match? match = priceRegex
                                            .firstMatch(rawPart);

                                        String partName = rawPart;
                                        double itemRate = 0.0;

                                        if (match != null) {
                                          partName = rawPart
                                              .substring(0, match.start)
                                              .trim(); // "display"
                                          itemRate =
                                              double.tryParse(
                                                match.group(1) ?? '0',
                                              ) ??
                                              0.0; // 500.0
                                        }

                                        final double itemAmount = itemRate * 1;
                                        grandTotal += itemAmount;

                                        structuredItems.add(<String, Object>{
                                          'description':
                                              partName,
                                          'qty': 1,
                                          'rate': itemRate.toStringAsFixed(
                                            2,
                                          ),
                                          'amount': itemAmount.toStringAsFixed(
                                            2,
                                          ), 
                                        });
                                      }

                                      // ✅ Service charge as separate key, not inside estimate_items
                                      final double serviceCharge =
                                          double.tryParse(
                                            _serviceChargeController.text
                                                .trim(),
                                          ) ??
                                          widget.ticket.serviceCharge ??
                                          0.0;

                                      if (serviceCharge > 0) {
                                        grandTotal += serviceCharge;
                                      }

                                      final Map<String, Object>
                                      generatedPartMap = <String, Object>{
                                        'estimate_number':
                                            widget.ticket.ticketId,
                                        'customers': <String, Object>{
                                          'name': widget.ticket.contactName,
                                          'billing_address':
                                              widget.ticket.center.isNotEmpty
                                              ? widget.ticket.center
                                              : widget.ticket.phone,
                                        },
                                        'estimate_items':
                                            structuredItems, 
                                        'service_charge': serviceCharge
                                            .toStringAsFixed(2), 
                                        'total': grandTotal.toStringAsFixed(
                                          2,
                                        ), 
                                      };

                                      await GeneratePdf().generatePdf(
                                        context,
                                        generatedPartMap,
                                        widget.ticket,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.send_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Send Quotation to WhatsApp',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFF008952,
                                      ), // WhatsApp Green Accent
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp createdAt) {
    final dateTime = createdAt.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // ======================================Show assign technician dialog===============================================
  void _showAssignTechDialog(BuildContext context) {
    final techId = widget.techdata?['id'] ?? '';
    final status = widget.techdata?['techstatus'] ?? 'AVAILABLE';
    final isBlocked = status == 'BLOCKED';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assign Technician',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Technicians list
                  StreamBuilder<QuerySnapshot>(
                    stream: DatabaseService().getTechniciansStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error loading technicians');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final techDocs = snapshot.data!.docs;

                      if (techDocs.isEmpty) {
                        return const Text('No technicians available');
                      }

                      return Column(
                        children: techDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final String techId = doc.id;
                          final String name = data['fullname'] ?? 'Unknown';
                          final String dept = data['department'] ?? 'General';
                          final String initial = name.isNotEmpty
                              ? name[0].toUpperCase()
                              : '?';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),

                            child: _buildTechnicianTile(
                              context: context,
                              ticket: widget.ticket,
                              techId: techId,
                              techName: name,
                              techDept: dept,
                              initial: initial,
                              techStatus:
                                  widget.techdata?['techstatus'] ?? 'AVAILABLE',
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Technician tile widget
  Widget _buildTechnicianTile({
    required BuildContext context,
    required TicketModel ticket,
    required String techId,
    required String techName,
    required String techDept,
    required String initial,
    required String techStatus, // Add this parameter
  }) {
    final isBlocked = techStatus == 'BLOCKED';

    return GestureDetector(
      onTap: isBlocked
          ? null // Disable tap when blocked
          : () async {
              try {
                await DatabaseService().assignTechnicianToTicket(
                  ticketDocId: ticket.id,
                  techId: techId,
                  techName: techName,
                  techDept: techDept,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Assigned $techName to ticket ${ticket.ticketId}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                  // Refresh the UI by rebuilding
                  setState(() {});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error assigning technician: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
      child: Opacity(
        opacity: isBlocked ? 0.5 : 1.0, // Visual feedback for disabled state
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isBlocked
                ? const Color(0xFFFFEBEE)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isBlocked
                  ? const Color(0xFFEF5350)
                  : const Color(0xFFE2E8F0),
              width: isBlocked ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isBlocked
                    ? const Color(0xFFFFCDD2)
                    : Colors.white,
                child: isBlocked
                    ? const Icon(Icons.lock, color: Color(0xFFD32F2F), size: 18)
                    : Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            techName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isBlocked
                                  ? const Color(0xFF9E9E9E)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (isBlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFCDD2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'BLOCKED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBlocked ? 'Unavailable - Blocked' : techDept,
                      style: TextStyle(
                        fontSize: 12,
                        color: isBlocked
                            ? const Color(0xFFF44336)
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
