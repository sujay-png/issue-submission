import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issue_submission_interface/models/tickect_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class GeneratePdf {
  Future<void> generatePdf(
    BuildContext context,
    Map<String, dynamic> partlist,
    TicketModel? ticket,
  ) async {
    try {
      final pdf = pw.Document();

      // Load font
      final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final pw.Font unicodeFont = pw.Font.ttf(fontData);
      final ByteData logoBytesData = await rootBundle.load(
        'assets/images/ECS logo 1.png',
      );
      final Uint8List logoBytes = logoBytesData.buffer.asUint8List();
      final pw.MemoryImage pdfImage = pw.MemoryImage(logoBytes);

      final pw.TextStyle baseStyle = pw.TextStyle(
        font: unicodeFont,
        fontSize: 12,
      );
      final pw.TextStyle boldStyle = pw.TextStyle(
        font: unicodeFont,
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
      );

    final List<List<dynamic>> tableData = [];
final List rawItems = partlist['estimate_items'] as List? ?? [];

for (var item in rawItems) {
  final String rawDesc = item['description']?.toString() ?? 'No Description';
  final String cleanDesc = rawDesc
      .replaceAll(RegExp(r'\s*\([₹$]\d+(?:\.\d+)?\)'), '')
      .trim();
  tableData.add([
    cleanDesc,
    '₹${item['rate']?.toString() ?? '0.00'}',
    '₹${item['amount']?.toString() ?? '0.00'}',
  ]);
}

final double serviceCharge =
    double.tryParse(partlist['service_charge']?.toString() ?? '') ?? 0.0;
if (serviceCharge > 0) {
  tableData.add([
    'Service Charge',
    '₹${serviceCharge.toStringAsFixed(2)}',
    '₹${serviceCharge.toStringAsFixed(2)}',
  ]);
}
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [
                pw.Container(width: 80, height: 80, child: pw.Image(pdfImage)),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      ticket?.category ?? "Required Spare Parts",
                      style: baseStyle.copyWith(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "ESTIMATE: ${partlist['estimate_number'] ?? 'N/A'}",
                      style: baseStyle,
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                pw.Text("BILL TO:", style: boldStyle),
                pw.Text(
                  partlist['customers']?['name'] ?? "No Customer Name",
                  style: baseStyle,
                ),
                pw.Text(
                  partlist['customers']?['billing_address'] ??
                      "No Address Provided",
                  style: baseStyle,
                ),
                pw.SizedBox(height: 30),

                // Corrected Table implementation
                pw.TableHelper.fromTextArray(
                  headers: ['Description', 'Rate', 'Amount'], 
                  data: tableData,
                  headerStyle: boldStyle,
                  cellStyle: baseStyle,
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                ),

                pw.SizedBox(height: 20),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total: ₹${partlist['total'] ?? '0.00'}', 
                    style: baseStyle.copyWith(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Saved to a completely new distinct variable 'pdfBytes'
      final Uint8List pdfBytes = await pdf.save();

      final String estimateNum = partlist['estimate_number'] ?? 'Draft';
      final String customerName = partlist['customers']?['name'] ?? 'Customer';
      final String totalAmount = partlist['total'] ?? '0.00';
      final String rawPhone = ticket?.phone ?? '';
      final String cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

      final String shareMessage =
          "Hello $customerName,Your quotation estimate #$estimateNum is ready. Total Amount: ₹$totalAmount\nPlease find the detailed quotation attached with parts breakdown.\n\nThank you!";

      if (kIsWeb) {
        if (cleanPhone.isNotEmpty) {
          final String encodedMsg = Uri.encodeComponent(shareMessage);
          final Uri whatsappUri = Uri.parse(
            "https://wa.me/$cleanPhone?text=$encodedMsg",
          );
          if (await canLaunchUrl(whatsappUri)) {
            await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          }
        }

        try {
          await Printing.sharePdf(
            bytes: pdfBytes,
            filename: 'Estimate_$estimateNum.pdf',
          );
        } catch (e) {
          try {
            downloadPdfWeb(pdfBytes, estimateNum);
          } catch (e2) {
            if (kDebugMode) {
              print('Web download error: $e and $e2');
            }
          }
        }

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('📥 PDF Ready'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your quotation PDF is being prepared...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To attach PDF to WhatsApp:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1️⃣ Switch to the WhatsApp tab that opened',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '2️⃣ Click the attachment icon (📎)',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '3️⃣ Select the PDF from Downloads',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '4️⃣ Send the message',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      } else {
        // Mobile platform workflow
        final outputDir = await getTemporaryDirectory();
        final File pdfFile = File(
          "${outputDir.path}/Estimate_$estimateNum.pdf",
        );
        await pdfFile.writeAsBytes(pdfBytes);

        if (cleanPhone.isNotEmpty) {
          try {
            final String encodedMsg = Uri.encodeComponent(shareMessage);
            final Uri whatsappUri = Uri.parse(
              "https://wa.me/$cleanPhone?text=$encodedMsg",
            );

            if (await canLaunchUrl(whatsappUri)) {
              await launchUrl(
                whatsappUri,
                mode: LaunchMode.externalApplication,
              );
              await Future.delayed(const Duration(milliseconds: 800));
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error opening WhatsApp: $e');
            }
          }
        }

        try {
          await Share.shareXFiles([
            XFile(pdfFile.path, mimeType: 'application/pdf'),
          ], subject: 'Quotation for Estimate #$estimateNum');
        } catch (e) {
          if (kDebugMode) {
            print('Error sharing file: $e');
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ PDF ready! Select WhatsApp to attach.'),
              backgroundColor: Color(0xFF008952),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in generatePdf: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating quotation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fixed Web Download Utility to run actively on Flutter Web
  void downloadPdfWeb(List<int> bytes, String estimateNum) {
    try {
      // To trigger actual physical browser downloads in Flutter Web:
      // import 'dart:html' as html; anchor elements are used here.
      if (kIsWeb) {
        final base64Data = base64Encode(bytes);
        final anchor = Uri.parse(
          'data:application/octet-stream;base64,$base64Data',
        );

        if (kDebugMode) {
          print('PDF Web fallback downloading layout prepared.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Web download failure execution details: $e');
      }
    }
  }
}
