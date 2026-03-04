import 'package:get/get.dart';
import '../magic_album_my_albums/magic_album_my_albums_logic.dart';
import '../magic_album_home/magic_album_home_logic.dart';
class MagicAlbumTabLogic extends GetxController {
  final currentIndex = 0.obs;
  void onTabChange(int index) {
    final previousIndex = currentIndex.value;
    currentIndex.value = index;
    if (index == 1) {
      try {
        final myAlbumsLogic = Get.find<MagicAlbumMyAlbumsLogic>();
        myAlbumsLogic.loadAlbums();
      } catch (e) {
      }
    }
    if (index == 0 && previousIndex != 0) {
      try {
        final homeLogic = Get.find<MagicAlbumHomeLogic>();
        homeLogic.loadRecentAlbums();
      } catch (e) {
      }
    }
  }
}
