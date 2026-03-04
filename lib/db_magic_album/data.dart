import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_magic_album_entity.dart';
class AlbumDatabase {
  AlbumDatabase._();
  static final AlbumDatabase instance = AlbumDatabase._();
  static Database? _db;
  static const _dbName = 'magic_album.db';
  static const _dbVersion = 1;
  static const _tableName = 'albums';
  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id               TEXT    PRIMARY KEY,
        title            TEXT    NOT NULL,
        type             TEXT    NOT NULL,
        cover_path       TEXT,
        photo_count      INTEGER NOT NULL DEFAULT 0,
        template_id      TEXT,
        music_path       TEXT,
        -- 音乐相册专用
        photos_json      TEXT    NOT NULL DEFAULT '[]',
        subtitles_json   TEXT    NOT NULL DEFAULT '{}',
        danmaku_json     TEXT    NOT NULL DEFAULT '[]',
        frame_duration   INTEGER NOT NULL DEFAULT 3,
        is_loop          INTEGER NOT NULL DEFAULT 1,
        -- 图文相册专用
        photo_blocks_json TEXT   NOT NULL DEFAULT '[]',
        view_count        INTEGER NOT NULL DEFAULT 0,
        -- 公共
        created_at       TEXT    NOT NULL,
        updated_at       TEXT    NOT NULL
      )
    ''');
  }
  Future<int> insert(AlbumEntity entity) async {
    final db = await database;
    return db.insert(
      _tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<int> update(AlbumEntity entity) async {
    final db = await database;
    return db.update(
      _tableName,
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }
  Future<int> updateTitle(String id, String title) async {
    final db = await database;
    return db.update(
      _tableName,
      {'title': title, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> incrementViewCount(String id) async {
    final db = await database;
    return db.rawUpdate(
      'UPDATE $_tableName SET view_count = view_count + 1 WHERE id = ?',
      [id],
    );
  }
  Future<int> delete(String id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
  Future<List<AlbumEntity>> queryAll() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'created_at DESC');
    return maps.map(AlbumEntity.fromMap).toList();
  }
  Future<List<AlbumEntity>> queryByType(AlbumType type) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'created_at DESC',
    );
    return maps.map(AlbumEntity.fromMap).toList();
  }
  Future<List<AlbumEntity>> queryRecent({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map(AlbumEntity.fromMap).toList();
  }
  Future<AlbumEntity?> queryById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return AlbumEntity.fromMap(maps.first);
  }
  Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM $_tableName');
    return (result.first['cnt'] as int?) ?? 0;
  }
  Future<int> deleteAll() async {
    final db = await database;
    return db.delete(_tableName);
  }
}
