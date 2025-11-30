import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'camera_save_screen.dart';

class UploadActionSheet extends StatelessWidget {
  const UploadActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Upload Options',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Options
          _buildOption(
            Icons.camera_alt,
            'Take Photo',
            AppColors.blueGradient,
            context,
          ),
          const SizedBox(height: 12),
          _buildOption(
            Icons.photo_library,
            'Upload Photo',
            AppColors.purpleGradient,
            context,
          ),
          const SizedBox(height: 12),
          _buildOption(
            Icons.videocam,
            'Upload Video',
            const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            context,
          ),
          const SizedBox(height: 12),
          _buildOption(
            Icons.description,
            'Upload Document',
            const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            context,
          ),
          const SizedBox(height: 12),
          _buildOption(
            Icons.create_new_folder,
            'Create Folder',
            const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            context,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildOption(IconData icon, String label, Gradient gradient, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close bottom sheet first
        
        if (label == 'Take Photo') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraSaveScreen(),
            ),
          );
        } else if (label == 'Upload Photo') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening gallery...')),
          );
        } else if (label == 'Upload Video') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening video picker...')),
          );
        } else if (label == 'Upload Document') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening document picker...')),
          );
        } else if (label == 'Create Folder') {
          _showCreateFolderDialog(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreateFolderDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Folder'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Folder "${controller.text}" created')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
