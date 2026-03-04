import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'magic_album_settings_logic.dart';
class MagicAlbumSettingsView extends GetView<MagicAlbumSettingsLogic> {
  const MagicAlbumSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            _buildSectionTitle('Data'),
            _buildSection([
              _buildSettingItem(
                icon: Icons.delete_sweep_outlined,
                iconColor: const Color(0xFFEF4444),
                title: 'Delete All Data',
                onTap: controller.onDeleteAllDataTap,
              ),
            ]),
            SizedBox(height: 8.h),
            _buildSectionTitle('About'),
            _buildSection([
              _buildSettingItem(
                icon: Icons.info_outline_rounded,
                iconColor: primaryColor,
                title: 'Version',
                trailing: Obx(
                  () => Text(
                    controller.appVersion.value,
                    style: TextStyle(fontSize: 13.sp, color: textSecondary),
                  ),
                ),
              ),
            ]),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Icon(icon, color: iconColor, size: 18.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: textBlack,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                size: 20.w,
                color: textSecondary.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}
