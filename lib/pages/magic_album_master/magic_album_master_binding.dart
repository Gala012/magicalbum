import 'package:get/get.dart';

import 'magic_album_master_logic.dart';

class MagicAlbumMasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      MagicAlbumMasterLogic(),
      permanent: true,
    );
  }
}
