import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../db_magic_album/db_magic_album_entity.dart';
import '../../main.dart';
import 'magic_album_photo_text_preview_logic.dart';
class MagicAlbumPhotoTextPreviewView
    extends GetView<MagicAlbumPhotoTextPreviewLogic> {
  const MagicAlbumPhotoTextPreviewView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: controller.templateBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                controller.contentGradientStartColor,
                controller.contentGradientEndColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(),
            body: Stack(
              children: [
                _buildContent(),
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: Obx(() {
                    final name = controller.currentMusicName.value;
                    if (name.isEmpty) return const SizedBox.shrink();
                    return RotationTransition(
                      turns: controller.rotationController,
                      child: GestureDetector(
                        onTap: controller.onToggleMusic,
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            controller.isPlaying.value
                                ? Icons.music_note
                                : Icons.music_note_outlined,
                            color: controller.templatePrimaryColor,
                            size: 24.w,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Obx(() {
                  final panel = controller.currentPanel.value;
                  if (panel != null) {
                    return GestureDetector(
                      onTap: controller.onClosePanel,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: GestureDetector(
                          onTap: () {},
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: _buildPanel(panel),
                          ),
                        ),
                      ),
                    );
                  }
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomToolbar(),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: Get.back,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.until((r) => r.isFirst),
          ),
        ],
      ),
      leadingWidth: 100.w,
      title: const Text('Magic Album'),
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                final box = context.findRenderObject() as RenderBox?;
                final sharePositionOrigin = box == null
                    ? null
                    : box.localToGlobal(Offset.zero) & box.size;
                controller.onSystemShareTap(
                  sharePositionOrigin: sharePositionOrigin,
                );
              },
            );
          },
        ),
      ],
    );
  }
  Widget _buildTemplateHeader(BuildContext context) {
    return Obx(() {
      final template = controller.currentTemplate;
      if (template == null) return const SizedBox.shrink();
      final screenHeight = MediaQuery.of(context).size.height;
      final headerHeight = screenHeight / 3;
      return SizedBox(
        height: headerHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/templates/${template.filename}',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 100.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      controller.contentGradientStartColor,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24.h,
              child: _buildTitleOverlay(),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildTitleOverlay() {
    return Obx(() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.w),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.albumTitle.value.isEmpty
                      ? 'My Magic Album'
                      : controller.albumTitle.value,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 50.w,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14.w,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      controller.currentDate.value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Icon(
                      Icons.visibility_rounded,
                      size: 14.w,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${controller.viewCount.value} views',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  Widget _buildContent() {
    return Builder(
      builder: (context) {
        return Obx(() {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildTemplateHeader(context),
              SizedBox(height: 16.h),
              ...controller.photoBlocks.map(
                (block) => _buildContentBlock(block),
              ),
              SizedBox(height: 80.h),
            ],
          );
        });
      },
    );
  }
  Widget _buildContentBlock(PhotoBlock block) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.w),
            child: SizedBox(
              width: double.infinity,
              height: 220.h,
              child:
                  block.photoPath.isNotEmpty &&
                      File(block.photoPath).existsSync()
                  ? Image.file(
                      File(block.photoPath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48.w,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
            ),
          ),
          if (block.description.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
              child: Text(
                block.description,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: controller.templateContentTextColor,
                  height: 1.7,
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildBottomToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolItem(
                icon: Icons.dashboard_outlined,
                label: 'Template',
                onTap: controller.onTemplateTap,
              ),
              _buildToolItem(
                icon: Icons.music_note_outlined,
                label: 'Music',
                onTap: controller.onMusicTap,
              ),
              _buildToolItem(
                icon: Icons.edit_outlined,
                label: 'Rename',
                onTap: controller.onRenameAlbumTap,
              ),
              _buildToolItem(
                icon: Icons.save_outlined,
                label: 'Save',
                onTap: controller.onSaveAlbumTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildToolItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.w, color: textPrimary),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: textPrimary),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPanel(String panelType) {
    switch (panelType) {
      case 'template':
        return _buildTemplatePanel();
      case 'music':
        return _buildMusicPanel();
      case 'more':
        return _buildMorePanel();
      case 'share':
        return _buildSharePanel();
      default:
        return const SizedBox.shrink();
    }
  }
  Widget _buildPanelBase({required List<Widget> children, double? height}) {
    return Container(
      height: height ?? 320.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
  Widget _buildMorePanel() {
    return _buildPanelBase(
      height: 240.h,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'More Options',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textBlack,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        _buildMoreItem(
          icon: Icons.edit_outlined,
          label: 'Edit Content',
          onTap: controller.onEditContentTap,
        ),
        _buildMoreItem(
          icon: Icons.drive_file_rename_outline,
          label: 'Rename Album',
          onTap: controller.onRenameAlbumTap,
        ),
        _buildMoreItem(
          icon: Icons.save_outlined,
          label: 'Save Album',
          onTap: controller.onSaveAlbumTap,
        ),
        _buildMoreItem(
          icon: Icons.close,
          label: 'Cancel',
          onTap: controller.onClosePanel,
          color: textSecondary,
        ),
      ],
    );
  }
  Widget _buildMoreItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: color ?? textPrimary),
            SizedBox(width: 14.w),
            Text(
              label,
              style: TextStyle(fontSize: 15.sp, color: color ?? textBlack),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSharePanel() {
    return _buildPanelBase(
      height: 200.h,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Share',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textBlack,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        _buildMoreItem(
          icon: Icons.photo_library_outlined,
          label: 'Save Images to Gallery',
          onTap: controller.onSaveImagesToGallery,
        ),
        Builder(
          builder: (context) {
            return _buildMoreItem(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () {
                final box = context.findRenderObject() as RenderBox?;
                final sharePositionOrigin = box == null
                    ? null
                    : box.localToGlobal(Offset.zero) & box.size;
                controller.onSystemShareTap(
                  sharePositionOrigin: sharePositionOrigin,
                );
              },
            );
          },
        ),
      ],
    );
  }
  Widget _buildTemplatePanel() {
    return Container(
      height: 480.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 90.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
              ),
            ),
            child: Obx(() {
              final selectedCategory =
                  controller.selectedTemplateCategory.value;
              return ListView.builder(
                itemCount: controller.templateCategories.length,
                itemBuilder: (_, i) {
                  final isSelected = selectedCategory == i;
                  return GestureDetector(
                    onTap: () => controller.onTemplateCategoryTap(i),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: isSelected
                            ? Border(
                                left: BorderSide(color: primaryColor, width: 3),
                              )
                            : null,
                      ),
                      child: Text(
                        controller.templateCategories[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? primaryColor : textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Obx(
                    () => GridView.builder(
                      padding: EdgeInsets.all(10.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.w,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: controller.filteredTemplates.length,
                      itemBuilder: (_, i) {
                        final template = controller.filteredTemplates[i];
                        final isSelected =
                            controller.selectedTemplateId.value == template.id;
                        return GestureDetector(
                          onTap: () => controller.onTemplateSelect(template.id),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.w),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9.w),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/templates/${template.filename}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: _getColor(i),
                                      child: Center(
                                        child: Icon(
                                          Icons.photo_album,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          size: 36.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      child: Text(
                                        template.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 6.w,
                                      right: 6.w,
                                      child: Container(
                                        width: 20.w,
                                        height: 20.w,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 13.w,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: GestureDetector(
                      onTap: controller.onClosePanel,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15.sp, color: textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Color _getColor(int index) {
    const colors = [
      Color(0xFFEF4444),
      Color(0xFFF97316),
      Color(0xFF8B5CF6),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF6366F1),
      Color(0xFF14B8A6),
      Color(0xFF84CC16),
      Color(0xFF0EA5E9),
      Color(0xFFA855F7),
    ];
    return colors[index % colors.length];
  }
  Widget _buildMusicPanel() {
    return Container(
      height: 420.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                _buildMusicTabItem('My Music', 0),
                _buildMusicTabItem('Search Music', 1),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => controller.selectedMusicTab.value == 0
                  ? _buildMyMusicList()
                  : _buildSearchMusic(),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.onClosePanel,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15.sp, color: textPrimary),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.onClosePanel,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                          ),
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Text(
                          'Done',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMusicTabItem(String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedMusicTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.onMusicTabChange(index),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                color: isSelected ? primaryColor : textSecondary,
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _buildMyMusicList() {
    return Obx(() {
      final list = controller.displayMusicItems;
      if (list.isEmpty) {
        return Center(
          child: Text(
            'No music available',
            style: TextStyle(fontSize: 14.sp, color: textSecondary),
          ),
        );
      }
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          final music = list[i];
          final isSelected = controller.selectedMusicId.value == music.id;
          return GestureDetector(
            onTap: () => controller.onMusicSelect(music),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_outline,
                    color: isSelected ? primaryColor : textSecondary,
                    size: 28.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          music.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isSelected ? primaryColor : textBlack,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          music.artist,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: _genreColor(music.genre).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Text(
                      music.genre,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: _genreColor(music.genre),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
  Color _genreColor(String genre) {
    switch (genre) {
      case 'romantic':
        return const Color(0xFFEC4899);
      case 'happy':
        return const Color(0xFFF59E0B);
      case 'epic':
        return const Color(0xFF8B5CF6);
      case 'folk':
        return const Color(0xFF10B981);
      case 'electronic':
        return const Color(0xFF3B82F6);
      case 'calm':
        return const Color(0xFF6366F1);
      default:
        return textSecondary;
    }
  }
  Widget _buildSearchMusic() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: TextField(
              controller: controller.musicSearchController,
              onChanged: controller.onSearchMusic,
              decoration: InputDecoration(
                hintText: 'Search for music...',
                hintStyle: TextStyle(fontSize: 14.sp, color: textSecondary),
                prefixIcon: Icon(
                  Icons.search,
                  color: textSecondary,
                  size: 20.w,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              final results = controller.searchMusicResults;
              final query = controller.musicSearchQuery.value;
              if (query.isEmpty) {
                return Center(
                  child: Text(
                    'Search for songs by name or artist',
                    style: TextStyle(fontSize: 14.sp, color: textSecondary),
                  ),
                );
              }
              if (results.isEmpty) {
                return Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(fontSize: 14.sp, color: textSecondary),
                  ),
                );
              }
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final music = results[i];
                  final isSelected =
                      controller.selectedMusicId.value == music.id;
                  return GestureDetector(
                    onTap: () => controller.onMusicSelect(music),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_outline,
                            color: isSelected ? primaryColor : textSecondary,
                            size: 28.w,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  music.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isSelected
                                        ? primaryColor
                                        : textBlack,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  music.artist,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
