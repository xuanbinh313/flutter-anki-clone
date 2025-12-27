import '../entities/template.dart';
import '../repositories/template_repository.dart';

class GetTemplatesUseCase {
  final TemplateRepository repository;

  GetTemplatesUseCase(this.repository);

  Future<List<Template>> call() {
    return repository.getTemplates();
  }
}
