import '../entities/template.dart';
import '../repositories/template_repository.dart';

class UpdateTemplateUseCase {
  final TemplateRepository repository;

  UpdateTemplateUseCase(this.repository);

  Future<void> call(Template template) {
    return repository.updateTemplate(template);
  }
}
