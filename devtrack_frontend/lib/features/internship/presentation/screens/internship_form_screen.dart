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
  late final TextEditingController _resumeFileName;
  late final TextEditingController _resumeUrl;
  late final TextEditingController _notes;
  late InternshipStatus _status;
  String? _appliedDate;
  String? _interviewDate;
  bool _reminderEnabled = false;

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
    _resumeFileName = TextEditingController(text: i?.resumeFileName ?? '');
    _resumeUrl = TextEditingController(text: i?.resumeUrl ?? '');
    _notes = TextEditingController(text: i?.notes ?? '');
    _status = i?.status ?? InternshipStatus.applied;
    _appliedDate = i?.appliedDate;
    _interviewDate = i?.interviewDate;
    _reminderEnabled = i?.reminderEnabled ?? (i?.interviewDate != null);
  }

  @override
  void dispose() {
    _company.dispose();
    _role.dispose();
    _location.dispose();
    _salary.dispose();
    _jobLink.dispose();
    _resumeFileName.dispose();
    _resumeUrl.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickAppliedDate() async {
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

  Future<void> _pickInterviewDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select Interview Date',
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Interview Time',
    );
    if (pickedTime == null || !mounted) return;

    final dt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _interviewDate =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}T${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
      _reminderEnabled = true;
      if (_status == InternshipStatus.applied) {
        _status = InternshipStatus.interview;
      }
    });
  }

  void _clearInterviewDate() {
    setState(() {
      _interviewDate = null;
      _reminderEnabled = false;
    });
  }

  String _formatInterviewDisplay(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} at $hour:$min $period';
    } catch (_) {
      return isoString.replaceFirst('T', ' ');
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
      interviewDate: _interviewDate,
      reminderEnabled: _reminderEnabled,
      resumeFileName: _resumeFileName.text.trim().isEmpty ? null : _resumeFileName.text.trim(),
      resumeUrl: _resumeUrl.text.trim().isEmpty ? null : _resumeUrl.text.trim(),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/internships');
            }
          },
        ),
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
                onChanged: (v) {
                  setState(() {
                    _status = v!;
                    if (_status == InternshipStatus.interview && _interviewDate == null) {
                      _pickInterviewDateTime();
                    }
                  });
                },
              ),
              const SizedBox(height: 14),

              // Applied Date picker
              InkWell(
                onTap: _pickAppliedDate,
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
                            : Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Interview & Calendar Schedule Section ──────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_available, color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        const Text(
                          'Interview Schedule & Alarms',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const Spacer(),
                        if (_interviewDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                            tooltip: 'Clear schedule',
                            onPressed: _clearInterviewDate,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickInterviewDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alarm, color: Colors.orange, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _interviewDate != null
                                    ? _formatInterviewDisplay(_interviewDate!)
                                    : 'Tap to schedule interview date & time',
                                style: TextStyle(
                                  fontWeight: _interviewDate != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _interviewDate != null
                                      ? Colors.orange.shade800
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    if (_interviewDate != null) ...[
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Reminder Alarm Enabled',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text(
                            'Generates in-app notifications & alarms before interview',
                            style: TextStyle(fontSize: 11)),
                        value: _reminderEnabled,
                        activeThumbColor: Colors.deepOrange,
                        onChanged: (val) => setState(() => _reminderEnabled = val),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Document & Resume Attachment Section ───────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.attach_file, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Resume / Document Attachment',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      _resumeFileName,
                      'Resume File Name (e.g. SDE_Resume_v2.pdf)',
                      Icons.description_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildField(
                      _resumeUrl,
                      'Resume Link / Drive URL',
                      Icons.cloud_upload_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Default Resume'),
                          onPressed: () {
                            setState(() {
                              _resumeFileName.text = 'DevTrack_Default_Resume.pdf';
                            });
                          },
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.link, size: 16),
                          label: const Text('Google Drive'),
                          onPressed: () {
                            if (_resumeUrl.text.isEmpty) {
                              setState(() {
                                _resumeUrl.text = 'https://drive.google.com/file/d/';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
