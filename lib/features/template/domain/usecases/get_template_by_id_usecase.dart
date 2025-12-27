import '../entities/template.dart';
import '../repositories/template_repository.dart';

class GetTemplateByIdUseCase {
  final TemplateRepository repository;

  GetTemplateByIdUseCase(this.repository);

  Future<Template> call(String id) {
    return repository.getTemplateById(id);
  }
}
