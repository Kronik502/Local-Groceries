import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final User? user;

  const CustomAppBar({super.key, this.user});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? fullName;
  String? base64Image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFirestoreUserData();
  }

  @override
  void didUpdateWidget(covariant CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.uid != widget.user?.uid) {
      _loadFirestoreUserData();
    }
  }

  Future<void> _loadFirestoreUserData() async {
    if (widget.user == null) {
      if (!mounted) return;
      setState(() {
        fullName = null;
        base64Image = null;
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          fullName = data['fullName'] ?? widget.user!.displayName ?? 'User';
          base64Image = data['profileImage'];
          _isLoading = false;
        });
      } else {
        setState(() {
          fullName = widget.user!.displayName ?? 'User';
          base64Image = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        fullName = widget.user!.displayName ?? 'User';
        base64Image = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isLoading
            ? Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.waving_hand_rounded,
                          size: 18,
                          color: Colors.amber[300],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hi, ${fullName ?? 'User'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        actions: [
          // Profile button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              tooltip: widget.user != null ? 'View Profile' : 'Login',
              icon: widget.user != null
                  ? (base64Image != null
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: MemoryImage(base64Decode(base64Image!)),
                            backgroundColor: Colors.transparent,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF14B8A6),
                                Color(0xFF06B6D4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              (fullName != null && fullName!.isNotEmpty)
                                  ? fullName![0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ))
                  : const Icon(
                      Icons.account_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
              onPressed: () {
                // Optional: Handle profile tap
              },
            ),
          ),

          // Logout button
          if (widget.user != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                tooltip: 'Logout',
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Logged out successfully'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),
        ],
      ),
    );
  }
}
