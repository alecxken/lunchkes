// lib/widgets/visitor_form.dart
import 'package:flutter/material.dart';

class VisitorForm extends StatefulWidget {
  final Function(String host, String name, String company) onSubmit;

  const VisitorForm({super.key, required this.onSubmit});

  @override
  State<VisitorForm> createState() => _VisitorFormState();
}

class _VisitorFormState extends State<VisitorForm> {
  final _hostController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_hostController.text.isEmpty || _nameController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    await widget.onSubmit(
      _hostController.text.trim(),
      _nameController.text.trim(),
      _companyController.text.trim(),
    );
    _hostController.clear();
    _nameController.clear();
    _companyController.clear();
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_add, color: Color(0xFF0082BB)),
              SizedBox(width: 8),
              Text(
                'Visitor Registration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF005B82),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hostController,
            decoration: InputDecoration(
              labelText: 'Staff Being Visited',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Visitor Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _companyController,
            decoration: InputDecoration(
              labelText: 'Company',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add),
              label: const Text('Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBED600),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }
}
