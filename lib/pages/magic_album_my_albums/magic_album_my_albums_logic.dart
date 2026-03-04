import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_magic_album/data.dart';
import '../../db_magic_album/db_magic_album_entity.dart';
import '../../utils/index.dart';
class MagicAlbumMyAlbumsLogic extends GetxController {
  final selectedFilter = 0.obs;
  final albumList = <AlbumEntity>[].obs;
  final isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    loadAlbums();
  }
  Future<void> loadAlbums() async {
    try {
      isLoading.value = true;
      if (selectedFilter.value == 0) {
        albumList.value = await AlbumDatabase.instance.queryAll();
      } else if (selectedFilter.value == 1) {
        albumList.value =
            await AlbumDatabase.instance.queryByType(AlbumType.music);
      } else {
        albumList.value =
            await AlbumDatabase.instance.queryByType(AlbumType.photoText);
      }
    } catch (e) {
      errorToast('Failed to load albums');
    } finally {
      isLoading.value = false;
    }
  }
  void onFilterChange(int index) {
    selectedFilter.value = index;
    loadAlbums();
  }
  void onAlbumTap(AlbumEntity album) {
    if (album.type == AlbumType.music) {
      Get.toNamed('/magic_music-album-editor', arguments: {'albumId': album.id});
    } else {
      Get.toNamed('/magic_photo-text-album-preview', arguments: {'albumId': album.id});
    }
  }
  void onEditAlbum(AlbumEntity album) {
    if (album.type == AlbumType.music) {
      Get.toNamed('/magic_music-album-editor', arguments: {'albumId': album.id});
    } else {
      Get.toNamed('/magic_photo-text-album-editor', arguments: {'albumId': album.id});
    }
  }
  void onRenameAlbum(AlbumEntity album) {
    final controller = TextEditingController(text: album.title);
    Get.dialog(
      AlertDialog(
        title: const Text('Rename Album'),
        content: TextField(
          controller: controller,
          maxLength: 50,
          decoration: const InputDecoration(
            hintText: 'Enter album name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isEmpty) {
                errorToast('Album name cannot be empty');
                return;
              }
              Get.back();
              await _saveNewTitle(album.id, newTitle);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  Future<void> _saveNewTitle(String albumId, String newTitle) async {
    try {
      await AlbumDatabase.instance.updateTitle(albumId, newTitle);
      successToast('Album renamed successfully');
      await loadAlbums();
    } catch (e) {
      errorToast('Failed to rename album');
    }
  }
  void onDeleteAlbum(AlbumEntity album) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Album'),
        content:
            const Text('Delete this album? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performDelete(album.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  Future<void> _performDelete(String albumId) async {
    try {
      await AlbumDatabase.instance.delete(albumId);
      successToast('Album deleted successfully');
      await loadAlbums();
    } catch (e) {
      errorToast('Failed to delete album');
    }
  }
  void onCreateNowTap() {
    Get.toNamed('/magic_select-photos');
  }
  void showAlbumMenu(BuildContext context, AlbumEntity album) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Get.back();
                onEditAlbum(album);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Rename'),
              onTap: () {
                Get.back();
                onRenameAlbum(album);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                onDeleteAlbum(album);
              },
            ),
          ],
        ),
      ),
    );
  }
}
