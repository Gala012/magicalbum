import 'package:get/get.dart';
import 'magic_album_my_albums_logic.dart';
class MagicAlbumMyAlbumsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MagicAlbumMyAlbumsLogic());
  }
}
