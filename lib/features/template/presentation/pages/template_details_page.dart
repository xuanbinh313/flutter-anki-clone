import 'package:anki_clone/features/template/presentation/pages/universal_web_editor.dart';
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
    return templateState.when(
      data: (template) {
        _controller.text = template.name;
        return Container(
          padding: EdgeInsets.all(20.0),
          child: UniversalWebEditor(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
