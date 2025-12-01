import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/storage_card.dart';
import '../widgets/category_item.dart';
import 'file_manager_screen.dart';
import 'profile_screen.dart';
import 'filebox_storage_screen.dart';
import 'gdrive_storage_screen.dart';
import 'internal_storage_screen.dart';
import 'package:smart_file_storage/screens/filebox_storage_screen.dart';
import 'camera_save_screen.dart';
import '../theme/app_gradients.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

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
                  children: const [
                    CategoryItem(
                      icon: Icons.image,
                      label: 'Picture',
                      iconColor: AppColors.iconYellow,
                    ),
                    CategoryItem(
                      icon: Icons.videocam,
                      label: 'Video',
                      iconColor: AppColors.iconRed,
                    ),
                    CategoryItem(
                      icon: Icons.description,
                      label: 'My File',
                      iconColor: AppColors.iconYellow,
                    ),
                    CategoryItem(
                      icon: Icons.apps,
                      label: 'Apps',
                      iconColor: AppColors.iconBlue,
                    ),
                  ],
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
            
            // Quick Camera Button
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
