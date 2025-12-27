import '../entities/template.dart';

abstract class TemplateRepository {
  Future<List<Template>> getTemplates();
  Future<Template> getTemplateById(String id);
  Future<void> addTemplate(Template template);
  Future<void> updateTemplate(Template template);
  Future<void> deleteTemplate(String id);
}
