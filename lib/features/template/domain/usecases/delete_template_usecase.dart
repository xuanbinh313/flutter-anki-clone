import '../repositories/template_repository.dart';

class DeleteTemplateUseCase {
  final TemplateRepository repository;

  DeleteTemplateUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteTemplate(id);
  }
}
