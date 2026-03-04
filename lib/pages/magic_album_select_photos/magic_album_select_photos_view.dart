import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../main.dart';
import 'magic_album_select_photos_logic.dart';
class MagicAlbumSelectPhotosView extends GetView<MagicAlbumSelectPhotosLogic> {
  const MagicAlbumSelectPhotosView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildPhotoGrid()),
          _buildBottomPreview(),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: Get.back,
      ),
      title: Obx(
        () => GestureDetector(
          onTap: controller.showAlbumPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.selectedAlbum.value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textBlack,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.arrow_drop_down, color: textBlack, size: 20.w),
            ],
          ),
        ),
      ),
      actions: [
        Obx(
          () => GestureDetector(
            onTap: controller.onDoneTap,
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: controller.selectedPhotos.isNotEmpty
                    ? primaryColor
                    : primaryColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18.h),
              ),
              child: Text(
                'Done (${controller.selectedPhotos.length}/${MagicAlbumSelectPhotosLogic.maxPhotos})',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildPhotoGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      final groupedPhotos = controller.groupPhotosByDate();
      final sortedKeys = groupedPhotos.keys.toList();
      return ListView.builder(
        padding: EdgeInsets.only(bottom: 8.h),
        itemCount: sortedKeys.length,
        itemBuilder: (_, groupIndex) {
          final date = sortedKeys[groupIndex];
          final photos = groupedPhotos[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: textBlack,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.w,
                  childAspectRatio: 1,
                ),
                itemCount: photos.length,
                itemBuilder: (_, i) => _buildPhotoItem(photos[i]),
              ),
            ],
          );
        },
      );
    });
  }
  Widget _buildPhotoItem(AssetEntity photo) {
    return Obx(() {
      final isSelected = controller.isSelected(photo);
      final order = isSelected ? controller.getPhotoOrder(photo) : 0;
      return GestureDetector(
        onTap: () => controller.onPhotoTap(photo),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AssetEntityImage(
              photo,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(200),
              fit: BoxFit.cover,
            ),
            if (isSelected)
              Container(color: Colors.black.withValues(alpha: 0.25)),
            if (isSelected)
              Positioned(
                top: 5.h,
                right: 5.w,
                child: Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$order',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (!isSelected)
              Positioned(
                top: 5.h,
                right: 5.w,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
  Widget _buildBottomPreview() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SafeArea(
            bottom: false,
            child: controller.selectedPhotos.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: Center(
                      child: Text(
                        'Tap photos to select',
                        style: TextStyle(fontSize: 13.sp, color: textSecondary),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 86.h,
                        child: ReorderableListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          itemCount: controller.selectedPhotos.length,
                          onReorder: controller.reorderPhotos,
                          itemBuilder: (_, i) {
                            final photo = controller.selectedPhotos[i];
                            return Container(
                              key: ValueKey(photo.id),
                              width: 66.w,
                              margin: EdgeInsets.only(right: 8.w),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.w),
                                    child: AssetEntityImage(
                                      photo,
                                      isOriginal: false,
                                      thumbnailSize: const ThumbnailSize.square(
                                        200,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.onRemovePhoto(photo),
                                      child: Container(
                                        width: 18.w,
                                        height: 18.w,
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 11.w,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 14.w,
                          right: 14.w,
                          bottom: 8.h,
                        ),
                        child: Text(
                          'You\'ve selected ${controller.selectedPhotos.length} photos, hold to reorder',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
