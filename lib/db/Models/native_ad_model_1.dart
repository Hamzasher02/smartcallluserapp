import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdModel1 extends GetxController {
  final List<NativeAd> _nativeAds = [];
  RxList<RxBool> isAdLoadedList = <RxBool>[].obs;

  // Use the test ad unit ID for debugging
  final String adUnitId = "ca-app-pub-3940256099942544/2247696110";

  // Load multiple native ads
  void loadAds(int count) {
    for (int i = 0; i < count; i++) {
      final NativeAd nativeAd = NativeAd(
        adUnitId: adUnitId,
        listener: NativeAdListener(
            // In your NativeAdModel1 class, when an ad loads successfully or fails to load
            onAdLoaded: (ad) {
          isAdLoadedList[i].value = true;
          print("Ad $i loaded successfully.");
        }, onAdFailedToLoad: (ad, error) {
          isAdLoadedList[i].value = false;
          print("Ad $i failed to load: $error");
          ad.dispose();
        }),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.medium),
        request: const AdRequest(),
      );

      // Initialize ad loading
      nativeAd.load();
      _nativeAds.add(nativeAd);

      // Add an observable boolean for the ad loading status
      isAdLoadedList.add(false.obs);
    }
  }

  // Retrieve the ad at a specific index
  NativeAd? getAd(int index) {
    if (index < _nativeAds.length) {
      return _nativeAds[index];
    }
    return null;
  }

  // Check if ad at a specific index is loaded
  bool isAdLoaded(int index) {
    if (index < isAdLoadedList.length) {
      return isAdLoadedList[index].value;
    }
    return false;
  }

  @override
  void dispose() {
    // Dispose all native ads when done
    for (NativeAd ad in _nativeAds) {
      ad.dispose();
    }
    super.dispose();
  }
}
