import 'package:flutter/material.dart';
import 'package:issue_submission_interface/service/firebase_service.dart';

class Addsparepartsform extends StatefulWidget {
  final String ticket;
  const Addsparepartsform({super.key, required this.ticket});

  @override
  State<Addsparepartsform> createState() => _AddsparepartsformState();
}

class _AddsparepartsformState extends State<Addsparepartsform> {
  final TextEditingController partController = TextEditingController();
  final List<String> _addedParts = [];
  bool isclicked = false;

  @override
  void dispose() {
    partController.dispose();
    super.dispose();
  }

  void _addPartToList() {
    final text = partController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _addedParts.add(text);
        partController.clear(); 
      });
    }
  }

  //================================ADD PARTS BUTTON LOGIC================================

  Future<void> addparts() async {
    if (_addedParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one item before saving.")),
      );
      return;
    }

    setState(() => isclicked = true);

    try {
    
   for (final part in _addedParts) {
  await DatabaseService().saveparts(widget.ticket, part);
}


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data saved successfully!"),
          backgroundColor: Color(0xFF008952),
        ),
      );

      setState(() {
        _addedParts.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isclicked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color containerBgColor = Color(0xFFF3F6FA);
    const Color primaryTextColor = Color(0xFF192A4E);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //======================== Header Row (Title and Save Button)=========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ADD SPARE PARTS",
                style: TextStyle(
                  color: primaryTextColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
   //===================SAVE PARTS===============================
              ElevatedButton.icon(
                onPressed: isclicked ? null : addparts,
                icon: isclicked
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.description_outlined, size: 18, color: Colors.white),
                label: Text(
                  isclicked ? "Saving..." : "Save Parts",
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

          Row(
            children: [
        //================================TEXTBOX DESIGN================================
              Expanded(
                child: TextField(
                  controller: partController,
                  cursorColor: primaryTextColor,
                  style: const TextStyle(fontSize: 16, color: primaryTextColor),
                  decoration: InputDecoration(
                    hintText: "Enter an item (e.g., data cabel)...",
                    hintStyle: TextStyle(
                      color: primaryTextColor.withValues(alpha: 0.3),
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: containerBgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryTextColor.withValues(alpha: 0.05)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryTextColor.withValues(alpha: 0.1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryTextColor.withValues(alpha: 0.05)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onSubmitted: (_) => _addPartToList(), // Adds item on keyboard "Enter" action
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _addPartToList,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF427AD8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

 // ======================= Visual list displaying currently added items before submission=============================
          if (_addedParts.isNotEmpty) ...[
            Text(
              "ITEMS TO BE ADDED:",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryTextColor.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _addedParts.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EDF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF427AD8).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF192A4E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _addedParts.remove(item); 
                          });
                        },
                        child: const Icon(
                          Icons.cancel_rounded,
                          size: 16,
                          color: Color(0xFF427AD8),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // ===================Customer Visibility Info Card==============================
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3EDF9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Color(0xFF427AD8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
               
              ],
            ),
          ),
        ],
      ),
    );
  }
}