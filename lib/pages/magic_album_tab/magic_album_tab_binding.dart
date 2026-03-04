import 'package:get/get.dart';
import 'magic_album_tab_logic.dart';
import '../magic_album_home/magic_album_home_logic.dart';
import '../magic_album_my_albums/magic_album_my_albums_logic.dart';
import '../magic_album_settings/magic_album_settings_logic.dart';
class MagicAlbumTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MagicAlbumTabLogic());
    Get.lazyPut(() => MagicAlbumHomeLogic());
    Get.lazyPut(() => MagicAlbumMyAlbumsLogic());
    Get.lazyPut(() => MagicAlbumSettingsLogic());
  }
}
