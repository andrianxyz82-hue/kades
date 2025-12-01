import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucketName = 'filebox';

  // Upload file to Supabase Storage
  Future<String> uploadFile({
    required File file,
    required String userId,
    String? folderId,
  }) async {
    try {
      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = path.extension(fileName);
      
      // Create unique file path: userId/folderId/timestamp_filename
      String storagePath;
      if (folderId != null) {
        storagePath = '$userId/$folderId/${timestamp}_$fileName';
      } else {
        storagePath = '$userId/${timestamp}_$fileName';
      }

      // Upload to Supabase Storage
      await _supabase.storage.from(bucketName).upload(
            storagePath,
            file,
            fileOptions: FileOptions(
              upsert: false,
            ),
          );

      return storagePath;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Delete file from Supabase Storage
  Future<void> deleteFile(String storagePath) async {
    try {
      await _supabase.storage.from(bucketName).remove([storagePath]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get public URL for file (signed URL for private bucket)
  Future<String> getFileUrl(String storagePath) async {
    try {
      // For private buckets, create signed URL (valid for 1 hour)
      final signedUrl = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(storagePath, 3600);
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to get file URL: $e');
    }
  }

  // Get file type from extension
  String getFileType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension)) {
      return 'image';
    } else if (['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension)) {
      return 'video';
    } else if (['.pdf', '.doc', '.docx', '.txt', '.xls', '.xlsx', '.ppt', '.pptx'].contains(extension)) {
      return 'document';
    } else {
      return 'other';
    }
  }
}
