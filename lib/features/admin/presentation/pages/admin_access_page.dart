import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminAccessPage extends ConsumerStatefulWidget {
  const AdminAccessPage({super.key});

  @override
  ConsumerState<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends ConsumerState<AdminAccessPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedRole;
  final List<String> _roles = ['Vice Chancellor', 'Dean', 'Chairman', 'Coordinator', 'Department Office'];

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Vice Chancellor': return Icons.account_balance;
      case 'Dean': return Icons.school;
      case 'Chairman': return Icons.person;
      case 'Coordinator': return Icons.assignment_ind;
      case 'Department Office': return Icons.desk;
      default: return Icons.person_outline;
    }
  }
  bool _isLoading = false;

  void _createAccount() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      setState(() => _isLoading = true);
      
      try {
        await ref.read(firebaseAuthRepositoryProvider).createStaffAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole!,
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _selectedRole = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff account created successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    } else if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Staff Account",
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Provision accounts for top-level department staff.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    items: _roles.map((e) => DropdownMenuItem(
                      value: e, 
                      child: Row(
                        children: [
                          Icon(_getRoleIcon(e), size: 20, color: Colors.grey.shade700),
                          const SizedBox(width: 12),
                          Text(e),
                        ],
                      )
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedRole = val),
                    decoration: const InputDecoration(
                      labelText: 'Select Role',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                    ),
                    validator: (val) => val == null ? 'Role is required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _nameController,
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    labelText: "Staff Email",
                    hintText: "e.g. chairman@uetmardan.edu.pk",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Required';
                      if (!value.trim().endsWith('@uetmardan.edu.pk')) {
                        return 'Must be a @uetmardan.edu.pk email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    labelText: "Temporary Password",
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: (value) => value == null || value.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: "Create Account",
                    isLoading: _isLoading,
                    onPressed: _createAccount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
