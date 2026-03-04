import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../db_magic_album/data.dart';
import '../../db_magic_album/db_magic_album_entity.dart';
import '../../utils/index.dart';
class MagicAlbumPhotoTextEditorLogic extends GetxController {
  final albumTitle = ''.obs;
  final photoBlocks = <Map<String, dynamic>>[].obs;
  final coverPhotoPath = ''.obs;
  final descriptionControllers = <TextEditingController>[].obs;
  final List<String> allPhotoPaths = [];
  final String albumType = Get.arguments?['type'] ?? 'photo_text';
  @override
  void onInit() {
    super.onInit();
    final photos = Get.arguments?['photos'] as List<dynamic>? ?? [];
    allPhotoPaths.addAll(photos.map((p) => p.toString()));
    if (allPhotoPaths.isNotEmpty) {
      coverPhotoPath.value = allPhotoPaths[0];
      photoBlocks.value = allPhotoPaths.map((path) {
        final controller = TextEditingController();
        descriptionControllers.add(controller);
        return <String, dynamic>{
          'photoPath': path,
          'description': '',
          'controller': controller,
        };
      }).toList();
    }
  }
  @override
  void onClose() {
    for (var controller in descriptionControllers) {
      controller.dispose();
    }
    super.onClose();
  }
  void onTitleTap() {
    Get.dialog(_TitleEditDialog(initialTitle: albumTitle.value)).then((result) {
      if (result != null && result is String) {
        albumTitle.value = result;
      }
    });
  }
  void onChangeCoverTap() {
    _showPhotoSelector((selectedPath) {
      coverPhotoPath.value = selectedPath;
    });
  }
  void onRemoveBlock(int index) {
    if (photoBlocks.length <= 1) {
      errorToast('At least 1 photo is required');
      return;
    }
    Get.dialog(
      AlertDialog(
        title: Text('Remove Photo'),
        content: Text('Remove this photo?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              descriptionControllers[index].dispose();
              descriptionControllers.removeAt(index);
              photoBlocks.removeAt(index);
              Get.back();
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }
  void onMoveUp(int index) {
    if (index <= 0) return;
    final block = photoBlocks.removeAt(index);
    photoBlocks.insert(index - 1, block);
    final controller = descriptionControllers.removeAt(index);
    descriptionControllers.insert(index - 1, controller);
  }
  void onMoveDown(int index) {
    if (index >= photoBlocks.length - 1) return;
    final block = photoBlocks.removeAt(index);
    photoBlocks.insert(index + 1, block);
    final controller = descriptionControllers.removeAt(index);
    descriptionControllers.insert(index + 1, controller);
  }
  Future<void> onDoneTap() async {
    if (albumTitle.value.trim().isEmpty) {
      final result = await Get.dialog(
        _TitleEditDialog(initialTitle: albumTitle.value),
      );
      if (result == null || result is! String || result.isEmpty) {
        return;
      }
      albumTitle.value = result;
    }
    if (albumType == 'music') {
      final List<String> photoPaths = [];
      final List<String> subtitles = [];
      for (int i = 0; i < photoBlocks.length; i++) {
        photoPaths.add(photoBlocks[i]['photoPath'] as String);
        subtitles.add(descriptionControllers[i].text.trim());
      }
      Get.offNamed(
        '/magic_music-album-editor',
        arguments: {
          'type': albumType,
          'photos': photoPaths,
          'subtitles': subtitles,
          'title': albumTitle.value,
        },
      );
      return;
    }
    try {
      final List<PhotoBlock> blocks = [];
      for (int i = 0; i < photoBlocks.length; i++) {
        blocks.add(
          PhotoBlock(
            photoPath: photoBlocks[i]['photoPath'] as String,
            description: descriptionControllers[i].text.trim(),
          ),
        );
      }
      final entity = AlbumEntity(
        id: Uuid().v4(),
        title: albumTitle.value,
        type: AlbumType.photoText,
        coverPath: coverPhotoPath.value,
        photoCount: blocks.length,
        photoBlocks: blocks,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await AlbumDatabase.instance.insert(entity);
      successToast('Album saved');
      Get.offNamed('/magic_photo-text-album-preview', arguments: {'albumId': entity.id});
    } catch (e) {
      errorToast('Save failed, please try again');
    }
  }
  void _showPhotoSelector(Function(String) onSelected) {
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
                  'Select Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 400),
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: allPhotoPaths.length,
                    itemBuilder: (context, index) {
                      final path = allPhotoPaths[index];
                      return GestureDetector(
                        onTap: () {
                          onSelected(path);
                          Get.back();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(path), fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _TitleEditDialog extends StatefulWidget {
  final String initialTitle;
  const _TitleEditDialog({required this.initialTitle});
  @override
  State<_TitleEditDialog> createState() => _TitleEditDialogState();
}
class _TitleEditDialogState extends State<_TitleEditDialog> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Album Title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLength: 50,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'My Magic Album',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final title = _controller.text.trim();
                    if (title.isEmpty) {
                      errorToast('Please enter album title');
                      return;
                    }
                    Get.back(result: title);
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
