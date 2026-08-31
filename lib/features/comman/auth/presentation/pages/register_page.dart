import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  int _selectedRoleIndex = 0; // 0: Farmer, 1: Buyer, 2: Officer

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  String? _selectedDistrict;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _register() async {
    final name = _nameController.text.trim();
    final emailOrPhone = _emailController.text.trim().replaceAll(' ', '');
    final district = _selectedDistrict ?? '';
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final nic = _nicController.text.trim();
    final department = _departmentController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (emailOrPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or phone number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final isEmail = emailOrPhone.contains('@');
    if (isEmail) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailOrPhone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    } else {
      final phoneRegex = RegExp(r'^0\d{9}$');
      if (!phoneRegex.hasMatch(emailOrPhone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number must be exactly 10 digits (e.g. 0771234567)'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    if (_selectedRoleIndex == 0) {
      if (nic.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farmers must provide their National Identity Card (NIC) number'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      final nicRegex = RegExp(r'^(\d{12}|\d{9}[vVxX])$');
      if (!nicRegex.hasMatch(nic)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid NIC number (12 digits or 9 digits with V/X)'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    if (_selectedRoleIndex == 2 && department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Officers must provide their Department name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (district.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your district'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String role = 'farmer';
    if (_selectedRoleIndex == 1) role = 'buyer';
    if (_selectedRoleIndex == 2) role = 'officer';

    setState(() {
      _isLoading = true;
    });

    String finalEmail = emailOrPhone;
    if (!emailOrPhone.contains('@')) {
      finalEmail = '$emailOrPhone@agrimart.com';
    }

    try {
      final Map<String, dynamic> userData = {
        'name': name,
        'email': finalEmail,
        'role': role,
        'district': district,
        'status': role == 'farmer' ? 'pending' : 'approved',
        'contact': emailOrPhone,
        'phone': !emailOrPhone.contains('@') ? emailOrPhone : null,
        'nic': role == 'farmer' ? nic : null,
        'department': role == 'officer' ? department : null,
        'savedProducts': <String>[],
      };

      await ref
          .read(authControllerProvider.notifier)
          .register(finalEmail, password, userData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            role == 'farmer'
                ? 'Registration successful! Verification is pending.'
                : 'Account created successfully!',
          ),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRouter.home,
        arguments: role,
      );
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Registration failed. Please try again.';
        final errorStr = e.toString().toLowerCase();

        if (errorStr.contains('email-already-in-use')) {
          errorMessage = 'An account with this email/phone already exists. Please log in.';
        } else if (errorStr.contains('invalid-email')) {
          errorMessage = 'Please enter a valid email address or phone number.';
        } else if (errorStr.contains('weak-password')) {
          errorMessage = 'The password provided is too weak (minimum 6 characters).';
        } else if (errorStr.contains('network-request-failed')) {
          errorMessage = 'Network connection error. Please check your internet.';
        } else if (e is FirebaseAuthException && e.message != null) {
          errorMessage = e.message!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select your role to get started',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Role selection cards
              _buildRoleCard(
                index: 0,
                title: 'Farmer',
                subtitle: 'List and sell your produce',
                emoji: '🧑‍🌾',
                iconBgColor: const Color(0xFFC5E1A5),
              ),
              const SizedBox(height: 12),
              _buildRoleCard(
                index: 1,
                title: 'Buyer',
                subtitle: 'Browse and order fresh produce',
                emoji: '🛒',
                iconBgColor: const Color(0xFFE3F2FD),
              ),
              const SizedBox(height: 12),
              _buildRoleCard(
                index: 2,
                title: 'Agricultural Officer',
                subtitle: 'Manage and monitor the platform',
                emoji: '👨‍💼',
                iconBgColor: const Color(0xFFFFF9C4),
              ),

              const SizedBox(height: 24),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1),
              const SizedBox(height: 24),

              // Form Fields
              _buildInputField(
                'Full Name',
                'Your full name',
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                'Email / Phone Number',
                'e.g. name@example.com or 0771234567',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              if (_selectedRoleIndex == 0) ...[
                _buildInputField(
                  'NIC (National Identity Card)',
                  'e.g. 199512345678 or 951234567V',
                  controller: _nicController,
                ),
                const SizedBox(height: 16),
              ],
              if (_selectedRoleIndex == 2) ...[
                _buildInputField(
                  'Department',
                  'e.g. Department of Agriculture',
                  controller: _departmentController,
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'District',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedDistrict,
                hint: Text(
                  'Select your district',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                isExpanded: true,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade50,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                  ),
                ),
                items: _districts.map((district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                'Password',
                'Create a password (min. 6 characters)',
                obscureText: _obscurePassword,
                controller: _passwordController,
                autocorrect: false,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                'Confirm Password',
                'Repeat password',
                obscureText: _obscureConfirmPassword,
                controller: _confirmPasswordController,
                autocorrect: false,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.login);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF387015),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required int index,
    required String title,
    required String subtitle,
    required String emoji,
    required Color iconBgColor,
  }) {
    bool isSelected = _selectedRoleIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoleIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDF5E1) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A8921) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A8921),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    bool obscureText = false,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            autocorrect: autocorrect,
            textCapitalization: textCapitalization,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
