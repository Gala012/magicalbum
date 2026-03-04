import 'dart:convert';
enum AlbumType {
  music('music'),
  photoText('photo_text');
  final String value;
  const AlbumType(this.value);
  static AlbumType fromString(String value) {
    return AlbumType.values.firstWhere((e) => e.value == value);
  }
}
class PhotoBlock {
  final String photoPath;
  final String description;
  const PhotoBlock({required this.photoPath, this.description = ''});
  Map<String, dynamic> toMap() => {
    'photoPath': photoPath,
    'description': description,
  };
  factory PhotoBlock.fromMap(Map<String, dynamic> map) => PhotoBlock(
    photoPath: map['photoPath'] as String,
    description: (map['description'] as String?) ?? '',
  );
}
class AlbumEntity {
  final String id;
  final String title;
  final AlbumType type;
  final String? coverPath;
  final int photoCount;
  final String? templateId;
  final String? musicPath;
  final List<String> photos;
  final Map<String, String> subtitles;
  final List<String> danmaku;
  final int frameDuration;
  final bool isLoop;
  final List<PhotoBlock> photoBlocks;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AlbumEntity({
    required this.id,
    required this.title,
    required this.type,
    this.coverPath,
    this.photoCount = 0,
    this.templateId,
    this.musicPath,
    this.photos = const [],
    this.subtitles = const {},
    this.danmaku = const [],
    this.frameDuration = 3,
    this.isLoop = true,
    this.photoBlocks = const [],
    this.viewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });
  AlbumEntity copyWith({
    String? id,
    String? title,
    AlbumType? type,
    String? coverPath,
    int? photoCount,
    String? templateId,
    String? musicPath,
    List<String>? photos,
    Map<String, String>? subtitles,
    List<String>? danmaku,
    int? frameDuration,
    bool? isLoop,
    List<PhotoBlock>? photoBlocks,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlbumEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      coverPath: coverPath ?? this.coverPath,
      photoCount: photoCount ?? this.photoCount,
      templateId: templateId ?? this.templateId,
      musicPath: musicPath ?? this.musicPath,
      photos: photos ?? this.photos,
      subtitles: subtitles ?? this.subtitles,
      danmaku: danmaku ?? this.danmaku,
      frameDuration: frameDuration ?? this.frameDuration,
      isLoop: isLoop ?? this.isLoop,
      photoBlocks: photoBlocks ?? this.photoBlocks,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.value,
      'cover_path': coverPath,
      'photo_count': photoCount,
      'template_id': templateId,
      'music_path': musicPath,
      'photos_json': jsonEncode(photos),
      'subtitles_json': jsonEncode(subtitles),
      'danmaku_json': jsonEncode(danmaku),
      'frame_duration': frameDuration,
      'is_loop': isLoop ? 1 : 0,
      'photo_blocks_json': jsonEncode(
        photoBlocks.map((b) => b.toMap()).toList(),
      ),
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  factory AlbumEntity.fromMap(Map<String, dynamic> map) {
    final photosRaw = map['photos_json'] as String? ?? '[]';
    final subtitlesRaw = map['subtitles_json'] as String? ?? '{}';
    final danmakuRaw = map['danmaku_json'] as String? ?? '[]';
    final blocksRaw = map['photo_blocks_json'] as String? ?? '[]';
    final photosDecoded = jsonDecode(photosRaw) as List<dynamic>;
    final subtitlesDecoded = jsonDecode(subtitlesRaw) as Map<String, dynamic>;
    final danmakuDecoded = jsonDecode(danmakuRaw) as List<dynamic>;
    final blocksDecoded = jsonDecode(blocksRaw) as List<dynamic>;
    return AlbumEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      type: AlbumType.fromString(map['type'] as String),
      coverPath: map['cover_path'] as String?,
      photoCount: (map['photo_count'] as int?) ?? 0,
      templateId: map['template_id'] as String?,
      musicPath: map['music_path'] as String?,
      photos: photosDecoded.map((e) => e as String).toList(),
      subtitles: subtitlesDecoded.map((k, v) => MapEntry(k, v as String)),
      danmaku: danmakuDecoded.map((e) => e as String).toList(),
      frameDuration: (map['frame_duration'] as int?) ?? 3,
      isLoop: ((map['is_loop'] as int?) ?? 1) == 1,
      photoBlocks: blocksDecoded
          .map((e) => PhotoBlock.fromMap(e as Map<String, dynamic>))
          .toList(),
      viewCount: (map['view_count'] as int?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
