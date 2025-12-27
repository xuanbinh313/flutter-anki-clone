import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/template_model.dart';

abstract class TemplateRemoteDataSource {
  Future<List<TemplateModel>> getTemplates();
  Future<TemplateModel> getTemplateById(String id);
  Future<void> addTemplate(TemplateModel template);
  Future<void> updateTemplate(TemplateModel template);
  Future<void> deleteTemplate(String id);
}

class TemplateRemoteDataSourceImpl implements TemplateRemoteDataSource {
  final SupabaseClient supabaseClient;

  TemplateRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<TemplateModel>> getTemplates() async {
    final response = await supabaseClient
        .from('notetypes')
        .select()
        .order('created_at');
    return (response as List)
        .map((json) => TemplateModel.fromJson(json))
        .toList();
  }

  @override
  Future<TemplateModel> getTemplateById(String id) async {
    final response = await supabaseClient
        .from('notetypes')
        .select('id,name,created_at,updated_at')
        .eq('id', id);
    return TemplateModel.fromJson(response.first);
  }

  @override
  Future<void> addTemplate(TemplateModel template) async {
    final data = template.toSupabase();
    data['user_id'] = supabaseClient.auth.currentUser!.id;
    await supabaseClient.from('notetypes').insert(data);
  }

  @override
  Future<void> updateTemplate(TemplateModel template) async {
    await supabaseClient
        .from('notetypes')
        .update({
          'name': template.name,
          'updated_at': template.updatedAt.toIso8601String(),
        })
        .eq('id', template.id);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await supabaseClient.from('templates').delete().eq('id', id);
  }
}
