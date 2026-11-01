import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers/ai_repository_provider.dart';
import '../../domain/entities/ai_result.dart';

class ResumeGeneratorScreen extends ConsumerStatefulWidget {
  const ResumeGeneratorScreen({super.key});

  @override
  ConsumerState<ResumeGeneratorScreen> createState() =>
      _ResumeGeneratorScreenState();
}

class _ResumeGeneratorScreenState extends ConsumerState<ResumeGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roleCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isExportingPdf = false;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _roleCtrl.dispose();
    _experienceCtrl.dispose();
    _contextCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final repo = ref.read(aiRepositoryProvider);
      final result = await repo.generateResumeBullets(
        role: _roleCtrl.text.trim(),
        experience: _experienceCtrl.text.trim(),
        additionalContext: _contextCtrl.text.trim().isEmpty
            ? null
            : _contextCtrl.text.trim(),
      );
      setState(() => _result = result.content);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume bullets generated & saved to history!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportPdf({String? role, String? experience, String? bullets}) async {
    final exportRole = role ?? _roleCtrl.text.trim();
    final exportExp = experience ?? _experienceCtrl.text.trim();
    final exportBullets = bullets ?? _result;

    if (exportBullets == null || exportBullets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bullet points available to export')),
      );
      return;
    }

    setState(() => _isExportingPdf = true);

    try {
      final repo = ref.read(aiRepositoryProvider);
      final Uint8List pdfBytes = await repo.exportResumePdf(
        role: exportRole.isNotEmpty ? exportRole : 'Software Engineer',
        experience: exportExp,
        bullets: exportBullets,
      );

      if (!mounted) return;

      _showPdfDownloadDialog(exportRole, pdfBytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Export failed: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  void _showPdfDownloadDialog(String role, Uint8List pdfBytes) {
    final sanitizedRole = role.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = 'resume_${sanitizedRole.toLowerCase()}.pdf';
    final sizeKb = (pdfBytes.lengthInBytes / 1024).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Resume PDF Ready'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: $filename', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Size: $sizeKb KB • Formatted with ATS guidelines',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.teal, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PDF generated successfully via DevTrack AI intelligence engine.',
                      style: TextStyle(fontSize: 12, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloaded $filename ($sizeKb KB) to documents!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Save / Download'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          ),
        ],
      ),
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ResumeHistoryBottomSheet(
        onSelectHistory: (item) {
          setState(() {
            _roleCtrl.text = item.role;
            if (item.experience != null) _experienceCtrl.text = item.experience!;
            if (item.additionalContext != null) _contextCtrl.text = item.additionalContext!;
            _result = item.generatedBullets;
          });
        },
        onExportPdf: (item) => _exportPdf(
          role: item.role,
          experience: item.experience ?? '',
          bullets: item.generatedBullets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Home',
          onPressed: () => context.go('/home'),
        ),
        title: const Text('AI Resume Bullets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Resume History',
            onPressed: _showHistorySheet,
          ),
          if (_result != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy all',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _result!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard!')),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E1B4B),
                    Color(0xFF312E81),
                    AppColors.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accentLight, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Resume Bullets Studio',
                          style: AppTheme.inter(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Generate ATS-friendly resume bullets & export to professional PDF',
                          style: AppTheme.inter(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Input form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _roleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Role / Position *',
                      hintText: 'e.g. SDE Intern at Google',
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _experienceCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'What you worked on *',
                      hintText:
                          'e.g. Built REST APIs in Spring Boot, integrated payment gateway, wrote unit tests',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.edit_note),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _contextCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Additional Context (optional)',
                      hintText: 'e.g. Team size, tech stack, results achieved',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Icon(Icons.info_outline),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generate,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isLoading ? 'Generating...' : 'Generate Bullets'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(color: Colors.red.shade700)),
                    ),
                  ],
                ),
              ),
            ],

            // Result
            if (_result != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Generated Bullets',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _result!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied!')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: SelectableText(
                  _result!,
                  style: AppTheme.inter(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Regenerate'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isExportingPdf ? null : () => _exportPdf(),
                      icon: _isExportingPdf
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(_isExportingPdf ? 'Exporting...' : 'Export PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Resume History Bottom Sheet ──────────────────────────────────────────────

class _ResumeHistoryBottomSheet extends ConsumerStatefulWidget {
  final ValueChanged<ResumeHistoryItem> onSelectHistory;
  final ValueChanged<ResumeHistoryItem> onExportPdf;

  const _ResumeHistoryBottomSheet({
    required this.onSelectHistory,
    required this.onExportPdf,
  });

  @override
  ConsumerState<_ResumeHistoryBottomSheet> createState() =>
      _ResumeHistoryBottomSheetState();
}

class _ResumeHistoryBottomSheetState
    extends ConsumerState<_ResumeHistoryBottomSheet> {
  bool _isLoading = true;
  List<ResumeHistoryItem> _histories = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(aiRepositoryProvider);
      final items = await repo.getResumeHistory();
      if (mounted) {
        setState(() {
          _histories = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteHistory(int id) async {
    try {
      final repo = ref.read(aiRepositoryProvider);
      await repo.deleteResumeHistory(id);
      setState(() {
        _histories.removeWhere((item) => item.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume deleted from history')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.history, color: Colors.teal, size: 26),
              const SizedBox(width: 8),
              const Text(
                'Resume Generation History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      )
                    : _histories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_toggle_off,
                                    size: 56, color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                Text(
                                  'No saved resumes yet.\nGenerate bullets to build your history!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _histories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (ctx, idx) {
                              final item = _histories[idx];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.role,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: Colors.grey),
                                            onPressed: () =>
                                                _deleteHistory(item.id),
                                          ),
                                        ],
                                      ),
                                      if (item.experience != null &&
                                          item.experience!.isNotEmpty) ...[
                                        Text(
                                          item.experience!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Row(
                                        children: [
                                          Text(
                                            item.createdAt != null
                                                ? item.createdAt!.substring(0, 10)
                                                : '',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton.icon(
                                            onPressed: () {
                                              widget.onSelectHistory(item);
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.edit_note,
                                                size: 16),
                                            label: const Text('Load'),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              widget.onExportPdf(item);
                                            },
                                            icon: const Icon(
                                                Icons.picture_as_pdf,
                                                size: 14),
                                            label: const Text('PDF',
                                                style: TextStyle(fontSize: 11)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade700,
                                              foregroundColor: Colors.white,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
