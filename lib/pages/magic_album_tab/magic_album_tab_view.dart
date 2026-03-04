import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../magic_album_home/magic_album_home_view.dart';
import '../magic_album_my_albums/magic_album_my_albums_view.dart';
import '../magic_album_settings/magic_album_settings_view.dart';
import 'magic_album_tab_logic.dart';
class MagicAlbumTabView extends GetView<MagicAlbumTabLogic> {
  const MagicAlbumTabView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            MagicAlbumHomeView(),
            MagicAlbumMyAlbumsView(),
            MagicAlbumSettingsView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => _buildBottomNav()),
    );
  }
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h).copyWith(bottom: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildTabItem(
                icon: Icons.photo_album_outlined,
                activeIcon: Icons.photo_album,
                label: 'My Albums',
                index: 1,
              ),
              _buildTabItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTabItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = controller.currentIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTabChange(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24.w,
              color: isActive ? primaryColor : textSecondary,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? primaryColor : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
