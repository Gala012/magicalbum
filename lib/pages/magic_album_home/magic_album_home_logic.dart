import 'package:get/get.dart';
import '../../db_magic_album/data.dart';
import '../../db_magic_album/db_magic_album_entity.dart';
import '../magic_album_tab/magic_album_tab_logic.dart';
class MagicAlbumHomeLogic extends GetxController {
  final bannerIndex = 0.obs;
  final recentAlbums = <AlbumEntity>[].obs;
  final isLoadingRecent = true.obs;
  @override
  void onInit() {
    super.onInit();
    loadRecentAlbums();
  }
  Future<void> loadRecentAlbums() async {
    try {
      isLoadingRecent.value = true;
      recentAlbums.value =
          await AlbumDatabase.instance.queryRecent(limit: 10);
    } catch (e) {
    } finally {
      isLoadingRecent.value = false;
    }
  }
  void onBannerChange(int index) {
    bannerIndex.value = index;
  }
  void onCreateAlbumTap() {
    Get.toNamed('/magic_select-photos');
  }
  void onThemeTap(String theme) {
    Get.toNamed('/magic_select-photos', arguments: {'theme': theme});
  }
  void onMusicAlbumTap() {
    Get.toNamed('/magic_select-photos', arguments: {'type': 'music'});
  }
  void onPhotoTextAlbumTap() {
    Get.toNamed('/magic_select-photos', arguments: {'type': 'photo_text'});
  }
  void onViewAllTap() {
    try {
      final tabLogic = Get.find<MagicAlbumTabLogic>();
      tabLogic.onTabChange(1);
    } catch (e) {
      Get.toNamed('/magic_my-albums');
    }
  }
  void onRecentAlbumTap(AlbumEntity album) {
    if (album.type == AlbumType.music) {
      Get.toNamed('/magic_music-album-editor', arguments: {'albumId': album.id});
    } else {
      Get.toNamed('/magic_photo-text-album-preview', arguments: {'albumId': album.id});
    }
  }
}
