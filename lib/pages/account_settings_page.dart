
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // DARK BLUE-GREEN THEME
  static const Color primaryColor = Color(0xFF237C78);
  static const Color backgroundColor = Color(0xFF102F35);
  static const Color cardColor = Color(0xFF174A50);
  static const Color accentColor = Color(0xFF65B6A5);
  static const Color textColor = Color(0xFFE8F2EF);
  static const Color mutedColor = Color(0xFFC3DCD7);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPassword =
      TextEditingController();

  final TextEditingController _newPassword =
      TextEditingController();

  bool _loading = false;
  bool _loggingOut = false;

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;

  // SHOW/HIDE PASSWORD FORM
  bool _showPasswordForm = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  // CLOSE AND CLEAR PASSWORD FORM
  void _closePasswordForm() {
    setState(() {
      _showPasswordForm = false;
      _currentPassword.clear();
      _newPassword.clear();
      _hideCurrentPassword = true;
      _hideNewPassword = true;
      _formKey.currentState?.reset();
    });
  }

  // SUCCESS POPUP
  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 85,
                  width: 85,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: accentColor,
                    size: 60,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Password Updated!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Your account password has been changed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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

  // CHANGE PASSWORD
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showMessage('No authenticated user found.');
      return;
    }

    if (_currentPassword.text == _newPassword.text) {
      _showMessage(
        'New password must be different from current password.',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassword.text,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(_newPassword.text.trim());

      _currentPassword.clear();
      _newPassword.clear();

      if (!mounted) return;

      setState(() {
        _loading = false;
        _showPasswordForm = false;
        _hideCurrentPassword = true;
        _hideNewPassword = true;
      });

      await _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Your current password is incorrect.';
          break;
        case 'weak-password':
          message = 'Your new password is too weak.';
          break;
        case 'requires-recent-login':
          message =
              'Please log in again before changing your password.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        default:
          message = e.message ?? 'Password update failed.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    }
  }

  // LOGOUT
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(color: mutedColor),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: mutedColor),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _loggingOut = true);

    try {
      await FirebaseAuth.instance.signOut();

      // main.dart automatically displays LoginPage.
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to log out. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _loggingOut = false);
      }
    }
  }

  // MESSAGE
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: textColor),
          ),
          backgroundColor: cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: accentColor.withOpacity(0.35),
            ),
          ),
        ),
      );
  }

  // PASSWORD FIELD
  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: mutedColor),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: accentColor,
        ),
        suffixIcon: IconButton(
          onPressed: onVisibilityToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: mutedColor,
          ),
        ),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: accentColor.withOpacity(0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: accentColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: accentColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: accentColor,
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(
          color: accentColor,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required.';
        }

        if (label == 'New Password' &&
            value.trim().length < 6) {
          return 'Password must have at least 6 characters.';
        }

        return null;
      },
    );
  }

  // MY ACCOUNT PROFILE
  Widget _buildMyAccount(User user) {
    return FutureBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final firestoreName =
            data?['fullName']?.toString().trim();

        final displayName =
            firestoreName != null && firestoreName.isNotEmpty
                ? firestoreName
                : (user.displayName?.isNotEmpty == true
                    ? user.displayName!
                    : 'User');

        final email = user.email ?? 'Unknown';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF237C78),
                Color(0xFF174A50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accentColor.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 43,
                  backgroundColor: Color(0xFFE8F2EF),
                  child: Icon(
                    Icons.person_rounded,
                    size: 55,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (snapshot.connectionState ==
                      ConnectionState.waiting &&
                  !snapshot.hasData)
                const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 7),

              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFC3DCD7),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Student Information Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // SECTION TITLE
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  // CHANGE PASSWORD SECTION
  Widget _buildChangePasswordSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // CLICKABLE CHANGE PASSWORD HEADER
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                if (_showPasswordForm) {
                  if (!_loading) {
                    _closePasswordForm();
                  }
                } else {
                  _showPasswordForm = true;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: accentColor,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Update your account password.',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    _showPasswordForm
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: accentColor,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),

          // EXPANDABLE PASSWORD FORM
          if (_showPasswordForm) ...[
            Divider(
              color: accentColor.withOpacity(0.20),
              height: 1,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your password details below.',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _passwordField(
                      controller: _currentPassword,
                      label: 'Current Password',
                      obscureText: _hideCurrentPassword,
                      onVisibilityToggle: () {
                        setState(() {
                          _hideCurrentPassword =
                              !_hideCurrentPassword;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    _passwordField(
                      controller: _newPassword,
                      label: 'New Password',
                      obscureText: _hideNewPassword,
                      onVisibilityToggle: () {
                        setState(() {
                          _hideNewPassword =
                              !_hideNewPassword;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: mutedColor,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Use at least 6 characters for your new password.',
                            style: TextStyle(
                              fontSize: 11,
                              color: mutedColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _loading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded),
                                  SizedBox(width: 9),
                                  Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : _closePasswordForm,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: mutedColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // BUILD PAGE
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape =
                MediaQuery.of(context).orientation ==
                    Orientation.landscape;

            final horizontalPadding =
                isLandscape ? 32.0 : 20.0;

            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 850,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

                      // MY ACCOUNT
                      if (user != null)
                        _buildMyAccount(user)
                      else
                        const Text(
                          'No account information available.',
                          style: TextStyle(color: textColor),
                        ),

                      const SizedBox(height: 28),

                      // SECURITY
                      _sectionTitle('Security'),
                      const SizedBox(height: 14),

                      _buildChangePasswordSection(),

                      const SizedBox(height: 28),

                      // LOGOUT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed:
                              _loggingOut ? null : _logout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentColor,
                            side: const BorderSide(
                              color: accentColor,
                            ),
                            backgroundColor: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          icon: _loggingOut
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accentColor,
                                  ),
                                )
                              : const Icon(
                                  Icons.logout_rounded,
                                ),
                          label: Text(
                            _loggingOut
                                ? 'Logging out...'
                                : 'Logout',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Center(
                        child: Text(
                          'STUDENT INFORMATION MOBILE APP',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: mutedColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
