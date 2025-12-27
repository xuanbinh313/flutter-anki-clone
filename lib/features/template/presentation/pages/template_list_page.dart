import 'package:anki_clone/features/template/domain/entities/template.dart';
import 'package:anki_clone/features/template/presentation/pages/template_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../viewmodels/template_viewmodel.dart';

class TemplateListPage extends ConsumerWidget {
  const TemplateListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateState = ref.watch(templateListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Template List')),
      body: templateState.when(
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(child: Text('No templates yet.'));
          }
          return Container(
            padding: EdgeInsets.all(20.0),
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'name',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'createdAt',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'actions',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
              rows: templates.map((template) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      GestureDetector(
                        child: Text(template.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TemplateDetailsPage(templateId: template.id),
                            ),
                          );
                        },
                      ),
                    ),
                    DataCell(Text(template.createdAt.toString())),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          ref
                              .read(templateListProvider.notifier)
                              .deleteTemplate(template.id);
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTemplateDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Template'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Template title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(templateListProvider.notifier)
                    .addTemplate(
                      Template(
                        id: const Uuid().v4(),
                        name: controller.text,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
