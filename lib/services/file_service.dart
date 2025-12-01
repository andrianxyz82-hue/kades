import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/file_model.dart';

class FileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Save file metadata to database
  Future<FileModel> saveFile({
    required String name,
    required String storagePath,
    required String fileType,
    required int fileSize,
    String? folderId,
    String storageType = 'filebox',
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final response = await _supabase.from('files').insert({
        'user_id': userId,
        'folder_id': folderId,
        'name': name,
        'file_type': fileType,
        'file_size': fileSize,
        'storage_path': storagePath,
        'storage_type': storageType,
      }).select().single();

      return FileModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  // Get files (optionally filter by folder)
  Future<List<FileModel>> getFiles({
    String? folderId,
    String storageType = 'filebox',
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      var query = _supabase
          .from('files')
          .select()
          .eq('user_id', userId)
          .eq('storage_type', storageType);

      if (folderId != null) {
        query = query.eq('folder_id', folderId);
      } else {
        query = query.isFilter('folder_id', null);
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => FileModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get files: $e');
    }
  }

  // Delete file metadata
  Future<void> deleteFile(String fileId) async {
    try {
      await _supabase.from('files').delete().eq('id', fileId);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get files in folder (including subfolders)
  Future<List<FileModel>> getFilesInFolder(String folderId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .from('files')
          .select()
          .eq('user_id', userId)
          .eq('folder_id', folderId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => FileModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get files in folder: $e');
    }
  }
}
