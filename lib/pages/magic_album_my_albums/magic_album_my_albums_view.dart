import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../db_magic_album/db_magic_album_entity.dart';
import '../../main.dart';
import 'magic_album_my_albums_logic.dart';
class MagicAlbumMyAlbumsView extends GetView<MagicAlbumMyAlbumsLogic> {
  const MagicAlbumMyAlbumsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Albums'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.albumList.isEmpty) {
                return _buildEmptyState();
              }
              return _buildAlbumList();
            }),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterBar() {
    const filters = ['All', 'Music', 'Photo Story'];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Obx(
        () => Row(
          children: List.generate(
            filters.length,
            (i) => GestureDetector(
              onTap: () => controller.onFilterChange(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: controller.selectedFilter.value == i
                      ? primaryColor
                      : const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: Text(
                  filters[i],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: controller.selectedFilter.value == i
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: controller.selectedFilter.value == i
                        ? Colors.white
                        : textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAlbumList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.albumList.length,
      itemBuilder: (context, index) {
        final album = controller.albumList[index];
        return _buildAlbumCard(album);
      },
    );
  }
  Widget _buildAlbumCard(AlbumEntity album) {
    final typeLabel = album.type == AlbumType.music ? 'Music' : 'Photo Story';
    final typeColor =
        album.type == AlbumType.music ? primaryColor : const Color(0xFFF472B6);
    return GestureDetector(
      onTap: () => controller.onAlbumTap(album),
      onLongPress: () => controller.showAlbumMenu(Get.context!, album),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.w),
                bottomLeft: Radius.circular(14.w),
              ),
              child: album.coverPath != null && album.coverPath!.isNotEmpty
                  ? Image.file(
                      File(album.coverPath!),
                      width: 100.w,
                      height: 100.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                    )
                  : _buildPlaceholderCover(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            album.title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: textBlack,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.photo_outlined,
                          size: 14.w,
                          color: textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${album.photoCount} photo${album.photoCount != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.w,
                          color: textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatDate(album.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
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
  Widget _buildPlaceholderCover() {
    return Container(
      width: 100.w,
      height: 100.w,
      color: primaryColor.withValues(alpha: 0.1),
      child: Icon(
        Icons.photo_album_outlined,
        size: 40.w,
        color: primaryColor.withValues(alpha: 0.4),
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_album_outlined,
              size: 50.w,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No albums yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start creating your first album!',
            style: TextStyle(fontSize: 14.sp, color: textSecondary),
          ),
          SizedBox(height: 28.h),
          GestureDetector(
            onTap: controller.onCreateNowTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                ),
                borderRadius: BorderRadius.circular(26.h),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Create Now',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
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
