import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import '../../db_magic_album/data.dart';
import '../../db_magic_album/db_magic_album_entity.dart';
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
class MagicAlbumPhotoTextPreviewLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController rotationController;
  final albumTitle = ''.obs;
  final currentDate = ''.obs;
  final viewCount = 0.obs;
  final coverPath = ''.obs;
  final photoBlocks = <PhotoBlock>[].obs;
  final isPlaying = false.obs;
  final currentMusicName = ''.obs;
  final currentPanel = Rx<String?>(null);
  final templateCategories = const [
    'All',
    'Holiday',
    'Elegant',
    '3D',
    'Trendy',
    'Memorial',
    'Travel',
    'Romance',
    'Baby',
    'Minimal',
    'Classic',
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
  AlbumEntity? _album;
  String _albumId = '';
  final _audioPlayer = AudioPlayer();
  @override
  void onInit() {
    super.onInit();
    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _albumId = Get.arguments?['albumId'] as String? ?? '';
    _loadCatalogs().then((_) => _loadAlbum());
  }
  @override
  void onClose() {
    rotationController.dispose();
    _audioPlayer.dispose();
    musicSearchController.dispose();
    super.onClose();
  }
  TemplateItem? get currentTemplate =>
      allTemplates.firstWhereOrNull((t) => t.id == selectedTemplateId.value);
  Color get templatePrimaryColor => _parseColor(
    currentTemplate?.primaryColor,
    defaultColor: const Color(0xFF8B5CF6),
  );
  Color get templateBackgroundColor =>
      _parseColor(currentTemplate?.backgroundColor, defaultColor: Colors.white);
  Color? get templateBackgroundGradientStart =>
      currentTemplate?.backgroundGradientStart != null
      ? _parseColor(currentTemplate?.backgroundGradientStart)
      : null;
  Color? get templateBackgroundGradientEnd =>
      currentTemplate?.backgroundGradientEnd != null
      ? _parseColor(currentTemplate?.backgroundGradientEnd)
      : null;
  Color get templateTitleColor => _parseColor(
    currentTemplate?.titleColor,
    defaultColor: const Color(0xFF1F2937),
  );
  Color get templateContentTextColor => _parseColor(
    currentTemplate?.contentTextColor,
    defaultColor: const Color(0xFF1F2937),
  );
  Color get templateAccentColor => _parseColor(
    currentTemplate?.accentColor,
    defaultColor: const Color(0xFF8B5CF6),
  );
  Color get contentGradientStartColor {
    if (currentTemplate?.contentGradientStart != null) {
      return _parseColor(
        currentTemplate?.contentGradientStart,
        defaultColor: templateBackgroundColor,
      );
    }
    return templateBackgroundColor;
  }
  Color get contentGradientEndColor {
    if (currentTemplate?.contentGradientEnd != null) {
      return _parseColor(
        currentTemplate?.contentGradientEnd,
        defaultColor: _lightenColor(templateBackgroundColor),
      );
    }
    return _lightenColor(templateBackgroundColor, 0.4);
  }
  Color _parseColor(String? hex, {Color? defaultColor}) {
    if (hex == null || hex.isEmpty) {
      return defaultColor ?? const Color(0xFF8B5CF6);
    }
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse(hexCode, radix: 16) + 0xFF000000);
    } catch (_) {
      return defaultColor ?? const Color(0xFF8B5CF6);
    }
  }
  Color _lightenColor(Color color, [double amount = 0.3]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
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
  }
  Future<void> _loadAlbum() async {
    if (_albumId.isEmpty) return;
    try {
      final album = await AlbumDatabase.instance.queryById(_albumId);
      if (album == null) return;
      _album = album;
      albumTitle.value = album.title;
      currentDate.value = getDateString(album.createdAt);
      coverPath.value = album.coverPath ?? '';
      photoBlocks.value = album.photoBlocks;
      await AlbumDatabase.instance.incrementViewCount(_albumId);
      viewCount.value = album.viewCount + 1;
      bool needSave = false;
      if (album.templateId == null || album.templateId!.isEmpty) {
        if (allTemplates.isNotEmpty) {
          final random = Random();
          final randomTemplate =
              allTemplates[random.nextInt(allTemplates.length)];
          selectedTemplateId.value = randomTemplate.id;
          _album = _album!.copyWith(templateId: randomTemplate.id);
          needSave = true;
        }
      } else {
        selectedTemplateId.value = album.templateId!;
      }
      if (album.musicPath == null || album.musicPath!.isEmpty) {
        if (allMusicItems.isNotEmpty) {
          final random = Random();
          final randomMusic =
              allMusicItems[random.nextInt(allMusicItems.length)];
          selectedMusicId.value = randomMusic.id;
          currentMusicName.value = randomMusic.name;
          _album = _album!.copyWith(musicPath: randomMusic.filename);
          await _startPlayMusic(randomMusic.filename);
          needSave = true;
        }
      } else {
        final music = allMusicItems.firstWhereOrNull(
          (m) => m.filename == album.musicPath,
        );
        if (music != null) {
          selectedMusicId.value = music.id;
          currentMusicName.value = music.name;
        }
        await _startPlayMusic(album.musicPath!);
      }
      if (needSave) {
        await AlbumDatabase.instance.update(
          _album!.copyWith(updatedAt: DateTime.now()),
        );
      }
    } catch (_) {}
  }
  Future<void> _startPlayMusic(String filename) async {
    try {
      await _audioPlayer.play(AssetSource('music/$filename'));
      isPlaying.value = true;
      rotationController.repeat();
    } catch (_) {
      isPlaying.value = false;
    }
  }
  void onToggleMusic() async {
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
  void onMoreTap() => currentPanel.value = 'more';
  void onShareTap() => currentPanel.value = 'share';
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
  Future<void> onTemplateSelect(String templateId) async {
    selectedTemplateId.value = templateId;
    if (_album == null) return;
    try {
      _album = _album!.copyWith(
        templateId: templateId,
        updatedAt: DateTime.now(),
      );
      await AlbumDatabase.instance.update(_album!);
      onClosePanel();
    } catch (_) {}
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
      if (_album != null) {
        _album = _album!.copyWith(
          musicPath: music.filename,
          updatedAt: DateTime.now(),
        );
        await AlbumDatabase.instance.update(_album!);
      }
    } catch (_) {
      errorToast('Failed to play music');
    }
  }
  void onEditContentTap() {
    currentPanel.value = null;
    Get.back();
  }
  void onRenameAlbumTap() {
    currentPanel.value = null;
    final titleController = TextEditingController(text: albumTitle.value);
    Get.dialog(
      AlertDialog(
        title: const Text('Rename Album'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              maxLength: 50,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'My Magic Album',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              if (newTitle.isEmpty) {
                errorToast('Please enter album title');
                return;
              }
              try {
                await AlbumDatabase.instance.updateTitle(_albumId, newTitle);
                albumTitle.value = newTitle;
                if (_album != null) {
                  _album = _album!.copyWith(title: newTitle);
                }
                Get.back();
                successToast('Album renamed');
              } catch (_) {
                errorToast('Save failed, please try again');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        titleController.dispose();
      });
    });
  }
  Future<void> onSaveAlbumTap() async {
    currentPanel.value = null;
    if (_album == null) return;
    try {
      await AlbumDatabase.instance.update(
        _album!.copyWith(updatedAt: DateTime.now()),
      );
      successToast('Album saved');
      Get.offAllNamed('/magic_tab');
    } catch (_) {
      errorToast('Save failed, please try again');
    }
  }
  Future<void> onSaveImagesToGallery() async {
    currentPanel.value = null;
    try {
      final result = await PhotoManager.requestPermissionExtend();
      if (!result.isAuth) {
        Get.dialog(
          AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Please allow access to Photos in Settings to save images.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
                child: const Text('Go to Settings'),
              ),
            ],
          ),
        );
        return;
      }
      final paths = <String>[];
      if (coverPath.value.isNotEmpty) paths.add(coverPath.value);
      for (final block in photoBlocks) {
        if (block.photoPath.isNotEmpty) paths.add(block.photoPath);
      }
      for (final path in paths) {
        if (File(path).existsSync()) {
          await PhotoManager.editor.saveImageWithPath(
            path,
            title: 'magic_album',
          );
        }
      }
      successToast('Images saved to your gallery');
    } catch (_) {
      errorToast('Save failed, please try again');
    }
  }
  Future<void> onSystemShareTap({Rect? sharePositionOrigin}) async {
    currentPanel.value = null;
    try {
      final paths = <String>[];
      if (coverPath.value.isNotEmpty) paths.add(coverPath.value);
      for (final block in photoBlocks) {
        if (block.photoPath.isNotEmpty) paths.add(block.photoPath);
      }
      if (paths.isEmpty) {
        errorToast('No images to share');
        return;
      }
      final xFiles = paths
          .where((p) => File(p).existsSync())
          .map((p) => XFile(p))
          .toList();
      if (xFiles.isEmpty) {
        errorToast('No valid images found');
        return;
      }
      final result = await Share.shareXFiles(
        xFiles,
        text: albumTitle.value,
        sharePositionOrigin: sharePositionOrigin,
      );
      if (result.status == ShareResultStatus.success) {
        successToast('Shared successfully');
      } else if (result.status == ShareResultStatus.dismissed) {
      } else {
        errorToast('Share failed, please try again');
      }
    } catch (e) {
      print('Share error: $e');
      errorToast('Share failed, please try again');
    }
  }
}
