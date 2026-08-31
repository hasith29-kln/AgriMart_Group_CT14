import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agri_mart/core/providers/auth_provider.dart';
import 'package:agri_mart/core/providers/user_provider.dart';
import 'package:agri_mart/core/models/user_model.dart';

class BuyerEditProfilePage extends ConsumerStatefulWidget {
  const BuyerEditProfilePage({super.key});

  @override
  ConsumerState<BuyerEditProfilePage> createState() => _BuyerEditProfilePageState();
}

class _BuyerEditProfilePageState extends ConsumerState<BuyerEditProfilePage> {
  final Color primaryBlue = const Color(0xFF1976D2);
  final Color backgroundGrey = const Color(0xFFF9F9F9);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUser = ref.read(currentUserProvider).value;
      if (_currentUser != null) {
        _nameController.text = _currentUser!.name;
        _emailController.text = _currentUser!.email;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_currentUser == null) return;
    
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> updates = {
        'name': name,
        'email': email,
      };
      
      await ref.read(userControllerProvider.notifier).updateUserProfile(_currentUser!.id, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.person, size: 54, color: Colors.grey.shade500),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildLabel('Full Name *'),
                  _buildTextField(controller: _nameController, hintText: 'e.g. John Doe', prefixIcon: '👤'),
                  const SizedBox(height: 16),
                  _buildLabel('Email Address'),
                  _buildTextField(
                    controller: _emailController, 
                    hintText: 'e.g. john@example.com', 
                    prefixIcon: '✉️',
                    readOnly: true, // Usually email requires re-auth to change
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email address cannot be changed directly.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: TextStyle(color: readOnly ? Colors.grey.shade600 : Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(prefixIcon, style: const TextStyle(fontSize: 18)),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
