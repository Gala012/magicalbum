import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:uuid/uuid.dart';
import '../../db_magic_album/data.dart';
import '../../db_magic_album/db_magic_album_entity.dart' as db;
import '../../utils/index.dart';
class TemplateItem {
  final String id;
  final String category;
  final String filename;
  final String name;
  final String primaryColor;
  final String backgroundColor;
  final String? backgroundGradientStart;
  final String? backgroundGradientEnd;
  final String titleColor;
  final String contentTextColor;
  final String accentColor;
  final String? contentGradientStart;
  final String? contentGradientEnd;
  const TemplateItem({
    required this.id,
    required this.category,
    required this.filename,
    required this.name,
    required this.primaryColor,
    required this.backgroundColor,
    this.backgroundGradientStart,
    this.backgroundGradientEnd,
    required this.titleColor,
    required this.contentTextColor,
    required this.accentColor,
    this.contentGradientStart,
    this.contentGradientEnd,
  });
  factory TemplateItem.fromJson(Map<String, dynamic> json) => TemplateItem(
    id: json['id'] as String,
    category: json['category'] as String,
    filename: json['filename'] as String,
    name: json['name'] as String,
    primaryColor: json['primaryColor'] as String? ?? '#8B5CF6',
    backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
    backgroundGradientStart: json['backgroundGradientStart'] as String?,
    backgroundGradientEnd: json['backgroundGradientEnd'] as String?,
    titleColor: json['titleColor'] as String? ?? '#1F2937',
    contentTextColor: json['contentTextColor'] as String? ?? '#1F2937',
    accentColor: json['accentColor'] as String? ?? '#8B5CF6',
    contentGradientStart: json['contentGradientStart'] as String?,
    contentGradientEnd: json['contentGradientEnd'] as String?,
  );
}
class MusicItem {
  final String id;
  final String filename;
  final String name;
  final String artist;
  final String genre;
  const MusicItem({
    required this.id,
    required this.filename,
    required this.name,
    required this.artist,
    required this.genre,
  });
  factory MusicItem.fromJson(Map<String, dynamic> json) => MusicItem(
    id: json['id'] as String,
    filename: json['filename'] as String,
    name: json['name'] as String,
    artist: json['artist'] as String,
    genre: json['genre'] as String,
  );
}
class MagicAlbumMusicEditorLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController rotationController;
  final albumName = 'My Magic Album'.obs;
  String? albumId;
  final isPlaying = false.obs;
  final currentMusicName = ''.obs;
  final currentPhotoIndex = 0.obs;
  Timer? _carouselTimer;
  final currentPanel = Rx<String?>(null);
  final templateCategories = const [
    'All',
    'Holiday',
    'Elegant',
    '3D',
    'Trendy',
    'Interactive',
    'Memorial',
    'Travel',
    'Romance',
    'Baby',
    'Minimal',
    'Classic',
    'Legacy',
  ];
  final allTemplates = <TemplateItem>[].obs;
  final filteredTemplates = <TemplateItem>[].obs;
  final selectedTemplateCategory = 0.obs;
  final selectedTemplateId = ''.obs;
  final selectedMusicTab = 0.obs;
  final selectedMusicId = ''.obs;
  final allMusicItems = <MusicItem>[].obs;
  final displayMusicItems = <MusicItem>[].obs;
  final searchMusicResults = <MusicItem>[].obs;
  final musicSearchQuery = ''.obs;
  final musicSearchController = TextEditingController();
  final _audioPlayer = AudioPlayer();
  final selectedEditTab = 0.obs;
  final photos = <String>[].obs;
  final subtitleControllers = <TextEditingController>[];
  final loopPlay = true.obs;
  final frameDuration = 3.obs;
  final albumNameController = TextEditingController();
  @override
  void onInit() {
    super.onInit();
    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    final args = Get.arguments as Map<String, dynamic>?;
    albumId = args?['albumId'] as String?;
    if (albumId != null) {
      _loadCatalogs().then((_) => _loadAlbumData());
    } else {
      final photoPaths = args?['photos'] as List<dynamic>? ?? [];
      photos.addAll(photoPaths.map((p) => p.toString()));
      final title = args?['title'] as String?;
      if (title != null && title.isNotEmpty) {
        albumName.value = title;
      }
      final subtitles = args?['subtitles'] as List<dynamic>? ?? [];
      for (int i = 0; i < photos.length; i++) {
        final ctrl = TextEditingController();
        if (i < subtitles.length) {
          ctrl.text = subtitles[i].toString();
        }
        subtitleControllers.add(ctrl);
      }
      albumNameController.text = albumName.value;
      _loadCatalogs();
    }
  }
  @override
  void onClose() {
    _carouselTimer?.cancel();
    rotationController.dispose();
    _audioPlayer.dispose();
    for (final c in subtitleControllers) {
      c.dispose();
    }
    musicSearchController.dispose();
    albumNameController.dispose();
    super.onClose();
  }
  TemplateItem? get currentTemplate =>
      allTemplates.firstWhereOrNull((t) => t.id == selectedTemplateId.value);
  String get currentSubtitle {
    final index = currentPhotoIndex.value;
    if (index >= 0 && index < subtitleControllers.length) {
      return subtitleControllers[index].text.trim();
    }
    return '';
  }
  Future<void> _loadCatalogs() async {
    try {
      final templateJson = await rootBundle.loadString(
        'assets/templates/catalog.json',
      );
      final templateList = jsonDecode(templateJson) as List<dynamic>;
      allTemplates.value = templateList
          .map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
          .toList();
      filteredTemplates.value = List.from(allTemplates);
    } catch (_) {}
    try {
      final musicJson = await rootBundle.loadString(
        'assets/music/catalog.json',
      );
      final musicList = jsonDecode(musicJson) as List<dynamic>;
      allMusicItems.value = musicList
          .map((e) => MusicItem.fromJson(e as Map<String, dynamic>))
          .toList();
      displayMusicItems.value = List.from(allMusicItems);
    } catch (_) {}
    if (selectedTemplateId.value.isEmpty && allTemplates.isNotEmpty) {
      final random = Random();
      final randomTemplate = allTemplates[random.nextInt(allTemplates.length)];
      selectedTemplateId.value = randomTemplate.id;
    }
    if (selectedMusicId.value.isEmpty && allMusicItems.isNotEmpty) {
      final random = Random();
      final randomMusic = allMusicItems[random.nextInt(allMusicItems.length)];
      await onMusicSelect(randomMusic);
    }
    if (photos.isNotEmpty) {
      _carouselTimer = Timer.periodic(const Duration(seconds: 6), (_) {
        currentPhotoIndex.value = (currentPhotoIndex.value + 1) % photos.length;
      });
    }
  }
  Future<void> _loadAlbumData() async {
    try {
      if (albumId == null) return;
      final album = await AlbumDatabase.instance.queryById(albumId!);
      if (album == null) {
        errorToast('Album not found');
        Get.back();
        return;
      }
      albumName.value = album.title;
      albumNameController.text = album.title;
      photos.value = List<String>.from(album.photos);
      for (int i = 0; i < photos.length; i++) {
        final ctrl = TextEditingController();
        final subtitleText = album.subtitles['$i'] ?? '';
        ctrl.text = subtitleText;
        subtitleControllers.add(ctrl);
      }
      if (album.templateId != null && album.templateId!.isNotEmpty) {
        selectedTemplateId.value = album.templateId!;
      }
      frameDuration.value = album.frameDuration;
      loopPlay.value = album.isLoop;
      if (album.musicPath != null && album.musicPath!.isNotEmpty) {
        final music = allMusicItems.firstWhereOrNull(
          (m) => m.filename == album.musicPath,
        );
        if (music != null) {
          await onMusicSelect(music);
        }
      } else {
        if (photos.isNotEmpty) {
          _carouselTimer = Timer.periodic(const Duration(seconds: 6), (_) {
            currentPhotoIndex.value =
                (currentPhotoIndex.value + 1) % photos.length;
          });
        }
      }
      successToast('Album loaded successfully');
    } catch (e) {
      errorToast('Failed to load album');
    }
  }
  void onRenameAlbumTap() {
    Get.dialog(
      _RenameAlbumDialog(
        initialName: albumName.value,
        onSave: (newName) {
          albumName.value = newName;
          albumNameController.text = newName;
        },
      ),
      barrierDismissible: false,
    );
  }
  void onTogglePlay() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
      isPlaying.value = false;
      rotationController.stop();
    } else {
      await _audioPlayer.resume();
      isPlaying.value = true;
      rotationController.repeat();
    }
  }
  void onTemplateTap() => currentPanel.value = 'template';
  void onMusicTap() => currentPanel.value = 'music';
  void onEditTap() => currentPanel.value = 'edit';
  void onClosePanel() => currentPanel.value = null;
  void onTemplateCategoryTap(int index) {
    selectedTemplateCategory.value = index;
    if (index == 0) {
      filteredTemplates.value = List.from(allTemplates);
    } else {
      final cat = templateCategories[index].toLowerCase();
      filteredTemplates.value = allTemplates
          .where((t) => t.category.toLowerCase() == cat)
          .toList();
    }
  }
  void onTemplateSelect(String templateId) {
    selectedTemplateId.value = templateId;
    onClosePanel();
  }
  void onMusicTabChange(int index) {
    selectedMusicTab.value = index;
    if (index == 0) {
      displayMusicItems.value = List.from(allMusicItems);
    }
  }
  void onSearchMusic(String query) {
    musicSearchQuery.value = query;
    if (query.trim().isEmpty) {
      searchMusicResults.value = [];
      return;
    }
    final q = query.toLowerCase();
    searchMusicResults.value = allMusicItems
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              m.artist.toLowerCase().contains(q) ||
              m.genre.toLowerCase().contains(q),
        )
        .toList();
  }
  Future<void> onMusicSelect(MusicItem music) async {
    try {
      selectedMusicId.value = music.id;
      currentMusicName.value = music.name;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('music/${music.filename}'));
      isPlaying.value = true;
      rotationController.repeat();
      onClosePanel();
    } catch (_) {
      errorToast('Failed to play music');
    }
  }
  void onConfirmMusic() => onClosePanel();
  void onEditTabChange(int index) => selectedEditTab.value = index;
  void onMovePhotoUp(int index) {
    if (index <= 0) return;
    final photo = photos.removeAt(index);
    photos.insert(index - 1, photo);
    final ctrl = subtitleControllers.removeAt(index);
    subtitleControllers.insert(index - 1, ctrl);
  }
  void onMovePhotoDown(int index) {
    if (index >= photos.length - 1) return;
    final photo = photos.removeAt(index);
    photos.insert(index + 1, photo);
    final ctrl = subtitleControllers.removeAt(index);
    subtitleControllers.insert(index + 1, ctrl);
  }
  Future<void> onAddPhotosTap() async {
    onClosePanel();
    try {
      final result = await PhotoManager.requestPermissionExtend();
      if (!result.isAuth && !result.hasAccess) {
        errorToast('Photos permission is required');
        return;
      }
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: false,
      );
      if (albums.isEmpty) {
        errorToast('No photos found');
        return;
      }
      _showPhotoPickerPanel(albums);
    } catch (e) {
      errorToast('Failed to load photos');
    }
  }
  void _showPhotoPickerPanel(List<AssetPathEntity> albums) {
    final selectedAssets = <AssetEntity>[].obs;
    final currentAlbum = albums[0].obs;
    final currentPhotos = <AssetEntity>[].obs;
    currentAlbum.value.getAssetListRange(start: 0, end: 1000).then((assets) {
      currentPhotos.value = assets;
    });
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Select Photos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(
                () => DropdownButton<AssetPathEntity>(
                  value: currentAlbum.value,
                  isExpanded: true,
                  items: albums
                      .map(
                        (album) => DropdownMenuItem(
                          value: album,
                          child: Text(album.name),
                        ),
                      )
                      .toList(),
                  onChanged: (album) async {
                    if (album != null) {
                      currentAlbum.value = album;
                      final assets = await album.getAssetListRange(
                        start: 0,
                        end: 1000,
                      );
                      currentPhotos.value = assets;
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: currentPhotos.length,
                  itemBuilder: (context, index) {
                    final asset = currentPhotos[index];
                    final isSelected = selectedAssets.contains(asset);
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          selectedAssets.remove(asset);
                        } else {
                          selectedAssets.add(asset);
                        }
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AssetEntityImage(
                            asset,
                            isOriginal: false,
                            thumbnailSize: const ThumbnailSize.square(200),
                            fit: BoxFit.cover,
                          ),
                          if (isSelected)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(
                  () => ElevatedButton(
                    onPressed: selectedAssets.isEmpty
                        ? null
                        : () async {
                            for (final asset in selectedAssets) {
                              final file = await asset.file;
                              if (file != null) {
                                photos.add(file.path);
                                subtitleControllers.add(
                                  TextEditingController(),
                                );
                              }
                            }
                            Get.back();
                            successToast(
                              '${selectedAssets.length} photos added',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      selectedAssets.isEmpty
                          ? 'Select photos'
                          : 'Add ${selectedAssets.length} photos',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
  void onAlbumNameSave() {
    final name = albumNameController.text.trim();
    if (name.isEmpty) {
      errorToast('Please enter album name');
      return;
    }
    albumName.value = name;
    successToast('Album name updated');
  }
  Future<void> onSaveTap() async {
    try {
      if (photos.isEmpty) {
        errorToast('Please add at least one photo');
        return;
      }
      final subtitles = <String, String>{};
      for (int i = 0; i < subtitleControllers.length; i++) {
        final text = subtitleControllers[i].text.trim();
        if (text.isNotEmpty) subtitles['$i'] = text;
      }
      final selectedMusic = allMusicItems.firstWhereOrNull(
        (m) => m.id == selectedMusicId.value,
      );
      final now = DateTime.now();
      final id = albumId ?? const Uuid().v4();
      DateTime createdAt = now;
      if (albumId != null) {
        final existingAlbum = await AlbumDatabase.instance.queryById(albumId!);
        if (existingAlbum != null) {
          createdAt = existingAlbum.createdAt;
        }
      }
      final entity = db.AlbumEntity(
        id: id,
        title: albumName.value,
        type: db.AlbumType.music,
        coverPath: photos.isNotEmpty ? photos[0] : null,
        photoCount: photos.length,
        templateId: selectedTemplateId.value,
        musicPath: selectedMusic?.filename,
        photos: List<String>.from(photos),
        subtitles: subtitles,
        danmaku: const [],
        frameDuration: frameDuration.value,
        isLoop: loopPlay.value,
        createdAt: createdAt,
        updatedAt: now,
      );
      if (albumId != null) {
        await AlbumDatabase.instance.update(entity);
        successToast('Album updated successfully');
      } else {
        await AlbumDatabase.instance.insert(entity);
        albumId = id;
        successToast('Album saved successfully');
      }
      Get.offAllNamed('/magic_tab');
    } catch (e) {
      errorToast('Save failed, please try again');
    }
  }
}
class _RenameAlbumDialog extends StatefulWidget {
  final String initialName;
  final void Function(String) onSave;
  const _RenameAlbumDialog({required this.initialName, required this.onSave});
  @override
  State<_RenameAlbumDialog> createState() => _RenameAlbumDialogState();
}
class _RenameAlbumDialogState extends State<_RenameAlbumDialog> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _handleSave() {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      errorToast('Please enter album title');
      return;
    }
    widget.onSave(title);
    Get.back();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Rename Album'),
      content: TextField(
        controller: _controller,
        maxLength: 50,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'My Magic Album',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _handleSave(),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _handleSave, child: const Text('Save')),
      ],
    );
  }
}
