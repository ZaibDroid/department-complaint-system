import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class CreateAdviserForm extends ConsumerStatefulWidget {
  const CreateAdviserForm({super.key});

  @override
  ConsumerState<CreateAdviserForm> createState() => _CreateAdviserFormState();
}

class _CreateAdviserFormState extends ConsumerState<CreateAdviserForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedBatch;
  String? _selectedSection;

  final List<String> _batches = ['Fall 2021', 'Fall 2022', 'Fall 2023', 'Fall 2024'];
  final List<String> _sections = ['A', 'B', 'C'];
  bool _isLoading = false;

  void _createAdviser() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBatch == null || _selectedSection == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Batch and Section')),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      
      try {
        await ref.read(firebaseAuthRepositoryProvider).createStaffAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: 'Batch Adviser',
          batch: _selectedBatch,
          section: _selectedSection,
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _selectedBatch = null;
            _selectedSection = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Batch Adviser account created successfully!')),
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
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create Batch Adviser",
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Assign a new batch adviser to a specific batch and section.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _nameController,
                  labelText: "Adviser Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  labelText: "Adviser Email",
                  hintText: "e.g. batchadviser@uetmardan.edu.pk",
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBatch,
                        items: _batches.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _selectedBatch = val),
                        decoration: const InputDecoration(labelText: 'Batch'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSection,
                        items: _sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _selectedSection = val),
                        decoration: const InputDecoration(labelText: 'Section'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: "Create Adviser Account",
                  isLoading: _isLoading,
                  onPressed: _createAdviser,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
