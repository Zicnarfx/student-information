
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'student_form_page.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  static const Color primaryColor = Color(0xFF237C78);
  static const Color backgroundColor = Color(0xFF102F35);
  static const Color cardColor = Color(0xFF174A50);
  static const Color accentColor = Color(0xFF65B6A5);
  static const Color textColor = Color(0xFFE8F2EF);
  static const Color mutedColor = Color(0xFFC3DCD7);

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Listen for search field focus changes.
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // DELETE STUDENT
  Future<void> _deleteStudent(
    BuildContext context,
    CollectionReference<Map<String, dynamic>> collection,
    String documentId,
    String fullName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: StudentsPage.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Student?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: StudentsPage.textColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete $fullName? '
            'This action cannot be undone.',
            style: const TextStyle(
              color: StudentsPage.mutedColor,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: StudentsPage.mutedColor,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await collection.doc(documentId).delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student deleted successfully!'),
          backgroundColor: StudentsPage.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete student. Please try again.',
          ),
          backgroundColor: StudentsPage.cardColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // RESPONSIVE SEARCH BAR
  Widget _buildSearchBar({
    required double horizontalPadding,
    required double verticalPadding,
    required bool compact,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        horizontalPadding,
        verticalPadding,
        horizontalPadding,
        compact ? 2 : 12,
      ),
      decoration: BoxDecoration(
        color: StudentsPage.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: StudentsPage.accentColor.withOpacity(0.20),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        style: const TextStyle(
          color: StudentsPage.textColor,
          fontSize: 14,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by student number...',
          hintStyle: const TextStyle(
            color: Color(0xFF9ABDB5),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: StudentsPage.accentColor,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: StudentsPage.mutedColor,
                  ),
                )
              : null,
          filled: true,
          fillColor: StudentsPage.cardColor,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: compact ? 3 : 14,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: StudentsPage.accentColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // RESPONSIVE EMPTY STATE
  Widget _buildEmptyState({
    required String title,
    required String message,
    IconData icon = Icons.school_rounded,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isShortScreen = constraints.maxHeight < 300;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(
                  isShortScreen ? 12 : 25,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: isShortScreen ? 65 : 95,
                      width: isShortScreen ? 65 : 95,
                      decoration: BoxDecoration(
                        color: StudentsPage.cardColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: StudentsPage.accentColor
                              .withOpacity(0.20),
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: isShortScreen ? 35 : 48,
                        color: StudentsPage.accentColor,
                      ),
                    ),
                    SizedBox(height: isShortScreen ? 10 : 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isShortScreen ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: StudentsPage.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: StudentsPage.mutedColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // RESPONSIVE STUDENT CARD
  Widget _buildStudentCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    CollectionReference<Map<String, dynamic>> collection,
  ) {
    final data = doc.data();

    final fullName = data['fullName'] ?? 'Unnamed Student';
    final studentNumber = data['studentNumber'] ?? '';
    final course = data['course'] ?? '';
    final yearLevel = data['yearLevel'] ?? '';
    final email = data['email'] ?? '';

    return Card(
      color: StudentsPage.cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: StudentsPage.accentColor.withOpacity(0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF245F5A),
              child: Icon(
                Icons.person_rounded,
                color: StudentsPage.accentColor,
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$fullName',
                    softWrap: true,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: StudentsPage.textColor,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Student No.: $studentNumber',
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 12,
                      color: StudentsPage.mutedColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$course • $yearLevel',
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 12,
                      color: StudentsPage.mutedColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$email',
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 12,
                      color: StudentsPage.mutedColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit Student',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentFormPage(
                          documentId: doc.id,
                          initialData: data,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: StudentsPage.accentColor,
                    size: 21,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete Student',
                  onPressed: () {
                    _deleteStudent(
                      context,
                      collection,
                      doc.id,
                      '$fullName',
                    );
                  },
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.redAccent,
                    size: 21,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // BUILD PAGE
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: StudentsPage.backgroundColor,
        body: Center(
          child: Text(
            'Please log in to view student records.',
            style: TextStyle(
              color: StudentsPage.textColor,
            ),
          ),
        ),
      );
    }

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    final mediaQuery = MediaQuery.of(context);

    final isLandscape =
        mediaQuery.orientation == Orientation.landscape;

    final keyboardIsOpen =
        mediaQuery.viewInsets.bottom > 0;

    // COMPACT LANDSCAPE LAYOUT
    final compactLayout = isLandscape &&
        (keyboardIsOpen || _searchFocusNode.hasFocus);

    return Scaffold(
      backgroundColor: StudentsPage.backgroundColor,
      resizeToAvoidBottomInset: true,

      // Hide AppBar when searching in landscape.
      appBar: compactLayout
          ? null
          : AppBar(
              title: const Text(
                'Student Records',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: StudentsPage.textColor,
                ),
              ),
              backgroundColor: StudentsPage.cardColor,
              foregroundColor: StudentsPage.textColor,
              elevation: 0,
              centerTitle: false,
              iconTheme: const IconThemeData(
                color: StudentsPage.accentColor,
              ),
            ),

      // Hide Add Student button while keyboard is open
      // or search field is focused in landscape.
      floatingActionButton: compactLayout
          ? null
          : FloatingActionButton.extended(
              backgroundColor: StudentsPage.primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentFormPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Student',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth > 700 ? 28.0 : 16.0;

            final verticalPadding =
                compactLayout ? 2.0 : 18.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1000,
                ),
                child: Column(
                  children: [
                    _buildSearchBar(
                      horizontalPadding: horizontalPadding,
                      verticalPadding: verticalPadding,
                      compact: compactLayout,
                    ),

                    Expanded(
                      child: StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: collection
                            .orderBy('fullName')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _buildEmptyState(
                              title: 'Something Went Wrong',
                              message:
                                  'Unable to load student records. '
                                  'Please check your connection and try again.',
                              icon: Icons.error_outline_rounded,
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: StudentsPage.accentColor,
                              ),
                            );
                          }

                          final docs =
                              snapshot.data?.docs ?? [];

                          if (docs.isEmpty) {
                            return _buildEmptyState(
                              title: 'No Student Records Yet',
                              message:
                                  'Start adding student information by '
                                  'tapping the Add Student button below.',
                            );
                          }

                          // FILTER BY STUDENT NUMBER ONLY
                          final filteredDocs = docs.where((doc) {
                            final studentNumber =
                                (doc.data()['studentNumber'] ?? '')
                                    .toString()
                                    .toLowerCase();

                            return studentNumber.contains(
                              _searchQuery,
                            );
                          }).toList();

                          if (filteredDocs.isEmpty) {
                            return _buildEmptyState(
                              title: 'No Matching Students',
                              message:
                                  'No student records found for '
                                  '"${_searchController.text}". '
                                  'Please check the student number '
                                  'and try again.',
                              icon: Icons.search_off_rounded,
                            );
                          }

                          return ListView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior
                                    .onDrag,
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              8,
                              horizontalPadding,
                              compactLayout ? 12 : 100,
                            ),
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              final doc = filteredDocs[index];

                              return _buildStudentCard(
                                context,
                                doc,
                                collection,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
