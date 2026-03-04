import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../db_magic_album/db_magic_album_entity.dart';
import '../../main.dart';
import 'magic_album_home_logic.dart';
class MagicAlbumHomeView extends GetView<MagicAlbumHomeLogic> {
  const MagicAlbumHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: primaryColor, size: 20.w),
            SizedBox(width: 6.w),
            Text(
              'Magic Album',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textBlack,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            _buildHowItWorks(),
            _buildThemes(),
            _buildAlbumTypeCards(),
            _buildRecentAlbums(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
  Widget _buildBanner() {
    final banners = [
      _BannerItem(
        gradient: const LinearGradient(
          colors: [Color(0xFF9F7AEA), Color(0xFFF472B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.music_note_rounded,
        title: 'Music Album',
        subtitle: 'Turn photos into a\ndynamic music album',
      ),
      _BannerItem(
        gradient: const LinearGradient(
          colors: [Color(0xFFC4B5FD), Color(0xFFA78BFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.photo_library_rounded,
        title: 'Photo Story',
        subtitle: 'Create beautiful\nphoto articles',
      ),
    ];
    return Container(
      height: 180.h,
      margin: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: banners.length,
              onPageChanged: controller.onBannerChange,
              itemBuilder: (_, i) => _buildBannerItem(banners[i]),
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: controller.bannerIndex.value == i ? 16.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: controller.bannerIndex.value == i
                        ? primaryColor
                        : primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBannerItem(_BannerItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(16.w),
      ),
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 40.w, color: Colors.white),
          ),
        ],
      ),
    );
  }
  Widget _buildHowItWorks() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textBlack,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _buildStep(
                icon: Icons.category_outlined,
                label: '① Choose Type',
                color: primaryColor,
              ),
              _buildArrow(),
              _buildStep(
                icon: Icons.photo_outlined,
                label: '② Select Photos',
                color: accentBlue,
              ),
              _buildArrow(),
              _buildStep(
                icon: Icons.save_outlined,
                label: '③ Customize\n& Save',
                color: accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStep({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22.w),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }
  Widget _buildArrow() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Icon(
        Icons.chevron_right_rounded,
        color: textSecondary.withValues(alpha: 0.5),
        size: 20.w,
      ),
    );
  }
  Widget _buildThemes() {
    final themes = [
      ('Wedding', '💍'),
      ('Baby', '👶'),
      ('Travel', '✈️'),
      ('Birthday', '🎂'),
      ('Family', '👨‍👩‍👧'),
      ('Love', '❤️'),
      ('Friends', '👫'),
      ('Corporate', '🏢'),
      ('Graduation', '🎓'),
      ('Pets', '🐾'),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Make albums for every moment',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textBlack,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: themes.length,
              itemBuilder: (_, i) {
                final (name, emoji) = themes[i];
                return GestureDetector(
                  onTap: () => controller.onThemeTap(name),
                  child: Container(
                    margin: EdgeInsets.only(right: 10.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.w),
                      border: Border.all(
                        color: accentBlue.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(emoji, style: TextStyle(fontSize: 14.sp)),
                        SizedBox(width: 5.w),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAlbumTypeCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Start',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textBlack,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTypeCard(
                  title: 'Music Album',
                  desc: 'Photos + music\nwith lyrics subtitles',
                  icon: Icons.music_note_rounded,
                  badge: 'HOT',
                  badgeColor: const Color(0xFFEF4444),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA78BFA), Color(0xFF9F7AEA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: controller.onMusicAlbumTap,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTypeCard(
                  title: 'Photo Story',
                  desc: 'Photos + text\narticle-style album',
                  icon: Icons.article_outlined,
                  badge: 'NEW',
                  badgeColor: const Color(0xFF10B981),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF472B6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: controller.onPhotoTextAlbumTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildTypeCard({
    required String title,
    required String desc,
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 32.w),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRecentAlbums() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Albums',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textBlack,
                ),
              ),
              GestureDetector(
                onTap: controller.onViewAllTap,
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Obx(() {
            if (controller.isLoadingRecent.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.recentAlbums.isEmpty) {
              return _buildEmptyRecent();
            }
            return _buildRecentList();
          }),
        ],
      ),
    );
  }
  Widget _buildRecentList() {
    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.recentAlbums.length,
        itemBuilder: (_, i) {
          final album = controller.recentAlbums[i];
          return _buildRecentCard(album);
        },
      ),
    );
  }
  Widget _buildRecentCard(AlbumEntity album) {
    final typeLabel = album.type == AlbumType.music ? 'Music' : 'Photo Story';
    final typeColor = album.type == AlbumType.music
        ? primaryColor
        : const Color(0xFFF472B6);
    return GestureDetector(
      onTap: () => controller.onRecentAlbumTap(album),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.w),
                topRight: Radius.circular(12.w),
              ),
              child: album.coverPath != null && album.coverPath!.isNotEmpty
                  ? Image.file(
                      File(album.coverPath!),
                      width: 140.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(album.createdAt),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPlaceholder() {
    return Container(
      width: 140.w,
      height: 100.h,
      color: primaryColor.withValues(alpha: 0.1),
      child: Icon(
        Icons.photo_album_outlined,
        size: 36.w,
        color: primaryColor.withValues(alpha: 0.4),
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
  Widget _buildEmptyRecent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: accentBlue.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48.w,
            color: primaryColor.withValues(alpha: 0.4),
          ),
          SizedBox(height: 12.h),
          Text(
            'No albums yet',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Create your first album!',
            style: TextStyle(fontSize: 13.sp, color: textSecondary),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: controller.onCreateAlbumTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                ),
                borderRadius: BorderRadius.circular(20.w),
              ),
              child: Text(
                'Create Now',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _BannerItem {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  const _BannerItem({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
