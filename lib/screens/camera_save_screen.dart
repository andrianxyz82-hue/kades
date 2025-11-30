import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';

class CameraSaveScreen extends StatefulWidget {
  const CameraSaveScreen({super.key});

  @override
  State<CameraSaveScreen> createState() => _CameraSaveScreenState();
}

class _CameraSaveScreenState extends State<CameraSaveScreen> {
  int _currentStep = 0; // 0: Capture, 1: Preview, 2: Select Storage, 3: Select Folder
  String? _selectedStorage;
  String? _selectedFolder;

  final List<Map<String, dynamic>> _storageOptions = [
    {'name': 'File Box', 'icon': Icons.folder, 'color': AppColors.blueGradientEnd},
    {'name': 'Google Drive', 'icon': Icons.cloud, 'color': AppColors.purpleGradientEnd},
    {'name': 'Internal Storage', 'icon': Icons.smartphone, 'color': AppGradients.yellowGradientEnd},
  ];

  final List<String> _folders = [
    'My Documents',
    'Work Projects',
    'Family Photos',
    'Vacation 2024',
    'Receipts',
  ];

  
  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _currentStep = 1;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _currentStep = 0;
      _selectedStorage = null;
      _selectedFolder = null;
    });
  }

  void _proceedToStorageSelection() {
    setState(() {
      _currentStep = 2;
    });
  }

  void _selectStorage(String storageName) {
    setState(() {
      _selectedStorage = storageName;
      _currentStep = 3;
    });
  }

  void _selectFolder(String folderName) {
    setState(() {
      _selectedFolder = folderName;
    });
  }

  void _uploadPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uploading to $_selectedStorage > $_selectedFolder...'),
        backgroundColor: AppColors.blueGradientEnd,
      ),
    );
    // Simulate upload delay then close
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Successful!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 48),
                  Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Take Photo';
      case 1: return 'Preview';
      case 2: return 'Select Storage';
      case 3: return 'Select Folder';
      default: return '';
    }
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case 0: return _buildCaptureView();
      case 1: return _buildPreviewView();
      case 2: return _buildStorageSelectionView();
      case 3: return _buildFolderSelectionView();
      default: return Container();
    }
  }

  Widget _buildCaptureView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt, size: 64, color: Colors.white54),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32),
          child: GestureDetector(
            onTap: _takePhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/placeholder_image.jpg'), // Placeholder
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(
              child: Text(
                'Photo Preview',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _retakePhoto,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Retake', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton.icon(
                onPressed: _proceedToStorageSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueGradientEnd,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Use Photo', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSelectionView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _storageOptions.length,
      itemBuilder: (context, index) {
        final option = _storageOptions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () => _selectStorage(option['name']),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: option['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(option['icon'], color: option['color'], size: 28),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    option['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFolderSelectionView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors.grey[900],
          child: Row(
            children: [
              const Text('Storage: ', style: TextStyle(color: Colors.white54)),
              Text(_selectedStorage ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _folders.length,
            itemBuilder: (context, index) {
              final folder = _folders[index];
              final isSelected = _selectedFolder == folder;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _selectFolder(folder),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blueGradientEnd.withOpacity(0.2) : Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? AppColors.blueGradientEnd : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: isSelected ? AppColors.blueGradientEnd : Colors.white54,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          folder,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.blueGradientEnd),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedFolder != null ? _uploadPhoto : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueGradientEnd,
                disabledBackgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Upload Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
