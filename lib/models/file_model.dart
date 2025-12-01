import 'package:flutter/material.dart';

class FileModel {
  final String id;
  final String userId;
  final String? folderId;
  final String name;
  final String fileType;
  final int fileSize;
  final String storagePath;
  final String storageType;
  final DateTime createdAt;

  FileModel({
    required this.id,
    required this.userId,
    this.folderId,
    required this.name,
    required this.fileType,
    required this.fileSize,
    required this.storagePath,
    required this.storageType,
    required this.createdAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      folderId: json['folder_id'] as String?,
      name: json['name'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      storagePath: json['storage_path'] as String,
      storageType: json['storage_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'folder_id': folderId,
      'name': name,
      'file_type': fileType,
      'file_size': fileSize,
      'storage_path': storagePath,
      'storage_type': storageType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData get icon {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
