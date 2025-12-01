import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_file_storage/models/file_model.dart';
import 'package:smart_file_storage/services/file_service.dart';
import 'package:smart_file_storage/theme/app_colors.dart';
import 'package:smart_file_storage/screens/filebox_storage_screen.dart';
import 'package:smart_file_storage/screens/gdrive_storage_screen.dart';
import 'package:smart_file_storage/screens/internal_storage_screen.dart';
import 'package:smart_file_storage/screens/camera_save_screen.dart';
import 'package:smart_file_storage/screens/profile_screen.dart';
import '../theme/app_gradients.dart';
import '../widgets/storage_card.dart';
import '../widgets/category_item.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _fileService = FileService();
  List<FileModel> _recentFiles = [];
  bool _isLoading = false;
  String _selectedCategory = 'photo'; // Default category

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all files then filter locally for now (can be optimized to filter in query)
      final files = await _fileService.getFiles();
      
      setState(() {
        _recentFiles = files.where((file) {
          if (_selectedCategory == 'photo') return file.fileType == 'photo';
          if (_selectedCategory == 'video') return file.fileType == 'video';
          if (_selectedCategory == 'document') return file.fileType == 'document';
          return true;
        }).take(5).toList(); // Take top 5 recent
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading files: $e');
    }
  }

  Widget _buildCategoryItem(IconData icon, String label, Color iconColor, String categoryKey) {
    final isSelected = _selectedCategory == categoryKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryKey;
        });
        _loadRecentFiles();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blueGradientEnd.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: AppColors.blueGradientEnd, width: 2) : null,
              boxShadow: isSelected ? [] : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.blueGradientEnd : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for floating effect
      backgroundColor: AppColors.backgroundGradient.colors.first, // Fix dark area
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          bottom: false, // Allow content to go behind bottom nav
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 120), // Reduced top padding, increased bottom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Text (Moved up)
                const Text(
                  'K-DC',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '(kapak data center)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4), // Reduced spacing
                const Text(
                  "aplikasi databse internal komunitas penggiat alam kareumbi",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24), // Reduced spacing
                
                // Storage Cards
                SizedBox(
                  height: 220,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.85),
                    padEnds: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FileBoxStorageScreen(),
                              ),
                            );
                          },
                          child: const StorageCard(
                            title: 'File Box',
                            usedStorage: '56.5',
                            totalStorage: '80',
                            progress: 0.7,
                            gradient: AppColors.blueGradient,
                            icon: Icons.folder,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GDriveStorageScreen(),
                              ),
                            );
                          },
                          child: const StorageCard(
                            title: 'G Drive',
                            usedStorage: '10.08',
                            totalStorage: '15',
                            progress: 0.67,
                            gradient: AppColors.purpleGradient,
                            icon: Icons.cloud,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InternalStorageScreen(),
                              ),
                            );
                          },
                          child: const StorageCard(
                            title: 'Device',
                            usedStorage: '112',
                            totalStorage: '128',
                            progress: 0.87,
                            gradient: AppGradients.yellowGradient,
                            icon: Icons.smartphone,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24), // Reduced spacing
                
                // Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.blueGradientEnd,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Total 32 files',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16), // Reduced spacing
                
                // Category Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryItem(Icons.image, 'Picture', AppColors.iconYellow, 'photo'),
                    _buildCategoryItem(Icons.videocam, 'Video', AppColors.iconRed, 'video'),
                    _buildCategoryItem(Icons.description, 'My File', AppColors.iconYellow, 'document'),
                    _buildCategoryItem(Icons.apps, 'Apps', AppColors.iconBlue, 'app'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recent Files List (Filtered)
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_recentFiles.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No files found in this category'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentFiles.length,
                    itemBuilder: (context, index) {
                      final file = _recentFiles[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(file.icon, color: AppColors.blueGradientEnd),
                        ),
                        title: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(file.formattedSize),
                        trailing: const Icon(Icons.more_vert, size: 20),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24), // Added bottom margin
        padding: const EdgeInsets.symmetric(vertical: 12), // Reduced vertical padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.explore, 'Explore', true),
            _buildNavItem(context, Icons.folder_open, 'Files', false),
            
            // Floating Action Button (Center)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraSaveScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueGradientEnd.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            
            _buildNavItem(context, Icons.cloud_queue, 'Cloud', false),
            _buildNavItem(context, Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == 'Files') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FileBoxStorageScreen(),
            ),
          );
        } else if (label == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        } else if (label == 'Cloud') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GDriveStorageScreen(),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isActive ? AppColors.blueGradient : null,
              color: isActive ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.blueGradientEnd : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
