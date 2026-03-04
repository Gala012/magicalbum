import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'db_magic_album/data.dart';
import '../pages/magic_album_tab/magic_album_tab_binding.dart';
import '../pages/magic_album_tab/magic_album_tab_view.dart';
import '../pages/magic_album_home/magic_album_home_binding.dart';
import '../pages/magic_album_home/magic_album_home_view.dart';
import '../pages/magic_album_my_albums/magic_album_my_albums_binding.dart';
import '../pages/magic_album_my_albums/magic_album_my_albums_view.dart';
import '../pages/magic_album_settings/magic_album_settings_binding.dart';
import '../pages/magic_album_settings/magic_album_settings_view.dart';
import '../pages/magic_album_select_photos/magic_album_select_photos_binding.dart';
import '../pages/magic_album_select_photos/magic_album_select_photos_view.dart';
import '../pages/magic_album_music_editor/magic_album_music_editor_binding.dart';
import '../pages/magic_album_music_editor/magic_album_music_editor_view.dart';
import '../pages/magic_album_photo_text_editor/magic_album_photo_text_editor_binding.dart';
import '../pages/magic_album_photo_text_editor/magic_album_photo_text_editor_view.dart';
import '../pages/magic_album_photo_text_preview/magic_album_photo_text_preview_binding.dart';
import '../pages/magic_album_photo_text_preview/magic_album_photo_text_preview_view.dart';
const Color primaryColor = Color(0xFFA78BFA);
const Color accentColor = Color(0xFFF472B6);
const Color accentBlue = Color(0xFFC4B5FD);
const Color bgColor = Color(0xFFF8F5FF);
const Color textPrimary = Color(0xFF4B5563);
const Color textBlack = Color(0xFF111827);
const Color textSecondary = Color(0xFF6B7280);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AlbumDatabase.instance.database;
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            getPages: Magic,
            initialRoute: '/magic_tab',
            theme: ThemeData(
              useMaterial3: true,
              primaryColor: primaryColor,
              scaffoldBackgroundColor: bgColor,
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                surface: const Color(0xFFFFFFFF),
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.sp,
                  color: textBlack,
                ),
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(size: 22, color: textBlack),
              ),
              dividerTheme: DividerThemeData(
                thickness: 1,
                color: Colors.grey[200],
              ),
            ),
          ),
        );
      },
    );
  }
}
List<GetPage<dynamic>> Magic = [
  GetPage(
    name: '/magic_tab',
    page: () => const MagicAlbumTabView(),
    binding: MagicAlbumTabBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/magic_home',
    page: () => const MagicAlbumHomeView(),
    binding: MagicAlbumHomeBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/magic_my-albums',
    page: () => const MagicAlbumMyAlbumsView(),
    binding: MagicAlbumMyAlbumsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/magic_settings',
    page: () => const MagicAlbumSettingsView(),
    binding: MagicAlbumSettingsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/magic_select-photos',
    page: () => const MagicAlbumSelectPhotosView(),
    binding: MagicAlbumSelectPhotosBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/magic_music-album-editor',
    page: () => const MagicAlbumMusicEditorView(),
    binding: MagicAlbumMusicEditorBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/magic_photo-text-album-editor',
    page: () => const MagicAlbumPhotoTextEditorView(),
    binding: MagicAlbumPhotoTextEditorBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/magic_photo-text-album-preview',
    page: () => const MagicAlbumPhotoTextPreviewView(),
    binding: MagicAlbumPhotoTextPreviewBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
];