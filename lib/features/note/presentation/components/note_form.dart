// features/note/presentation/screens/note_form_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteFormWidget extends ConsumerStatefulWidget {
  final List<String> fieldLabels;

  const NoteFormWidget({super.key, required this.fieldLabels});

  @override
  ConsumerState<NoteFormWidget> createState() => _NoteFormWidgetState();
}

class _NoteFormWidgetState extends ConsumerState<NoteFormWidget> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.fieldLabels.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  void _submit() {
    // Lấy value
    final values = _controllers.map((c) => c.text).toList();
    print('Submit to DB: $values');
    // ref.read(noteControllerProvider.notifier).addNote(...);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: widget.fieldLabels.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              _controllers[index].text = widget.fieldLabels[index];
              return TextField(
                controller: _controllers[index],
                decoration: InputDecoration(
                  labelText: "Field ${index + 1}", // 'Front', 'Back'...
                  border: const OutlineInputBorder(),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _submit,
            child: const Text('Save Note'),
          ),
        ),
      ],
    );
  }
}
