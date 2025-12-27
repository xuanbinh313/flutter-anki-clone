import 'dart:async';
import 'package:anki_clone/features/template/domain/usecases/get_template_by_id_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../main.dart'; // Accessing global supabase client
import '../../domain/entities/template.dart';
import '../../domain/usecases/add_template_usecase.dart';
import '../../domain/usecases/delete_template_usecase.dart';
import '../../domain/usecases/get_templates_usecase.dart';
import '../../domain/usecases/update_template_usecase.dart';
import '../../data/datasources/template_remote_datasource.dart';
import '../../data/repositories/template_repository_impl.dart';

// Data Sources
final templateRemoteDataSourceProvider = Provider<TemplateRemoteDataSource>((
  ref,
) {
  return TemplateRemoteDataSourceImpl(supabaseClient: supabase);
});

// Repository
final templateRepositoryProvider = Provider<TemplateRepositoryImpl>((ref) {
  return TemplateRepositoryImpl(
    remoteDataSource: ref.watch(templateRemoteDataSourceProvider),
  );
});

// Use Cases
final getTemplatesUseCaseProvider = Provider(
  (ref) => GetTemplatesUseCase(ref.watch(templateRepositoryProvider)),
);
final addTemplateUseCaseProvider = Provider(
  (ref) => AddTemplateUseCase(ref.watch(templateRepositoryProvider)),
);
final updateTemplateUseCaseProvider = Provider(
  (ref) => UpdateTemplateUseCase(ref.watch(templateRepositoryProvider)),
);
final deleteTemplateUseCaseProvider = Provider(
  (ref) => DeleteTemplateUseCase(ref.watch(templateRepositoryProvider)),
);
final getTemplateByIdUseCaseProvider = Provider(
  (ref) => GetTemplateByIdUseCase(ref.watch(templateRepositoryProvider)),
);

// ViewModel (AsyncNotifier)
class TemplateListNotifier extends AsyncNotifier<List<Template>> {
  @override
  FutureOr<List<Template>> build() async {
    return _getTemplates();
  }

  Future<List<Template>> _getTemplates() {
    final getTemplates = ref.read(getTemplatesUseCaseProvider);
    return getTemplates();
  }

  Future<void> addTemplate(Template template) async {
    final addTemplate = ref.read(addTemplateUseCaseProvider);
    final newTemplate = Template(
      id: const Uuid().v4(),
      name: template.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([...state.value!, newTemplate]);
    }

    try {
      await addTemplate(newTemplate);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> updateTemplate(Template template) async {
    final updateTemplate = ref.read(updateTemplateUseCaseProvider);
    final updatedTemplate = template.copyWith(updatedAt: DateTime.now());

    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final t in state.value!)
          if (t.id == template.id) updatedTemplate else t,
      ]);
    }

    try {
      await updateTemplate(updatedTemplate);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> deleteTemplate(String id) async {
    final deleteTemplate = ref.read(deleteTemplateUseCaseProvider);
    // Optimistic update
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final t in state.value!)
          if (t.id != id) t,
      ]);
    }

    try {
      await deleteTemplate(id);
    } catch (e) {
      state = previousState;
    }
  }
}

class TemplateDetailsNotifier extends AsyncNotifier<Template> {
  final String id;

  TemplateDetailsNotifier({required this.id});

  @override
  FutureOr<Template> build() async {
    return _getTemplateById(id);
  }

  Future<Template> _getTemplateById(String id) {
    final getTemplateById = ref.read(getTemplateByIdUseCaseProvider);
    return getTemplateById(id);
  }
}

final templateListProvider =
    AsyncNotifierProvider<TemplateListNotifier, List<Template>>(() {
      return TemplateListNotifier();
    });

final templateDetailsProvider =
    AsyncNotifierProvider.family<TemplateDetailsNotifier, Template, String>(
      (id) => TemplateDetailsNotifier(id: id),
    );
