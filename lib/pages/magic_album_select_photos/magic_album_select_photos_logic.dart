import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../utils/index.dart';
class MagicAlbumSelectPhotosLogic extends GetxController {
  final selectedAlbum = 'All'.obs;
  final selectedPhotos = <AssetEntity>[].obs;
  final albums = <AssetPathEntity>[].obs;
  final currentPhotos = <AssetEntity>[].obs;
  final isLoading = true.obs;
  final String albumType = Get.arguments?['type'] ?? 'music';
  static const int maxPhotos = 20;
  @override
  void onInit() {
    super.onInit();
    requestPermissionAndLoadPhotos();
  }
  Future<void> requestPermissionAndLoadPhotos() async {
    try {
      isLoading.value = true;
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth) {
        await loadAlbums();
      } else if (ps.hasAccess) {
        await loadAlbums();
      } else {
        errorToast('Photos permission is required');
        Get.back();
      }
    } catch (e) {
      errorToast('Failed to load photos: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> loadAlbums() async {
    try {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: false,
      );
      albums.value = paths;
      if (paths.isNotEmpty) {
        await switchAlbum(paths[0]);
      }
    } catch (e) {
      errorToast('Failed to load albums: $e');
    }
  }
  Future<void> switchAlbum(AssetPathEntity album) async {
    try {
      selectedAlbum.value = album.name;
      final List<AssetEntity> assets = await album.getAssetListRange(
        start: 0,
        end: 1000,
      );
      currentPhotos.value = assets;
    } catch (e) {
      errorToast('Failed to switch album: $e');
    }
  }
  void showAlbumPicker() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Album',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return ListTile(
                      title: Text(album.name),
                      trailing: selectedAlbum.value == album.name
                          ? Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        switchAlbum(album);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Map<String, List<AssetEntity>> groupPhotosByDate() {
    final Map<String, List<AssetEntity>> grouped = {};
    for (var photo in currentPhotos) {
      final date = photo.createDateTime;
      final now = DateTime.now();
      String dateKey;
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dateKey = 'Today';
      } else {
        dateKey = '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      }
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(photo);
    }
    return grouped;
  }
  void reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = selectedPhotos.removeAt(oldIndex);
    selectedPhotos.insert(newIndex, item);
  }
  void onPhotoTap(AssetEntity photo) {
    if (selectedPhotos.contains(photo)) {
      selectedPhotos.remove(photo);
    } else {
      if (selectedPhotos.length >= maxPhotos) {
        errorToast('Maximum 20 photos allowed');
        return;
      }
      selectedPhotos.add(photo);
    }
  }
  void onRemovePhoto(AssetEntity photo) {
    selectedPhotos.remove(photo);
  }
  bool isSelected(AssetEntity photo) => selectedPhotos.contains(photo);
  int getPhotoOrder(AssetEntity photo) => selectedPhotos.indexOf(photo) + 1;
  Future<void> onDoneTap() async {
    if (selectedPhotos.isEmpty) return;
    try {
      final List<String> photoPaths = [];
      for (var asset in selectedPhotos) {
        final file = await asset.file;
        if (file != null) {
          photoPaths.add(file.path);
        }
      }
      Get.toNamed(
        '/magic_photo-text-album-editor',
        arguments: {'type': albumType, 'photos': photoPaths},
      );
    } catch (e) {
      errorToast('Failed to process photos: $e');
    }
  }
}
