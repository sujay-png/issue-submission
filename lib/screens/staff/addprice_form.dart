import 'package:flutter/material.dart';
import 'package:issue_submission_interface/service/firebase_service.dart';

class InlinePartCard extends StatefulWidget {
  final String part;
  final List<String> allParts;
  final String ticketId;
  final Function(bool hasPrice) onPriceChecked;

  const InlinePartCard({
    super.key,
    required this.part,
    required this.allParts,
    required this.ticketId,
    required this.onPriceChecked,
  });

  @override
  State<InlinePartCard> createState() => _InlinePartCardState();
}

class _InlinePartCardState extends State<InlinePartCard> {
  bool _isEditing = false;
  bool _isSaving = false;
  String? _savedPrice; 
  final TextEditingController _priceController = TextEditingController();
final RegExp _priceRegex = RegExp(r'\(\s*₹(\d+)\s*\)$');

  @override
void initState() {
    super.initState();
   
    final match = _priceRegex.firstMatch(widget.part);
    if (match != null) {
      _savedPrice = match.group(1); 
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPriceChecked(_savedPrice != null);
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  //===============================SAVE PRICE==============================================
  Future<void> _savePrice() async {
  final cleanPrice = _priceController.text.trim();
  if (cleanPrice.isEmpty) return;

  setState(() => _isSaving = true);

  try {
    await DatabaseService().updatePartPrice(
      ticketId: widget.ticketId,
      partName: widget.part,
      price: cleanPrice,
      allParts: widget.allParts,
    );

    if (!mounted) return;
    setState(() {
      _isEditing = false;
      _savedPrice = cleanPrice; 
    });
    widget.onPriceChecked(true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
    );
  }
  if (mounted) setState(() => _isSaving = false);
}

  @override
  Widget build(BuildContext context) {
  final bool hasExistingPrice = _savedPrice != null;
    final match = _priceRegex.firstMatch(widget.part);
  final String cleanPartName = match != null
      ? widget.part.substring(0, match.start).trim()
      : widget.part;

  

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          //=====================================DISPLAY PARTS NAME=====================================
          Text(
            cleanPartName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(width: 10),
          //===================IF PRICE MENTIONED DISPALY PRICE==========================================
          if (hasExistingPrice)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5), // Emerald tint tag structure
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
             '₹$_savedPrice',
                style: const TextStyle(
                  color: Color(0xFF065F46),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            )
          else if (_isEditing)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80,
                  height: 36,
                  child: TextField(
                    controller: _priceController,
                    key: const ValueKey('inline_price_field'),
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF192A4E),
                    ),
                    decoration: InputDecoration(
                      hintText: "Price",
                      prefixText: "₹",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF192A4E),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 22,
                        ),
                        onPressed: _savePrice,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
              ],
            )
          else
            //=======================ADD PRICE BUTTON======================================
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => setState(() => _isEditing = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192A4E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                ),
                child: const Text('Add Price', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}
