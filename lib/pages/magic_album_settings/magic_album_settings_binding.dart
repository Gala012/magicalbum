import 'package:get/get.dart';
import 'magic_album_settings_logic.dart';
class MagicAlbumSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MagicAlbumSettingsLogic());
  }
}
