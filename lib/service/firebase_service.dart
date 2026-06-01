import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============ IMAGE HANDLING ============
  Future<String?> uploadImage(File file) async {
    try {
      String fileName = 'tickets/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = _storage.ref().child(fileName);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // ============ TICKET SAVING ============
  Future<void> saveTicket(Map<String, dynamic> data) async {
    await _db.collection('tickets').add(data);
  }

  // ============ HELPER: Generate Unique Ticket ID ============
  String generateTicketId() {
    return 'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  // ============ PAGE-SPECIFIC SUBMIT METHODS ============

  Future<void> submitLaptopTicket({
    required BuildContext context,
    required bool isMounted,
    required File? issueImage,
    required File? invoiceImage,
    required String category,
    required String brandModel,
    required String description,
    required String contactName,
    required String phone,
    required String? selectedCenter,
    required Function(String ticketId) onSuccess,
    required Function(String error) onError,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate ID once
      String ticketId = generateTicketId();

      // Upload images
      String? issueImageUrl;
      String? invoiceImageUrl;

      if (issueImage != null) {
        issueImageUrl = await uploadImage(issueImage);
      }

      if (invoiceImage != null) {
        invoiceImageUrl = await uploadImage(invoiceImage);
      }

      // Create ticket model
      TicketModel newTicket = TicketModel(
        ticketId: ticketId,
        category: category,
        brandModel: brandModel,
        description: description,
        contactName: contactName,
        phone: phone,
        center: selectedCenter ?? 'Unknown',
        imageUrl: issueImageUrl,
        invoiceurl: invoiceImageUrl, // Add invoice URL to model
        status: 'Open',
        createdAt: FieldValue.serverTimestamp(),
        id: '',
      );

      // Save to Firestore
      await saveTicket(newTicket.toMap());

      // Dismiss loading and call success callback
      if (isMounted) {
        Navigator.pop(context);
        onSuccess(ticketId);
      }
    } catch (e) {
      if (isMounted) {
        Navigator.pop(context);
        onError(e.toString());
      }
    }
  }

  Future<void> submitOtherTicket({
    required BuildContext context,
    required bool isMounted,
    required File? issueImage,
    required File? invoiceImage,
    required String category,
    required String brandModel,
    required String description,
    required String contactName,
    required String phone,
    required String? selectedCenter,
    required Function(String ticketId) onSuccess,
    required Function(String error) onError,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate ID once
      String ticketId = generateTicketId();

      // Upload images
      String? issueImageUrl;
      String? invoiceImageUrl;

      if (issueImage != null) {
        issueImageUrl = await uploadImage(issueImage);
      }

      if (invoiceImage != null) {
        invoiceImageUrl = await uploadImage(invoiceImage);
      }

      // Create ticket model
      TicketModel newTicket = TicketModel(
        ticketId: ticketId,
        category: category,
        brandModel: brandModel,
        description: description,
        contactName: contactName,
        phone: phone,
        center: selectedCenter ?? 'Unknown',
        imageUrl: issueImageUrl,
        invoiceurl: invoiceImageUrl,
        status: 'Open',
        createdAt: FieldValue.serverTimestamp(),
        id: '',
      );

      // Save to Firestore
      await saveTicket(newTicket.toMap());

      // Dismiss loading and call success callback
      if (isMounted) {
        Navigator.pop(context);
        onSuccess(ticketId);
      }
    } catch (e) {
      if (isMounted) {
        Navigator.pop(context);
        onError(e.toString());
      }
    }
  }

  /// For NetworkFinalDetails page
  /// Navigates to NetworkCreateTicket screen
  Future<void> submitNetworkTicket({
    required BuildContext context,
    required bool isMounted,
    required File? issueImage,
    required File? invoiceImage,
    required String category,
    required String brandModel,
    required String description,
    required String contactName,
    required String phone,
    required String? selectedCenter,
    required Function(String ticketId) onSuccess,
    required Function(String error) onError,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate ID once
      String ticketId = generateTicketId();

      // Upload images
      String? issueImageUrl;
      String? invoiceImageUrl;

      if (issueImage != null) {
        issueImageUrl = await uploadImage(issueImage);
      }

      if (invoiceImage != null) {
        invoiceImageUrl = await uploadImage(invoiceImage);
      }

      // Create ticket model
      TicketModel newTicket = TicketModel(
        ticketId: ticketId,
        category: category,
        brandModel: brandModel,
        description: description,
        contactName: contactName,
        phone: phone,
        center: selectedCenter ?? 'Unknown',
        imageUrl: issueImageUrl,
        invoiceurl: invoiceImageUrl,
        status: 'Open',
        createdAt: FieldValue.serverTimestamp(),
        id: '',
      );

      // Save to Firestore
      await saveTicket(newTicket.toMap());

      // Dismiss loading and call success callback
      if (isMounted) {
        Navigator.pop(context);
        onSuccess(ticketId);
      }
    } catch (e) {
      if (isMounted) {
        Navigator.pop(context);
        onError(e.toString());
      }
    }
  }

  Future<void> submitPrinterTicket({
    required BuildContext context,
    required bool isMounted,
    required File? issueImage,
    required File? invoiceImage,
    required String category,
    required String brandModel,
    required String description,
    required String contactName,
    required String phone,
    required String? selectedCenter,
    required Function(String ticketId) onSuccess,
    required Function(String error) onError,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate ID once
      String ticketId = generateTicketId();

      // Upload images
      String? issueImageUrl;
      String? invoiceImageUrl;

      if (issueImage != null) {
        issueImageUrl = await uploadImage(issueImage);
      }

      if (invoiceImage != null) {
        invoiceImageUrl = await uploadImage(invoiceImage);
      }

      // Create ticket model
      TicketModel newTicket = TicketModel(
        ticketId: ticketId,
        category: category,
        brandModel: brandModel,
        description: description,
        contactName: contactName,
        phone: phone,
        center: selectedCenter ?? 'Unknown',
        imageUrl: issueImageUrl,
        invoiceurl: invoiceImageUrl,
        status: 'Open',
        createdAt: FieldValue.serverTimestamp(),
        id: '',
      );

      // Save to Firestore
      await saveTicket(newTicket.toMap());

      // Dismiss loading and call success callback
      if (isMounted) {
        Navigator.pop(context);
        onSuccess(ticketId);
      }
    } catch (e) {
      if (isMounted) {
        Navigator.pop(context);
        onError(e.toString());
      }
    }
  }

  // ============ OTHER FUNCTIONS ============
  Future<void> assignTechnician(String ticketDocId, String techName) async {
    await _db.collection('tickets').doc(ticketDocId).update({
      'assignee': techName,
      'status': 'IN PROGRESS',
    });
  }

  Future<void> saveServiceReport(String ticketDocId, String reportText) async {
    try {
      await _db.collection('tickets').doc(ticketDocId).set({
        'serviceReport': reportText,
        'reportSavedAt': FieldValue.serverTimestamp(),
        'status': 'COMPLETED',
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception("Firestore Error [${e.code}]: ${e.message}");
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

Future<void> saveparts(String ticketDocId, String newPart) async {
  try {
    await _db.collection('tickets').doc(ticketDocId).update({
      'sparepartsrequirements': FieldValue.arrayUnion([newPart]),
      'status': 'PENDING',
    });
  } on FirebaseException catch (e) {
    throw Exception("Firestore Error [${e.code}]: ${e.message}");
  } catch (e) {
    throw Exception("An unexpected error occurred: $e");
  }
}

  Future<void> showPaymentDialog({
    required BuildContext context,
    required String ticketId,
    required String docId,
    required String customerphno,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: Color(0xFF1D4ED8),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Process Checkout',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer scan to complete payment for Ticket $ticketId',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/qrcode.jpeg',
                  height: 180,
                  width: 180,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // await openWhatsAppViaDeepLink(
                      //   context: context,
                      //   ticketId: ticketId,
                      //   phone: customerphno,
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF25D366,
                      ), // WhatsApp Green
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_new, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Open WhatsApp Chat',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('tickets')
                            .doc(docId)
                            .update({'paymentStatus': 'PAID'});

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment Successful')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            return Colors.transparent;
                          }),
                        ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'Confirm Cash/Card Payment Received',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updatePartPrice({
  required String ticketId,
  required String partName,
  required String price,
  required List<String> allParts,
}) async {
  final updatedPartWithPrice = "$partName (₹$price)"; 

  List<String> updatedPayloadList = List.from(allParts);
  int index = updatedPayloadList.indexOf(partName);

  if (index != -1) {
    updatedPayloadList[index] = updatedPartWithPrice;
  }

  await _db.collection('tickets').doc(ticketId).update({
    'sparepartsrequirements': updatedPayloadList, 
  });
}
  //Streams tickets assigned to a specific technician
  Stream<QuerySnapshot> getAssignedTickets(String technicianId) {
    return _db
        .collection('tickets')
        .where('assignedTechnicianId', isEqualTo: technicianId)
        .snapshots();
  }

  //
  Stream<QuerySnapshot> getTechniciansStream() {
    return _db.collection('technicians').snapshots();
  }

  Future<void> assignTechnicianToTicket({
    required String ticketDocId,
    required String techId,
    required String techName,
    required String techDept,
  }) async {
    try {
      await _db.collection('tickets').doc(ticketDocId).update({
        'assignedTechnicianId': techId,
        'assignee': techName,
        'department': techDept,
        'status': 'IN PROGRESS',
        'assignedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to assign technician: $e");
    }
  }

  Future<UserCredential> registerTechnician({
    required String name,
    required String department,
    required String specialty,
    required String email,
    required String password,
    required String status,
  }) async {
    try {
      // 1. Create the Auth User
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String authUid = userCredential.user!.uid;

      // 2. Create the Firestore Document
      await _db.collection('technicians').doc(authUid).set({
        'id': authUid,
        'fullname': name,
        'department': department,
        'speciality': specialty,
        'email': email,
        'password': password,
        'techstatus': status,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return userCredential;
    } catch (e) {
      // Rethrow to be caught by the UI catch block
      rethrow;
    }
  }

  Future<void> unblockTech({required String techId}) async {
    try {
      await _db.collection('technicians').doc(techId).update({
        'techstatus': 'AVAILABLE',
        'unblockedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      print("Error unblocking technician: ${e.message}");
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  //Block Tech
  Future<void> blocktech({required String techId}) async {
    try {
      await _db.collection('technicians').doc(techId).update({
        'techstatus': 'BLOCKED',
        'blockedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // Catching specific Firebase errors provides better debugging
      print("Error blocking technician: ${e.message}");
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatetech({
    required String techId,
    required String? fullname,
    required String? department,
    required String? speciality,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (fullname != null && fullname.isNotEmpty) {
        updateData['fullname'] = fullname;
      }
      if (department != null && department.isNotEmpty) {
        updateData['department'] = department;
      }
      if (speciality != null && speciality.isNotEmpty) {
        updateData['speciality'] = speciality;
      }
      if (updateData.isEmpty) {
        throw Exception("No fields to update");
      }

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('technicians').doc(techId).update(updateData);
    } on FirebaseException catch (e) {
      print("Error updating technician: ${e.message}");
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  //===========================update payment status=================================

Future<void> paymentupdate({
  required String ticketId,
  required BuildContext context,
}) async {
  
  if (ticketId.trim().isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment update failed: Missing Ticket ID.')),
      );
    }
    return; // Exit early
  }

  try {
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId) // Safe now, guaranteed not to be empty
        .update({
      'paymentStatus': 'PAID',
    });
ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful')),
      );
   
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment update failed: $e')),
      );
    }
  }
}
//======================SERVICE CHARGE==============================
Future<void> saveServiceCharge({
  required String ticketDocId,
  required double amount,
}) async {
  await FirebaseFirestore.instance
      .collection('tickets')
      .doc(ticketDocId)
      .set(
        <String, Object>{'serviceCharge': amount},
        SetOptions(merge: true),  
      );
}
}
