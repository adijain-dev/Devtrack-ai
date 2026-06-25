import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dsa_topic.dart';
import '../../data/models/dsa_topic_model.dart';
import '../notifiers/dsa_notifier.dart';

class DsaFormScreen extends ConsumerStatefulWidget {
  final DsaTopic? topic; // null = add mode

  const DsaFormScreen({super.key, this.topic});

  @override
  ConsumerState<DsaFormScreen> createState() => _DsaFormScreenState();
}

class _DsaFormScreenState extends ConsumerState<DsaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _topicName;
  late final TextEditingController _notes;
  late DsaCategory _category;
  late DsaDifficulty _difficulty;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.topic;
    _topicName = TextEditingController(text: t?.topicName ?? '');
    _notes     = TextEditingController(text: t?.notes ?? '');
    _category  = t?.category  ?? DsaCategory.arrays;
    _difficulty = t?.difficulty ?? DsaDifficulty.easy;
  }

  @override
  void dispose() {
    _topicName.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notifier = ref.read(dsaNotifierProvider.notifier);
    final topic = DsaTopicModel(
      id:            widget.topic?.id ?? '',
      topicName:     _topicName.text.trim(),
      category:      _category,
      difficulty:    _difficulty,
      isSolved:      widget.topic?.isSolved ?? false,
      solvedDate:    widget.topic?.solvedDate,
      notes:         _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      practiceCount: widget.topic?.practiceCount ?? 0,
    );

    final success = widget.topic != null
        ? await notifier.update(topic)
        : await notifier.create(topic);

    setState(() => _saving = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.topic != null ? 'Topic updated!' : 'Topic added!'),
        backgroundColor: Colors.green,
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.topic != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Topic' : 'Add DSA Topic'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Topic Name
              TextFormField(
                controller: _topicName,
                decoration: InputDecoration(
                  labelText: 'Topic Name *',
                  prefixIcon: const Icon(Icons.code),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Category dropdown
              DropdownButtonFormField<DsaCategory>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: DsaCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 14),

              // Difficulty dropdown
              DropdownButtonFormField<DsaDifficulty>(
                initialValue: _difficulty,
                decoration: InputDecoration(
                  labelText: 'Difficulty',
                  prefixIcon: const Icon(Icons.signal_cellular_alt),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: DsaDifficulty.values
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                    .toList(),
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Update Topic' : 'Save Topic',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
