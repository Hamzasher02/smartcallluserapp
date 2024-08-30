import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smart_call_app/Util/app_url.dart';

class NativeAdModel extends GetxController {
  NativeAd? nativeAd;

  RxBool isAdLoaded = false.obs;
  
  // Use the test ad unit ID for debugging
  final String adUnitId = "ca-app-pub-3940256099942544/2247696110";

  loadAd() {
    nativeAd = NativeAd(
        adUnitId: adUnitId,
        listener: NativeAdListener(onAdLoaded: (value) {
          isAdLoaded.value = true;
          if(kDebugMode){
            print("My Native Ad is loaded....");
          }
        
        },
        onAdFailedToLoad: (ad, error) {
          isAdLoaded.value = false;
          if (kDebugMode) {
            print("Failed to load native ad: $error");
          }
          ad.dispose();
        }),
        nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),
        request: const AdRequest());
        
    nativeAd!.load();
  }

  @override
  void dispose(){
    super.dispose();
    nativeAd?.dispose();
  }
}
