import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/template_viewmodel.dart';

class TemplateDetailsPage extends ConsumerStatefulWidget {
  final String templateId;
  const TemplateDetailsPage({super.key, required this.templateId});

  @override
  ConsumerState<TemplateDetailsPage> createState() =>
      _TemplateDetailsPageState();
}

class _TemplateDetailsPageState extends ConsumerState<TemplateDetailsPage> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templateState = ref.watch(templateDetailsProvider(widget.templateId));
    return Scaffold(
      appBar: AppBar(title: const Text('Template Details')),
      body: templateState.when(
        data: (template) {
          _controller.text = template.name;
          return Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                Text(template.createdAt.toString()),
                Text(template.updatedAt.toString()),
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
