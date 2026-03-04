import 'package:get/get.dart';
import 'magic_album_photo_text_preview_logic.dart';
class MagicAlbumPhotoTextPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MagicAlbumPhotoTextPreviewLogic());
  }
}
