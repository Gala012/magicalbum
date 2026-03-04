import 'package:get/get.dart';
import 'magic_album_music_editor_logic.dart';
class MagicAlbumMusicEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MagicAlbumMusicEditorLogic());
  }
}
