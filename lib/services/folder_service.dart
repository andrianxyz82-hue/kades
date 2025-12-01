import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/folder_model.dart';

class FolderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create new folder
  Future<FolderModel> createFolder({
    required String name,
    String? parentId,
    String storageType = 'filebox',
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final response = await _supabase.from('folders').insert({
        'user_id': userId,
        'name': name,
        'parent_id': parentId,
        'storage_type': storageType,
      }).select().single();

      return FolderModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }

  // Get folders (optionally filter by parent)
  Future<List<FolderModel>> getFolders({
    String? parentId,
    String storageType = 'filebox',
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      var query = _supabase
          .from('folders')
          .select()
          .eq('user_id', userId)
          .eq('storage_type', storageType);

      if (parentId != null) {
        query = query.eq('parent_id', parentId);
      } else {
        query = query.isFilter('parent_id', null);
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => FolderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get folders: $e');
    }
  }

  // Rename folder
  Future<void> renameFolder(String folderId, String newName) async {
    try {
      await _supabase.from('folders').update({
        'name': newName,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', folderId);
    } catch (e) {
      throw Exception('Failed to rename folder: $e');
    }
  }

  // Delete folder (cascade delete handled by database)
  Future<void> deleteFolder(String folderId) async {
    try {
      await _supabase.from('folders').delete().eq('id', folderId);
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }
}
