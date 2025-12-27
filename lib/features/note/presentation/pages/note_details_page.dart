import 'package:anki_clone/features/note/presentation/components/note_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/note_viewmodel.dart';

class NoteDetailsPage extends ConsumerStatefulWidget {
  final String noteId;
  const NoteDetailsPage({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailsPage> createState() => _NoteDetailsPageState();
}

class _NoteDetailsPageState extends ConsumerState<NoteDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteState = ref.watch(noteDetailsProvider(widget.noteId));
    return Scaffold(
      appBar: AppBar(title: const Text('Note Details')),
      body: noteState.when(
        data: (note) {
          return NoteFormWidget(fieldLabels: note.fields);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
