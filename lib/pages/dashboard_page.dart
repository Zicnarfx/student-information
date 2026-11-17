
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'account_settings_page.dart';
import 'student_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color backgroundColor = Color(0xFF102F35);
  static const Color cardColor = Color(0xFF174A50);
  static const Color accentColor = Color(0xFF65B6A5);

  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const DashboardHomePage(),
    const StudentsPage(),
    const AccountSettingsPage(),
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.settings_rounded,
  ];

  final List<String> _labels = [
    'Dashboard',
    'Students',
    'Settings',
  ];

  Widget _buildNavigationItem(int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 42,
                width: 50,
                transform: Matrix4.translationValues(
                  0,
                  isSelected ? -4 : 0,
                  0,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF65B6A5),
                            Color(0xFF237C78),
                            Color(0xFF174A50),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  _icons[index],
                  size: isSelected ? 28 : 25,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF9ABDB5),
                ),
              ),

              const SizedBox(height: 3),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? accentColor
                      : const Color(0xFF9ABDB5),
                ),
                child: Text(_labels[index]),
              ),

              const SizedBox(height: 3),

              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 3,
                width: isSelected ? 18 : 0,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CHECK IF THE KEYBOARD IS OPEN
    final keyboardIsOpen =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: backgroundColor,

      // Allow the body to resize when the keyboard appears.
      resizeToAvoidBottomInset: true,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // HIDE BOTTOM NAVIGATION WHEN KEYBOARD IS OPEN
      bottomNavigationBar: keyboardIsOpen
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 18,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 78,
                  child: Row(
                    children: List.generate(
                      _icons.length,
                      (index) => _buildNavigationItem(index),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ==========================================
// DASHBOARD HOME PAGE
// ==========================================

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  static const Color backgroundColor = Color(0xFF102F35);
  static const Color cardColor = Color(0xFF174A50);
  static const Color primaryColor = Color(0xFF237C78);
  static const Color accentColor = Color(0xFF65B6A5);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    final students = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    final displayName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : (user.email?.split('@').first ?? 'User');

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: accentColor,
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
                horizontal: isLandscape ? 28 : 20,
                vertical: isLandscape ? 14 : 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 950),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // WELCOME CARD
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(
                          isLandscape ? 20 : 24,
                        ),
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
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 65,
                              width: 65,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '$displayName!',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Manage your student information easily.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // OVERVIEW
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // LIVE STUDENT COUNT
                      StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: students.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _buildStudentCountCard(
                              'Error',
                              Icons.error_outline_rounded,
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Card(
                              color: cardColor,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: LinearProgressIndicator(
                                  color: accentColor,
                                  backgroundColor: backgroundColor,
                                ),
                              ),
                            );
                          }

                          return _buildStudentCountCard(
                            snapshot.data!.docs.length.toString(),
                            Icons.people_alt_rounded,
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      // INFORMATION
                      const Text(
                        'Information',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: accentColor.withOpacity(0.18),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              color: accentColor,
                              size: 32,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stay Organized!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Keep your student records organized '
                                    'and updated in one place.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFC3DCD7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // FOOTER
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              'STUDENT INFORMATION MOBILE APP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9ABDB5),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Manage. Organize. Achieve.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9ABDB5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
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

  // STUDENT COUNT CARD
  Widget _buildStudentCountCard(String count, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Students',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC3DCD7),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Registered Students',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9ABDB5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
