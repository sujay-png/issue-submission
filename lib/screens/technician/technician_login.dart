import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:issue_submission_interface/screens/technician/technician_workspace.dart';

class TechnicianLogin extends StatefulWidget {
  const TechnicianLogin({super.key});

  @override
  State<TechnicianLogin> createState() => _TechnicianLoginState();
}

class _TechnicianLoginState extends State<TechnicianLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definining Main Interface Colors from Image
    const Color primaryColor = Color(0xFF1D4ED8); // Vivid Blue
    const Color titleColor = Color(0xFF0F172A); // Dark Slate/Navy
    const Color buttonColor = Color(0xFF1E293B); // Dark Navy/Charcoal

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light background tint
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
             constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
            
                // 1. Lock Icon in Blue Curved Square
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      // Specific border radius to match the modern "superellipse" look
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
            
                // 2. Title Section
                const Text(
                  'technicial Portal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Front Desk Login',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 25),
            
                // 3. Username Field (using helper)
                _buildInputField(
                  controller: _emailController,
                  label: 'Username',
                  hintText: 'e.g. front_desk_admin',
                  icon: Icons.person_outline_rounded,
                ),
            
                // 4. Password Field (using helper)
                _buildInputField(
                  label: 'Password',
                  hintText: '••••••••••••',
                  controller: _passwordController,
                  icon: Icons.lock_open_outlined,
                  isPassword: true,
                ),
            
                const SizedBox(height: 10),
            
                // 5. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
            
                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter your credentials"),
                          ),
                        );
                        return;
                      }
            
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  TechnicianWorkspace(currentUserUid: _auth.currentUser!.uid,),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        // This captures the 400 error and tells you WHY it failed
                        print("Firebase Error Code: ${e.code}");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Login Failed: ${e.message}")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor, // Matches design color
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 12),
                        // Matches the design's arrow icon
                        Icon(Icons.login_rounded, size: 22),
                      ],
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

  Widget _buildInputField({
    required String label,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    // Definining Colors from the Design Image
    const Color labelColor = Color(0xFF64748B); // Slate/Grey
    const Color fillColor = Color(0xFFFAFBFC); // Very light grey
    const Color iconColor = Color(0xFF94A3B8); // Medium grey

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the field
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        // The stylized text field
        TextField(
          obscureText: isPassword,
          controller:
              controller, // If password, center the dots like the design

          style: const TextStyle(color: Color(0xFF1E293B)), // Text color
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            // Light grey prefix icon
            prefixIcon: Icon(icon, color: iconColor),
            // Borderless modern look
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
