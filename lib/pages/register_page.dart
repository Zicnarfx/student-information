
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // DARK BLUE-GREEN THEME
  static const Color primaryColor = Color(0xFF237C78);
  static const Color backgroundColor = Color(0xFF102F35);
  static const Color cardColor = Color(0xFF174A50);
  static const Color accentColor = Color(0xFF65B6A5);
  static const Color textColor = Color(0xFFE8F2EF);
  static const Color mutedColor = Color(0xFFC3DCD7);

  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  // REGISTER ACCOUNT
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    UserCredential? credential;
    String? profileError;

    try {
      // STEP 1: CREATE FIREBASE AUTHENTICATION ACCOUNT
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Unable to create user account.');
      }

      // STEP 2: SAVE USER INFORMATION TO FIRESTORE
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'fullName': _name.text.trim(),
          'email': _email.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        profileError = e.toString();
      }

      // STEP 3: UPDATE DISPLAY NAME
      try {
        await user.updateDisplayName(_name.text.trim());
      } catch (e) {
        profileError ??= e.toString();
      }

      // STEP 4: SIGN OUT
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        profileError ??= 'Sign out failed: $e';
      }

      if (!mounted) return;

      setState(() => _loading = false);

      // STEP 5: SHOW SUCCESS POPUP
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            contentPadding: const EdgeInsets.all(25),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 75,
                  width: 75,
                  decoration: const BoxDecoration(
                    color: Color(0xFF245F55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF65B6A5),
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Registration Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  profileError == null
                      ? 'Your account has been created successfully. '
                          'You may now login using your registered '
                          'email and password.'
                      : 'Your Firebase Authentication account was '
                          'created, but there was a problem saving '
                          'your profile information. Please check '
                          'your Firestore security rules.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: mutedColor,
                    height: 1.5,
                  ),
                ),

                if (profileError != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Profile saving error:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    profileError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.redAccent,
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK, Login Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (!mounted) return;

      // RETURN TO LOGIN PAGE
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } finally {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    }
  }

  // INPUT DECORATION
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF789A94)),
      prefixIcon: Icon(
        icon,
        color: accentColor,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: accentColor.withOpacity(0.20),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: accentColor,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  // FIELD LABEL
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }

  // BUILD PAGE
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF102F35),
              Color(0xFF174A50),
              Color(0xFF102F35),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 32 : 24,
                vertical: isLandscape ? 15 : 25,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                ),
                child: Column(
                  children: [
                    // APP LOGO
                    Container(
                      height: isLandscape ? 60 : 75,
                      width: isLandscape ? 60 : 75,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF237C78),
                            Color(0xFF65B6A5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(23),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: isLandscape ? 32 : 40,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Join us and manage your student information',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: mutedColor,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // REGISTRATION CARD
                    Container(
                      padding: EdgeInsets.all(
                        isLandscape ? 22 : 24,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: accentColor.withOpacity(0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // FULL NAME
                            _buildLabel('Full Name'),

                            TextFormField(
                              controller: _name,
                              textCapitalization:
                                  TextCapitalization.words,
                              style: const TextStyle(color: textColor),
                              decoration: _inputDecoration(
                                hint: 'Enter your full name',
                                icon: Icons.person_outline_rounded,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // EMAIL
                            _buildLabel('Email Address'),

                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: textColor),
                              decoration: _inputDecoration(
                                hint: 'Enter your email',
                                icon: Icons.email_outlined,
                              ),
                              validator: (v) {
                                if (v == null ||
                                    !RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+$',
                                    ).hasMatch(v.trim())) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // PASSWORD
                            _buildLabel('Password'),

                            TextFormField(
                              controller: _password,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: textColor),
                              decoration: _inputDecoration(
                                hint: 'Create a password',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: mutedColor,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // CONFIRM PASSWORD
                            _buildLabel('Confirm Password'),

                            TextFormField(
                              controller: _confirmPassword,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(color: textColor),
                              decoration: _inputDecoration(
                                hint: 'Confirm your password',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: mutedColor,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please confirm your password';
                                }

                                if (v != _password.text) {
                                  return 'Passwords do not match';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 28),

                            // REGISTER BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed:
                                    _loading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shadowColor:
                                      primaryColor.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 23,
                                        width: 23,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                        
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'STUDENT INFORMATION MOBILE APP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Color(0xFF9ABDB5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
