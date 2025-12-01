import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/file_model.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';
import '../theme/app_colors.dart';

class FilePreviewScreen extends StatefulWidget {
  final FileModel file;

  const FilePreviewScreen({super.key, required this.file});

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  final _storageService = StorageService();
  final _fileService = FileService();
  bool _isLoading = false;
  String? _fileUrl;

  @override
  void initState() {
    super.initState();
    _loadFileUrl();
  }

  Future<void> _loadFileUrl() async {
    setState(() => _isLoading = true);
    try {
      final url = await _storageService.getFileUrl(widget.file.storagePath);
      setState(() {
        _fileUrl = url;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading file: $e')),
        );
      }
    }
  }

  Future<void> _downloadFile() async {
    if (_fileUrl == null) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(_fileUrl!));
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.file.name}');
      await file.writeAsBytes(response.bodyBytes);
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to ${file.path}')),
        );
        OpenFile.open(file.path);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    }
  }

  Future<void> _shareFile() async {
    if (_fileUrl == null) return;
    
    // Share URL directly
    await Share.share('Check out this file: $_fileUrl');
  }

  Future<void> _deleteFile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${widget.file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        // Delete from Storage
        await _storageService.deleteFile(widget.file.storagePath);
        
        // Delete from Database
        await _fileService.deleteFile(widget.file.id);
        
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting file: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.file.name,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareFile,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadFile,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteFile,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _fileUrl == null
                ? const Text('Failed to load file', style: TextStyle(color: Colors.white))
                : _buildPreviewContent(),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (widget.file.fileType == 'photo') {
      return Image.network(
        _fileUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
          );
        },
      );
    } else if (widget.file.fileType == 'video') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam, size: 100, color: Colors.white54),
          const SizedBox(height: 20),
          const Text(
            'Video Preview Not Supported Yet',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _downloadFile,
            child: const Text('Download to Watch'),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.file.icon, size: 100, color: Colors.white54),
          const SizedBox(height: 20),
          Text(
            '${widget.file.fileType.toUpperCase()} File',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _downloadFile,
            child: const Text('Download to View'),
          ),
        ],
      );
    }
  }
}
