import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  
  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fullNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cellNoController = TextEditingController();
  final _whatsappNoController = TextEditingController();
  final _streetAddress1Controller = TextEditingController();
  final _streetAddress2Controller = TextEditingController();
  final _townshipController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _sameAsCell = false;
  String? _profileImageBase64;
  File? _selectedImageFile;
  
  User? get _currentUser => widget.user ?? FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _cellNoController.addListener(_onCellNoChanged);
  }

  void _onCellNoChanged() {
    if (_sameAsCell) {
      setState(() {
        _whatsappNoController.text = _cellNoController.text;
      });
    }
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _fullNameController.text = data['fullName'] ?? '';
          _surnameController.text = data['surname'] ?? '';
          _emailController.text = data['email'] ?? _currentUser!.email ?? '';
          _cellNoController.text = data['cellNo'] ?? '';
          _whatsappNoController.text = data['whatsappNo'] ?? '';
          _sameAsCell = data['sameAsCell'] ?? false;
          _streetAddress1Controller.text = data['streetAddress1'] ?? '';
          _streetAddress2Controller.text = data['streetAddress2'] ?? '';
          _townshipController.text = data['township'] ?? '';
          _postalCodeController.text = data['postalCode'] ?? '';
          _profileImageBase64 = data['profileImage'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _fullNameController.text = _currentUser!.displayName ?? '';
          _emailController.text = _currentUser!.email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading profile data', isError: true);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _selectedImageFile = imageFile;
          _profileImageBase64 = base64Image;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: ${e.toString()}', isError: true);
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    final fullName = _fullNameController.text.trim();
    final surname = _surnameController.text.trim();
    final cellNo = _cellNoController.text.trim();
    
    if (fullName.isEmpty) {
      _showSnackBar('Full name cannot be empty', isError: true);
      return;
    }
    
    if (surname.isEmpty) {
      _showSnackBar('Surname cannot be empty', isError: true);
      return;
    }
    
    if (cellNo.isEmpty) {
      _showSnackBar('Cell number cannot be empty', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final whatsappNo = _sameAsCell ? cellNo : _whatsappNoController.text.trim();
      
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
        'fullName': fullName,
        'surname': surname,
        'email': _emailController.text,
        'cellNo': cellNo,
        'whatsappNo': whatsappNo,
        'sameAsCell': _sameAsCell,
        'streetAddress1': _streetAddress1Controller.text.trim(),
        'streetAddress2': _streetAddress2Controller.text.trim(),
        'township': _townshipController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'profileImage': _profileImageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update display name in Firebase Auth
      await _currentUser!.updateDisplayName('$fullName $surname');

      _showSnackBar('Profile updated successfully!');
      
    } catch (e) {
      _showSnackBar('Error updating profile: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _showSnackBar('Error logging out', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Color(0xFFEF4444) : Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled && !readOnly ? Colors.white : Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled && !readOnly ? Colors.transparent : Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: enabled && !readOnly
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 16,
          color: enabled && !readOnly ? Color(0xFF0F172A) : Color(0xFF64748B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF64748B)),
          prefixIcon: Icon(
            icon,
            color: enabled && !readOnly ? Color(0xFF6366F1) : Color(0xFF64748B),
          ),
          suffixIcon: readOnly
              ? Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF64748B),
                  size: 18,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color(0xFF6366F1),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: enabled && !readOnly ? Colors.white : Color(0xFFF1F5F9),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _cellNoController.dispose();
    _whatsappNoController.dispose();
    _streetAddress1Controller.dispose();
    _streetAddress2Controller.dispose();
    _townshipController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    
                    // Profile Image
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Color(0xFF14B8A6),
                            backgroundImage: _profileImageBase64 != null
                                ? MemoryImage(base64Decode(_profileImageBase64!))
                                : null,
                            child: _profileImageBase64 == null
                                ? Text(
                                    _fullNameController.text.isNotEmpty
                                        ? _fullNameController.text[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF14B8A6).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // User Name
                    Text(
                      _fullNameController.text.isNotEmpty && _surnameController.text.isNotEmpty
                          ? '${_fullNameController.text} ${_surnameController.text}'
                          : _fullNameController.text.isNotEmpty
                              ? _fullNameController.text
                              : 'User',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    // User Email
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _emailController.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
              
              // Form Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Edit Profile Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Personal Information Section
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Full Name Field
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'First Name',
                      icon: Icons.person_rounded,
                      enabled: !_isSaving,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Surname Field
                    _buildTextField(
                      controller: _surnameController,
                      label: 'Surname',
                      icon: Icons.person_outline_rounded,
                      enabled: !_isSaving,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Email Field (Read-only)
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_rounded,
                      enabled: false,
                      readOnly: true,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Contact Information Section
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Cell Number Field
                    _buildTextField(
                      controller: _cellNoController,
                      label: 'Cell Number',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      enabled: !_isSaving,
                    ),
                    
                    SizedBox(height: 12),
                    
                    // WhatsApp Checkbox
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'Use same number for WhatsApp',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        value: _sameAsCell,
                        activeColor: Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onChanged: _isSaving
                            ? null
                            : (value) {
                                setState(() {
                                  _sameAsCell = value ?? false;
                                  if (_sameAsCell) {
                                    _whatsappNoController.text = _cellNoController.text;
                                  }
                                });
                              },
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // WhatsApp Number Field
                    if (!_sameAsCell)
                      _buildTextField(
                        controller: _whatsappNoController,
                        label: 'WhatsApp Number',
                        icon: Icons.chat_rounded,
                        keyboardType: TextInputType.phone,
                        enabled: !_isSaving,
                      ),
                    
                    if (!_sameAsCell) SizedBox(height: 24),
                    
                    // Address Information Section
                    if (!_sameAsCell) SizedBox(height: 8),
                    Text(
                      'Address Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Street Address 1
                    _buildTextField(
                      controller: _streetAddress1Controller,
                      label: 'Street Address 1',
                      icon: Icons.home_rounded,
                      enabled: !_isSaving,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Street Address 2
                    _buildTextField(
                      controller: _streetAddress2Controller,
                      label: 'Street Address 2 (Optional)',
                      icon: Icons.home_outlined,
                      enabled: !_isSaving,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Township
                    _buildTextField(
                      controller: _townshipController,
                      label: 'Township',
                      icon: Icons.location_city_rounded,
                      enabled: !_isSaving,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Postal Code
                    _buildTextField(
                      controller: _postalCodeController,
                      label: 'Postal Code',
                      icon: Icons.markunread_mailbox_rounded,
                      keyboardType: TextInputType.number,
                      enabled: !_isSaving,
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Save Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSaving ? null : _saveProfile,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: _isSaving
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Logout Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFFEF4444),
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _logout,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF4444),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}