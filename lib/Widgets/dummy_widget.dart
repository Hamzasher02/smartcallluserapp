import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smart_call_app/db/Models/native_ad_model.dart';

class MyDummyNativeAd extends StatefulWidget {
  const MyDummyNativeAd({super.key});

  @override
  State<MyDummyNativeAd> createState() => _MyDummyNativeAdState();
}

class _MyDummyNativeAdState extends State<MyDummyNativeAd> {
  NativeAdModel nativeAdModel = Get.put(NativeAdModel());

  @override
  void initState() {
    super.initState();
    nativeAdModel.loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Obx(() {
            return nativeAdModel.isAdLoaded.value
                ? Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 1.0,
                          maxWidth: MediaQuery.of(context).size.width * 1.0),
                      child: AdWidget(ad: nativeAdModel.nativeAd!),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  );
          }),
        ],
      ),
    );
  }
}
