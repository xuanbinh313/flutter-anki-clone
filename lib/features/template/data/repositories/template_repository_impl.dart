import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/template.dart';
import '../../domain/repositories/template_repository.dart';
import '../datasources/template_remote_datasource.dart';
import '../models/template_model.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateRemoteDataSource remoteDataSource;

  TemplateRepositoryImpl({required this.remoteDataSource});

  Future<bool> get _isConnected async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  @override
  Future<List<Template>> getTemplates() async {
    final remoteTemplates = await remoteDataSource.getTemplates();
    return remoteTemplates;
  }

  @override
  Future<Template> getTemplateById(String id) async {
    final remoteTemplate = await remoteDataSource.getTemplateById(id);
    return remoteTemplate;
  }

  @override
  Future<void> addTemplate(Template template) async {
    final templateModel = TemplateModel.fromEntity(template);

    if (await _isConnected) {
      try {
        await remoteDataSource.addTemplate(templateModel);
      } catch (e) {
        // failed to sync, keep as unsynced
      }
    }
  }

  @override
  Future<void> updateTemplate(Template template) async {
    final templateModel = TemplateModel.fromEntity(template);

    if (await _isConnected) {
      try {
        await remoteDataSource.updateTemplate(templateModel);
      } catch (e) {
        // failed to sync
      }
    }
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await remoteDataSource.deleteTemplate(id);
  }

  Future<void> syncTemplates() async {
    // This would be called periodically or on app start to push unsynced changes
    // For now, leaving empty or simple implementation.
    // We would query local templates where synced = false and try to push them.
    if (await _isConnected) {
      final remoteTemplates = await remoteDataSource.getTemplates();
      for (var template in remoteTemplates) {
        try {
          await remoteDataSource.addTemplate(
            template,
          ); // Assuming add handles upsert or we check id first
        } catch (e) {
          try {
            await remoteDataSource.updateTemplate(template);
          } catch (e2) {
            // failed to sync
          }
        }
      }
    }
  }
}
