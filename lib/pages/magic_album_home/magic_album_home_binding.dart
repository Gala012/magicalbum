import 'package:get/get.dart';
import 'magic_album_home_logic.dart';
class MagicAlbumHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MagicAlbumHomeLogic());
  }
}
