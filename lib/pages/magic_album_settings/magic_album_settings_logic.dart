import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_magic_album/data.dart';
import '../../utils/index.dart';
class MagicAlbumSettingsLogic extends GetxController {
  final appVersion = '1.0.0'.obs;
  void onDeleteAllDataTap() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will delete all your albums permanently. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performDeleteAll();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
  Future<void> _performDeleteAll() async {
    try {
      await AlbumDatabase.instance.deleteAll();
      successToast('All data deleted successfully');
    } catch (e) {
      errorToast('Failed to delete data');
    }
  }
}
