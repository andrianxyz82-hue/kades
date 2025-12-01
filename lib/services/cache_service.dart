import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/file_model.dart';
import '../models/folder_model.dart';

class CacheService {
  static const String _filesKey = 'cached_files';
  static const String _foldersKey = 'cached_folders';

  // Save files to cache
  Future<void> saveFiles(List<FileModel> files) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> filesJson = files.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_filesKey, filesJson);
  }

  // Get files from cache
  Future<List<FileModel>> getCachedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? filesJson = prefs.getStringList(_filesKey);
    
    if (filesJson == null) return [];
    
    return filesJson.map((f) => FileModel.fromJson(jsonDecode(f))).toList();
  }

  // Save folders to cache
  Future<void> saveFolders(List<FolderModel> folders) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> foldersJson = folders.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_foldersKey, foldersJson);
  }

  // Get folders from cache
  Future<List<FolderModel>> getCachedFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? foldersJson = prefs.getStringList(_foldersKey);
    
    if (foldersJson == null) return [];
    
    return foldersJson.map((f) => FolderModel.fromJson(jsonDecode(f))).toList();
  }
}
