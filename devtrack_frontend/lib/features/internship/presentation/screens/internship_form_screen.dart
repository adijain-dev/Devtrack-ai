import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/internship.dart';
import '../notifiers/internship_notifier.dart';

/// Used for both Add and Edit.
/// Pass [internship] via GoRouter extra for edit mode; null = add mode.
class InternshipFormScreen extends ConsumerStatefulWidget {
  final Internship? internship; // null → add, non-null → edit

  const InternshipFormScreen({super.key, this.internship});

  @override
  ConsumerState<InternshipFormScreen> createState() =>
      _InternshipFormScreenState();
}

class _InternshipFormScreenState extends ConsumerState<InternshipFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _company;
  late final TextEditingController _role;
  late final TextEditingController _location;
  late final TextEditingController _salary;
  late final TextEditingController _jobLink;
  late final TextEditingController _notes;
  late InternshipStatus _status;
  String? _appliedDate;

  bool _isEditing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.internship;
    _isEditing = i != null;
    _company = TextEditingController(text: i?.companyName ?? '');
    _role = TextEditingController(text: i?.role ?? '');
    _location = TextEditingController(text: i?.location ?? '');
    _salary = TextEditingController(text: i?.salary ?? '');
    _jobLink = TextEditingController(text: i?.jobLink ?? '');
    _notes = TextEditingController(text: i?.notes ?? '');
    _status = i?.status ?? InternshipStatus.applied;
    _appliedDate = i?.appliedDate;
  }

  @override
  void dispose() {
    _company.dispose();
    _role.dispose();
    _location.dispose();
    _salary.dispose();
    _jobLink.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _appliedDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notifier = ref.read(internshipNotifierProvider.notifier);
    final internship = Internship(
      id: widget.internship?.id ?? '',
      companyName: _company.text.trim(),
      role: _role.text.trim(),
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      salary: _salary.text.trim().isEmpty ? null : _salary.text.trim(),
      jobLink: _jobLink.text.trim().isEmpty ? null : _jobLink.text.trim(),
      status: _status,
      appliedDate: _appliedDate,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );

    bool success;
    if (_isEditing) {
      success = await notifier.update(internship);
    } else {
      success = await notifier.create(internship);
    }

    setState(() => _saving = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Updated!' : 'Internship added!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Internship' : 'Add Internship'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(_company, 'Company Name *', Icons.business,
                  required: true),
              const SizedBox(height: 14),
              _buildField(_role, 'Role / Position *', Icons.work,
                  required: true),
              const SizedBox(height: 14),
              _buildField(_location, 'Location', Icons.location_on),
              const SizedBox(height: 14),
              _buildField(_salary, 'Salary / Stipend', Icons.attach_money),
              const SizedBox(height: 14),
              _buildField(_jobLink, 'Job Link (URL)', Icons.link,
                  keyboardType: TextInputType.url),
              const SizedBox(height: 14),

              // Status dropdown
              DropdownButtonFormField<InternshipStatus>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Application Status',
                  prefixIcon: const Icon(Icons.track_changes),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: InternshipStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 14),

              // Date picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Applied Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    _appliedDate ?? 'Tap to select',
                    style: TextStyle(
                        color: _appliedDate == null
                            ? Colors.grey
                            : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notes,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notes / Recruiter Info',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update Internship' : 'Save Internship',
                        style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
          : null,
    );
  }
}
