import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../models/folder_model.dart';
import '../models/file_model.dart';
import '../services/folder_service.dart';
import '../services/file_service.dart';
import '../services/storage_service.dart';
import 'profile_screen.dart';

class FileBoxStorageScreen extends StatefulWidget {
  final String? parentFolderId;
  final String? folderName;

  const FileBoxStorageScreen({
    super.key,
    this.parentFolderId,
    this.folderName,
  });

  @override
  State<FileBoxStorageScreen> createState() => _FileBoxStorageScreenState();
}

class _FileBoxStorageScreenState extends State<FileBoxStorageScreen> {
  final _folderService = FolderService();
  final _fileService = FileService();
  final _storageService = StorageService();
  
  List<FolderModel> _folders = [];
  List<FileModel> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final folders = await _folderService.getFolders(parentId: widget.parentFolderId);
      final files = await _fileService.getFiles(folderId: widget.parentFolderId);
      
      setState(() {
        _folders = folders;
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      try {
        await _folderService.createFolder(
          name: controller.text,
          parentId: widget.parentFolderId,
        );
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating folder: $e')),
          );
        }
      }
    }
  }

  Future<void> _renameFolder(FolderModel folder) async {
    final controller = TextEditingController(text: folder.name);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'New folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      try {
        await _folderService.renameFolder(folder.id, controller.text);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder renamed successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error renaming folder: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteFolder(FolderModel folder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"? All files inside will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _folderService.deleteFolder(folder.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting folder: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteFile(FileModel file) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _storageService.deleteFile(file.storagePath);
        await _fileService.deleteFile(file.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting file: $e')),
          );
        }
      }
    }
  }

  Future<void> _uploadFile(String type) async {
    try {
      File? file;
      String? fileName;
      List<int>? fileBytes;

      if (type == 'photo') {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          fileName = pickedFile.name;
          fileBytes = await pickedFile.readAsBytes();
        }
      } else if (type == 'video') {
        final picker = ImagePicker();
        final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
        if (pickedFile != null) {
          fileName = pickedFile.name;
          fileBytes = await pickedFile.readAsBytes();
        }
      } else {
        // Document
        final result = await FilePicker.platform.pickFiles();
        if (result != null) {
          fileName = result.files.single.name;
          fileBytes = result.files.single.bytes;
        }
      }

      if (fileBytes != null && fileName != null) {
        // Show loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading file...')),
          );
        }

        // Upload to Supabase Storage
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Create storage path
        String storagePath;
        if (widget.parentFolderId != null) {
          storagePath = '$userId/${widget.parentFolderId}/${timestamp}_$fileName';
        } else {
          storagePath = '$userId/${timestamp}_$fileName';
        }

        // Upload using bytes (web-compatible)
        await Supabase.instance.client.storage
            .from('filebox')
            .uploadBinary(storagePath, Uint8List.fromList(fileBytes));

        // Save metadata to database
        final fileType = _storageService.getFileType(fileName);
        
        await _fileService.saveFile(
          name: fileName,
          storagePath: storagePath,
          fileType: fileType,
          fileSize: fileBytes.length,
          folderId: widget.parentFolderId,
        );

        _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  Future<void> _openFile(FileModel file) async {
    try {
      final url = await _storageService.getFileUrl(file.storagePath);
      await OpenFile.open(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder, color: AppColors.iconBlue),
              title: const Text('Create Folder'),
              onTap: () {
                Navigator.pop(context);
                _createFolder();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo, color: AppColors.iconYellow),
              title: const Text('Upload Photo'),
              onTap: () {
                Navigator.pop(context);
                _uploadFile('photo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppColors.iconRed),
              title: const Text('Upload Video'),
              onTap: () {
                Navigator.pop(context);
                _uploadFile('video');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.iconBlue),
              title: const Text('Upload Document'),
              onTap: () {
                Navigator.pop(context);
                _uploadFile('document');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios),
                          color: AppColors.textPrimary,
                        ),
                        Text(
                          widget.folderName ?? 'File Box',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.blueGradientEnd,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Files Section
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            // Storage Card (animated)
                            if (!_isExpanded)
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.blueGradient,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.blueGradientEnd.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  child: const Icon(
                                                    Icons.folder,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                const Text(
                                                  'File Box Storage',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        
                                        // Progress Bar
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatBytes(_usedStorageBytes),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              _formatBytes(_totalStorageBytes),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: _totalStorageBytes > 0 
                                                ? _usedStorageBytes / _totalStorageBytes 
                                                : 0,
                                            backgroundColor: Colors.white.withOpacity(0.3),
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                            minHeight: 8,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Clean Button
                                        GestureDetector(
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Clean storage feature coming soon!'),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Text(
                                                  'Clean Storage',
                                                  style: TextStyle(
                                                    color: AppColors.blueGradientEnd,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.cleaning_services,
                                                  color: AppColors.blueGradientEnd,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Section Header with View Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Supabase Files',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _toggleView,
                                  child: Text(
                                    _isExpanded ? 'Back' : 'View All',
                                    style: const TextStyle(
                                      color: AppColors.blueGradientEnd,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total ${_files.length} files',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            if (_folders.isEmpty && _files.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text(
                                    'No files or folders yet.\nTap + to upload or create folder.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            
                            // Folders
                            ..._folders.map((folder) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildFolderItem(folder),
                            )),
                            
                            // Files
                            ..._files.map((file) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildFileItem(file),
                            )),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadOptions,
        backgroundColor: AppColors.blueGradientEnd,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildFolderItem(FolderModel folder) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileBoxStorageScreen(
              parentFolderId: folder.id,
              folderName: folder.name,
            ),
          ),
        ).then((_) => _loadData());
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Rename'),
                  onTap: () {
                    Navigator.pop(context);
                    _renameFolder(folder);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteFolder(folder);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.iconBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.folder,
                color: AppColors.iconBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Folder',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(FileModel file) {
    return GestureDetector(
      onTap: () => _openFile(file),
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteFile(file);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.iconYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                file.icon,
                color: AppColors.iconYellow,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${file.fileType} · ${file.formattedSize}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blueGradientStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.cloud_done,
                color: AppColors.blueGradientEnd,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
