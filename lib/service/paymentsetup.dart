import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UPIPaymentService {
  
  static const String UPI_ID = '7353022229@pthdfc';
  static const String MERCHANT_NAME = 'Dayanand Prabhu';
  
 static Future<void> openWhatsAppWeb({
  
    required BuildContext context,
    required String ticketId,
    required String brandname,
    required String devicename,
    required String deviceproblem,
    required String phone,
     required String amount,
         String? transactionRef,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
 final String upiUrl = 'upi://pay'
          '?pa=$UPI_ID'
          '&pn=${Uri.encodeComponent(MERCHANT_NAME)}'
          '&am=$amount'
          '&tn=${Uri.encodeComponent('Payment for Repair Service')}'
          '&tr=${transactionRef ?? DateTime.now().millisecondsSinceEpoch}';
    
    final String message = 
        '*Ticket Payment Summary*\n\n'
        '• *Ticket ID:* $ticketId\n'
        '• *Brand Name:* $brandname\n'
        '• *Device Name:* $devicename\n'
        '• *Device Problem:* $deviceproblem\n'
        '• *Status:* Pending Scan\n\n'
        '*Scan/View your Payment QR Code here:* \n$upiUrl';
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappWebUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    try {
      await launchUrl(
        whatsappWebUri,
        mode: LaunchMode.platformDefault, 
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp Web: $e')),
        );
      }
    }
  }

  //Send Whatsapp final message
  Future<void> whatsappcustomer({
  
    required BuildContext context,
    required String ticketId,
    required String customername,
    required String devicename,
    required String deviceproblem,
    required String status,
    required String Paymentstatus,

    required String phone,
  
      
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    
    final String message = 
        '*Device Service Update*\n\n'
        '*Dear:* $customername\n'
        '*We are pleased to inform you that your device has been successfully repaired and is ready for collection.*\n\n'
        '*Service Details*\n\n'
        '*Device :* $devicename\n'
        '*Reported Issue:* $deviceproblem\n'
        '*Service Status* $status\n'
        '*Payment Status* $Paymentstatus\n\n'
        '*Please visit our service center at your convenience to collect your device*\n\n'
        '*If you have any questions, feel free to contact us.*\n\n'
        '*Thank you for choosing our service.\n\n';
   
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappWebUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    try {
      await launchUrl(
        whatsappWebUri,
        mode: LaunchMode.platformDefault, 
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp Web: $e')),
        );
      }
    }
  }




}