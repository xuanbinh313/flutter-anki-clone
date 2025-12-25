import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/note_viewmodel.dart';

class NoteDetailsPage extends ConsumerWidget {
  final String noteId;
  const NoteDetailsPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteState = ref.watch(noteDetailsProvider(noteId));

    return Scaffold(
      appBar: AppBar(title: const Text('Note Details')),
      body: noteState.when(
        data: (note) {
          return Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(note.sfld),
                Text(note.createdAt.toString()),
                Text(note.updatedAt.toString()),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
