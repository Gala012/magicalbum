import 'package:get/get.dart';
import 'magic_album_photo_text_editor_logic.dart';
class MagicAlbumPhotoTextEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MagicAlbumPhotoTextEditorLogic());
  }
}
