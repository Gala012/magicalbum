import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'magic_album_photo_text_editor_logic.dart';
class MagicAlbumPhotoTextEditorView
    extends GetView<MagicAlbumPhotoTextEditorLogic> {
  const MagicAlbumPhotoTextEditorView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        title: const Text('Edit'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView(
                children: [
                  _buildCoverSection(),
                  ...List.generate(
                    controller.photoBlocks.length,
                    (i) => _buildPhotoBlock(i),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
          _buildDoneButton(),
        ],
      ),
    );
  }
  Widget _buildCoverSection() {
    return GestureDetector(
      onTap: controller.onTitleTap,
      child: Stack(
        children: [
          Obx(
            () => Container(
              width: double.infinity,
              height: 220.h,
              child: controller.coverPhotoPath.value.isNotEmpty
                  ? Image.file(
                      File(controller.coverPhotoPath.value),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFF9F7AEA),
                      child: Icon(
                        Icons.photo,
                        size: 60.w,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40.h,
            left: 16.w,
            right: 60.w,
            child: Obx(
              () => Text(
                controller.albumTitle.value.isEmpty
                    ? 'Tap to enter article title'
                    : controller.albumTitle.value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: controller.albumTitle.value.isEmpty
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white,
                  shadows: const [Shadow(color: Colors.black38, blurRadius: 4)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12.h,
            right: 12.w,
            child: GestureDetector(
              onTap: controller.onChangeCoverTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_outlined, color: Colors.white, size: 14.w),
                    SizedBox(width: 4.w),
                    Text(
                      'Change Cover',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPhotoBlock(int index) {
    final block = controller.photoBlocks[index];
    final photoPath = block['photoPath'] as String;
    final textController = block['controller'] as TextEditingController;
    final total = controller.photoBlocks.length;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      color: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 40.w, 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.w),
                  child: Image.file(
                    File(photoPath),
                    width: 90.w,
                    height: 90.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 90.w,
                    child: TextField(
                      controller: textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Tap to enter description (optional)',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: textSecondary,
                          height: 1.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: textBlack,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10.h,
            left: 8.w,
            child: GestureDetector(
              onTap: () => controller.onRemoveBlock(index),
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 12.w, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            right: 10.w,
            top: 10.h,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => controller.onMoveUp(index),
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 24.w,
                    color: index == 0
                        ? textSecondary.withValues(alpha: 0.25)
                        : textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: () => controller.onMoveDown(index),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24.w,
                    color: index == total - 1
                        ? textSecondary.withValues(alpha: 0.25)
                        : textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDoneButton() {
    return GestureDetector(
      onTap: controller.onDoneTap,
      child: Container(
        width: double.infinity,
        color: primaryColor,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'Done',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
