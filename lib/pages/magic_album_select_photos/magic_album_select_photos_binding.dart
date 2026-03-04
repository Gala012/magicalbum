import 'package:get/get.dart';
import 'magic_album_select_photos_logic.dart';
class MagicAlbumSelectPhotosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MagicAlbumSelectPhotosLogic());
  }
}
