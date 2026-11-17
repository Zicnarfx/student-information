
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;

  const StudentFormPage({
    super.key,
    this.documentId,
    this.initialData,
  });

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  // DARK BLUE-GREEN THEME
  static const Color primaryColor = Color(0xFF237C78);
  static const Color backgroundColor = Color(0xFF102F35);
  static const Color cardColor = Color(0xFF174A50);
  static const Color accentColor = Color(0xFF65B6A5);
  static const Color textColor = Color(0xFFE8F2EF);
  static const Color mutedColor = Color(0xFFC3DCD7);

  final _key = GlobalKey<FormState>();

  late final TextEditingController _number;
  late final TextEditingController _name;
  late final TextEditingController _course;
  late final TextEditingController _year;
  late final TextEditingController _email;

  bool _saving = false;

  bool get isEditing => widget.documentId != null;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData ?? {};

    _number = TextEditingController(
      text: data['studentNumber']?.toString() ?? '',
    );

    _name = TextEditingController(
      text: data['fullName']?.toString() ?? '',
    );

    _course = TextEditingController(
      text: data['course']?.toString() ?? '',
    );

    _year = TextEditingController(
      text: data['yearLevel']?.toString() ?? '',
    );

    _email = TextEditingController(
      text: data['email']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _course.dispose();
    _year.dispose();
    _email.dispose();
    super.dispose();
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

                Text(
                  isEditing
                      ? 'Student Updated!'
                      : 'Student Added!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  isEditing
                      ? 'Student information has been updated successfully.'
                      : 'New student information has been saved successfully.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

    if (!mounted) return;

    // RETURN TO STUDENT RECORDS
    Navigator.pop(context);
  }

  // SAVE STUDENT
  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please log in again.');
      }

      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('students');

      final data = <String, dynamic>{
        'studentNumber': _number.text.trim(),
        'fullName': _name.text.trim(),
        'course': _course.text.trim(),
        'yearLevel': _year.text.trim(),
        'email': _email.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isEditing) {
        await collection.doc(widget.documentId).update(data);
      } else {
        await collection.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      setState(() => _saving = false);

      // SHOW SUCCESS POPUP
      await _showSuccessDialog();

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      setState(() => _saving = false);
    }
  }

  // FORM FIELD
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool email = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: email
            ? TextCapitalization.none
            : TextCapitalization.words,
        style: const TextStyle(
          color: textColor,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: mutedColor),
          prefixIcon: Icon(
            icon,
            color: accentColor,
          ),
          filled: true,
          fillColor: backgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.5,
            ),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required.';
          }

          if (email &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(value.trim())) {
            return 'Please enter a valid email address.';
          }

          return null;
        },
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

      appBar: AppBar(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Student' : 'Add Student',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: accentColor),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 32 : 20,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 850,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Container(
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
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                isEditing
                                    ? Icons.edit_note_rounded
                                    : Icons.person_add_alt_1_rounded,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEditing
                                        ? 'Update Student'
                                        : 'New Student',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    isEditing
                                        ? 'Update the student information below.'
                                        : 'Fill in the details to register a new student.',
                                    style: const TextStyle(
                                      color: Color(0xFFC3DCD7),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // FORM HEADING
                      const Text(
                        'Student Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Please provide the required student details.',
                        style: TextStyle(
                          fontSize: 13,
                          color: mutedColor,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // FORM CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildField(
                                controller: _number,
                                label: 'Student Number',
                                icon: Icons.badge_outlined,
                              ),

                              _buildField(
                                controller: _name,
                                label: 'Full Name',
                                icon: Icons.person_outline_rounded,
                              ),

                              _buildField(
                                controller: _course,
                                label: 'Course',
                                icon: Icons.menu_book_rounded,
                              ),

                              _buildField(
                                controller: _year,
                                label: 'Year Level',
                                icon: Icons.school_outlined,
                                keyboardType: TextInputType.number,
                              ),

                              _buildField(
                                controller: _email,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                email: true,
                              ),

                              const SizedBox(height: 8),

                              // SAVE BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _saving ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        primaryColor.withOpacity(0.6),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _saving
                                      ? const SizedBox(
                                          height: 23,
                                          width: 23,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isEditing
                                                  ? Icons.save_rounded
                                                  : Icons.person_add_alt_1_rounded,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              isEditing
                                                  ? 'Update Student'
                                                  : 'Save Student',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // FOOTER
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.school_rounded,
                              color: accentColor,
                              size: 28,
                            ),
                            SizedBox(height: 7),
                            Text(
                              'STUDENT INFORMATION SYSTEM',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: mutedColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage. Organize. Achieve.',
                              style: TextStyle(
                                fontSize: 11,
                                color: mutedColor,
                              ),
                            ),
                          ],
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
