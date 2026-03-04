import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'magic_album_music_editor_logic.dart';
class MagicAlbumMusicEditorView extends GetView<MagicAlbumMusicEditorLogic> {
  const MagicAlbumMusicEditorView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildPreviewArea(),
          Obx(() {
            if (controller.currentPanel.value != null) {
              return GestureDetector(
                onTap: controller.onClosePanel,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              );
            }
            return const SizedBox.shrink();
          }),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(() {
              if (controller.currentPanel.value != null) {
                return GestureDetector(
                  onTap: () {},
                  child: _buildPanel(controller.currentPanel.value!),
                );
              }
              return _buildBottomToolbar();
            }),
          ),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: Get.back,
      ),
      title: Obx(
        () => GestureDetector(
          onTap: controller.onRenameAlbumTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  controller.albumName.value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.edit_outlined, color: Colors.white70, size: 14.w),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPreviewArea() {
    return Obx(() {
      final template = controller.currentTemplate;
      final photoList = controller.photos;
      final currentIndex = controller.currentPhotoIndex.value;
      final subtitle = controller.currentSubtitle;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (template != null)
            Positioned.fill(
              child: Image.asset(
                'assets/templates/${template.filename}',
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, s) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1E1B2E),
                        Color(0xFF2D1B69),
                        Color(0xFF1E1B2E),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E1B2E),
                    Color(0xFF2D1B69),
                    Color(0xFF1E1B2E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.15)),
          ),
          if (photoList.isNotEmpty && currentIndex < photoList.length)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: Center(
                key: ValueKey<int>(currentIndex),
                child: Container(
                  width: 290.w,
                  height: 380.h,
                  margin: EdgeInsets.only(top: 60.h, bottom: 120.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: -5,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.w),
                        child: Image.file(
                          File(photoList[currentIndex]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (ctx, e, s) => _buildPhotoPlaceholder(),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.w),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Center(
              child: Container(
                width: 290.w,
                height: 380.h,
                margin: EdgeInsets.only(top: 60.h, bottom: 120.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.w),
                  child: _buildPhotoPlaceholder(),
                ),
              ),
            ),
          if (subtitle.isNotEmpty)
            Positioned(
              bottom: 170.h,
              left: 30.w,
              right: 30.w,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<String>(subtitle),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16.w),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 100.h,
            right: 16.w,
            child: Obx(() {
              final name = controller.currentMusicName.value;
              if (name.isEmpty) return const SizedBox.shrink();
              return RotationTransition(
                turns: controller.rotationController,
                child: GestureDetector(
                  onTap: controller.onTogglePlay,
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.isPlaying.value
                          ? Icons.music_note
                          : Icons.music_note_outlined,
                      color: const Color(0xFFA78BFA),
                      size: 22.w,
                    ),
                  ),
                ),
              );
            }),
          ),
          Positioned(
            bottom: 100.h,
            left: 0,
            right: 0,
            child: Obx(() {
              final name = controller.currentMusicName.value;
              if (name.isEmpty) return const SizedBox.shrink();
              return Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.music_note, color: Colors.white70, size: 14.w),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }
  Widget _buildPhotoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.6),
            accentColor.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.photo,
          size: 80.w,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
  Widget _buildBottomToolbar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToolBtn(
              icon: Icons.dashboard_outlined,
              label: 'Template',
              onTap: controller.onTemplateTap,
            ),
            _buildToolBtn(
              icon: Icons.music_note_outlined,
              label: 'Music',
              onTap: controller.onMusicTap,
            ),
            _buildToolBtn(
              icon: Icons.edit_outlined,
              label: 'Edit',
              onTap: controller.onEditTap,
            ),
            _buildSaveBtn(),
          ],
        ),
      ),
    );
  }
  Widget _buildToolBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16.w),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSaveBtn() {
    return GestureDetector(
      onTap: controller.onSaveTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
          ),
          borderRadius: BorderRadius.circular(20.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.save_outlined, color: Colors.white, size: 16.w),
            SizedBox(width: 4.w),
            Text(
              'Save',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
      case 'edit':
        return _buildEditPanel();
      default:
        return const SizedBox.shrink();
    }
  }
  Widget _buildPanelContainer({required Widget child, double? height}) {
    return Container(
      height: height ?? 480.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: child,
    );
  }
  Widget _buildTemplatePanel() {
    return _buildPanelContainer(
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
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: controller.templateCategories.length,
              itemBuilder: (_, i) {
                return Obx(() {
                  final isSelected =
                      controller.selectedTemplateCategory.value == i;
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
                });
              },
            ),
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9.w),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/templates/${template.filename}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, e, s) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getTemplateColor(i),
                                            _getTemplateColor(
                                              i,
                                            ).withValues(alpha: 0.6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 6.h,
                                      ),
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      child: Text(
                                        template.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 6.h,
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
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
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
  Color _getTemplateColor(int index) {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFF97316),
      const Color(0xFF8B5CF6),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
      const Color(0xFF14B8A6),
      const Color(0xFF84CC16),
      const Color(0xFF0EA5E9),
      const Color(0xFFA855F7),
    ];
    return colors[index % colors.length];
  }
  Widget _buildMusicPanel() {
    return _buildPanelContainer(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                _buildMusicTab('My Music', 0),
                _buildMusicTab('Search Music', 1),
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
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.onConfirmMusic,
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
  Widget _buildMusicTab(String label, int index) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
          child: Text(
            'Select music to use',
            style: TextStyle(fontSize: 13.sp, color: textSecondary),
          ),
        ),
        Expanded(
          child: Obx(
            () => controller.displayMusicItems.isEmpty
                ? Center(
                    child: Text(
                      'No music available',
                      style: TextStyle(fontSize: 14.sp, color: textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.displayMusicItems.length,
                    itemBuilder: (_, i) {
                      final music = controller.displayMusicItems[i];
                      final isSelected =
                          controller.selectedMusicId.value == music.id;
                      return GestureDetector(
                        onTap: () => controller.onMusicSelect(music),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_outline,
                                color: isSelected
                                    ? primaryColor
                                    : textSecondary,
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
                                  color: _genreColor(
                                    music.genre,
                                  ).withValues(alpha: 0.12),
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
                  ),
          ),
        ),
      ],
    );
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
              final query = controller.musicSearchQuery.value;
              final results = controller.searchMusicResults;
              if (query.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 48.w,
                        color: textSecondary.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Search for songs by name or artist',
                        style: TextStyle(fontSize: 14.sp, color: textSecondary),
                      ),
                    ],
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
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
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
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: _genreColor(
                                music.genre,
                              ).withValues(alpha: 0.12),
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
            }),
          ),
        ],
      ),
    );
  }
  Widget _buildEditPanel() {
    return _buildPanelContainer(
      height: 520.h,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                _buildEditTab('Photos', 0),
                _buildEditTab('Subtitles', 1),
                _buildEditTab('Settings', 2),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedEditTab.value) {
                case 0:
                  return _buildPhotosTab();
                case 1:
                  return _buildSubtitlesTab();
                case 2:
                  return _buildSettingsTab();
                default:
                  return _buildPhotosTab();
              }
            }),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.onAddPhotosTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Text(
                          'Add Photos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
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
  Widget _buildEditTab(String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedEditTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.onEditTabChange(index),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
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
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                color: isSelected ? primaryColor : textSecondary,
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _buildPhotosTab() {
    return Obx(() {
      final photoList = controller.photos;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
            child: Text(
              'Total ${photoList.length} photos: tap arrows to reorder',
              style: TextStyle(fontSize: 13.sp, color: textSecondary),
            ),
          ),
          SizedBox(
            height: 130.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              itemCount: photoList.length + 1,
              itemBuilder: (_, i) {
                if (i == photoList.length) {
                  return GestureDetector(
                    onTap: controller.onAddPhotosTap,
                    child: Container(
                      width: 100.w,
                      margin: EdgeInsets.only(left: 8.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10.w),
                        color: primaryColor.withValues(alpha: 0.05),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: primaryColor, size: 28.w),
                          SizedBox(height: 4.h),
                          Text(
                            'Add Photos',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Container(
                      width: 100.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.w),
                        child: Image.file(
                          File(photoList[i]),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, e, s) => Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey.shade500,
                              size: 28.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6.h,
                      left: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: i == 0
                              ? primaryColor
                              : Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: Text(
                          i == 0 ? 'Cover' : '${i + 1}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6.h,
                      left: 0,
                      right: 8.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => controller.onMovePhotoUp(i),
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 10.w,
                                color: i == 0 ? Colors.white30 : Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => controller.onMovePhotoDown(i),
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10.w,
                                color: i == photoList.length - 1
                                    ? Colors.white30
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    });
  }
  Widget _buildSubtitlesTab() {
    return Obx(() {
      final photoList = controller.photos;
      if (photoList.isEmpty) {
        return Center(
          child: Text(
            'No photos added yet',
            style: TextStyle(fontSize: 14.sp, color: textSecondary),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: photoList.length,
        itemBuilder: (_, i) {
          final total = photoList.length;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.w),
                      child: SizedBox(
                        width: 70.w,
                        height: 70.h,
                        child: Image.file(
                          File(photoList[i]),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, e, s) => Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey.shade500,
                              size: 24.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      left: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: i == 0
                              ? primaryColor
                              : Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: Text(
                          i == 0 ? 'Cover' : '${i + 1}',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    height: 70.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.w),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: controller.subtitleControllers.length > i
                          ? controller.subtitleControllers[i]
                          : null,
                      maxLength: 30,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Tap to add subtitle (max 30 chars)',
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: textSecondary,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      style: TextStyle(fontSize: 13.sp, color: textBlack),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => controller.onMovePhotoUp(i),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 22.w,
                        color: i == 0
                            ? textSecondary.withValues(alpha: 0.3)
                            : textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.onMovePhotoDown(i),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22.w,
                        color: i == total - 1
                            ? textSecondary.withValues(alpha: 0.3)
                            : textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
  Widget _buildSettingsTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildSettingRow(
            label: 'Album Name',
            child: Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: TextField(
                        controller: controller.albumNameController,
                        maxLength: 50,
                        decoration: InputDecoration(
                          hintText: 'My Magic Album',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: textSecondary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 14.sp, color: textBlack),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: controller.onAlbumNameSave,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildSettingRow(
            label: 'Duration (sec)',
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.frameDuration.value > 1) {
                      controller.frameDuration.value--;
                    }
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: const Icon(Icons.remove, size: 18),
                  ),
                ),
                SizedBox(width: 12.w),
                Obx(
                  () => Text(
                    '${controller.frameDuration.value}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: textBlack,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () => controller.frameDuration.value++,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop Playback',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: textBlack,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Obx(
                () => Switch(
                  value: controller.loopPlay.value,
                  onChanged: (v) => controller.loopPlay.value = v,
                  activeTrackColor: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSettingRow({required String label, required Widget child}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            color: textBlack,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 12.w),
        child,
      ],
    );
  }
}
