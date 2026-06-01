import 'package:flutter/material.dart';
import 'package:issue_submission_interface/service/firebase_service.dart';
import 'package:issue_submission_interface/service/paymentsetup.dart';

class Savedocument extends StatefulWidget {
  final String ticket;
  final String custname;
  final String devicename;
  final String deviceproblem;
  final String phoneno;
  final String status;
  final String paymentstatus;


  const Savedocument({super.key,required this.ticket,
   required this.custname, 
   required this.devicename, 
   required this.deviceproblem, 
   required this.phoneno,
   required this.status,
   required this.paymentstatus,

   });

  @override
  State<Savedocument> createState() => _SavedocumentState();
}

class _SavedocumentState extends State<Savedocument> {
  
  @override
  Widget build(BuildContext context) {
    final TextEditingController reportController = TextEditingController();
    bool isLoading = false;
 
    
    @override
  void dispose() {
    reportController.dispose(); 
    super.dispose();
  }

//=================================SAVE DOCUMENTATION BUTTON LOGIC=============================
 Future<void> handleSaveReport() async {
  final report = reportController.text.trim();

  if (report.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter report details before saving."),
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    // Save report
    await DatabaseService().saveServiceReport(
      widget.ticket,
      report,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Report saved successfully!"),
        backgroundColor: Color(0xFF008952),
      ),
    );

    //====================== Send WhatsApp message========================================
    await UPIPaymentService().whatsappcustomer(
      context: context,
      ticketId: widget.ticket,
      customername: widget.custname,
      devicename: widget.devicename,
      deviceproblem: widget.deviceproblem,
      phone: widget.phoneno,
      status: widget.status,
      Paymentstatus: widget.paymentstatus
     
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Failed to save: $e"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
    const Color containerBgColor = Color(0xFFF3F6FA);   
    const Color primaryTextColor = Color(0xFF192A4E);

    return Container(
      color: Colors.white, 
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ==============================Section Title=======================================
              Text(
                "SERVICE DOCUMENTATION",
                style: TextStyle(
                  color: primaryTextColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
             
             ElevatedButton.icon(
              onPressed: isLoading ? null : handleSaveReport,
              icon: isLoading 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.description_outlined, size: 18, color: Colors.white),
              label: Text(
                isLoading ? "Saving..." : "Save Report",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192A4E),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
            
        
            ],
          ),
          const SizedBox(height: 16),

//==================TEXTBOX DESIGN=========================================
          TextField(
            controller: reportController,
            maxLines: 12, 
            cursorColor: primaryTextColor,
            style: const TextStyle(fontSize: 16, color: primaryTextColor),
            decoration: InputDecoration(
              hintText: "Document your findings, parts replaced, and work done here...",
              hintStyle: TextStyle(
                color: primaryTextColor.withValues(alpha: 0.3),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: containerBgColor,
              // Smooth rounded corners and light border
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: primaryTextColor.withValues(alpha: 0.05)),
              ),
             
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: primaryTextColor.withValues(alpha: 0.1), width: 1.5),
              ),
             
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: primaryTextColor.withValues(alpha: 0.05)),
              ),
              contentPadding: const EdgeInsets.all(24),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: containerBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryTextColor.withValues(alpha: 0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EDF9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Color(0xFF427AD8), 
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
//=========================Note summary====================================                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Customer Visibility",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "The notes you enter here are final. Once the job is marked as \"Fixed\", this report will be automatically send whatsapp message to the customer as part of their service summary.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: primaryTextColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}