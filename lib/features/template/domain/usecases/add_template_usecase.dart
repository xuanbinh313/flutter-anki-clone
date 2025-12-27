import '../entities/template.dart';
import '../repositories/template_repository.dart';

class AddTemplateUseCase {
  final TemplateRepository repository;

  AddTemplateUseCase(this.repository);

  Future<void> call(Template template) {
    return repository.addTemplate(template);
  }
}
