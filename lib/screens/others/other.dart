import 'package:flutter/material.dart';
import 'package:issue_submission_interface/screens/others/other_final_details.dart';

class Other extends StatefulWidget {
  final String category;
  const Other({super.key, required this.category});

  @override
  State<Other> createState() => _OtherState();
}

class _OtherState extends State<Other> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // 2. Listen for changes in the text field
    _controller.addListener(() {
      setState(() {
        _isButtonEnabled = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers!
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = _isButtonEnabled
        ? const Color(0xFF3B82F6)
        : const Color(0xFFE2E8F0);

    final Color textColor = _isButtonEnabled
        ? Colors.white
        : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'STEP 2 OF 3',
            style: TextStyle(
              color: Color(0xFF4338CA),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          height: 500,
          child: Container(
            padding: EdgeInsets.all(15),
        
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(color: Colors.blueAccent, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Tell us more',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Brand & Model',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 500,
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'e.g. Dell XPS 15',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 500,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            // Capture the text from the controller
                            String brandName = _controller.text;
        
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherFinalDetails(
                                  brandmodel: brandName,
                                  category: widget.category,
                                ), // Pass it here
                              ),
                            );
                          }
                        : null,
        
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          buttonColor, // Light grey for "disabled" look
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color:
                            textColor, // Text color changes based on enabled state
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
