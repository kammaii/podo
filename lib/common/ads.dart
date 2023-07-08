import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo/screens/profile/user.dart';

// ANDROID_앱ID : ca-app-pub-2526130301535877~2249268822
// IOS_앱ID : ca-app-pub-2526130301535877~5843284501

class Ads {
  final ANDROID_INTERSTITIAL = 'android_interstitial';
  final ANDROID_BANNER = 'android_banner';
  final IOS_INTERSTITIAL = 'ios_interstitial';
  final IOS_BANNER = 'ios_banner';

  static final Ads _instance = Ads.init();

  factory Ads() {
    return _instance;
  }

  Ads.init() {
    _initAds();
    _loadInterstitialAds();
    print('Ads 초기화');
  }

  late final Map<String, String> UNIT_ID;
  InterstitialAd? _interstitialAd;

  _initAds() {
    UNIT_ID = kReleaseMode
        ? {
            ANDROID_INTERSTITIAL: 'ca-app-pub-2526130301535877/6871040113',
            ANDROID_BANNER: 'ca-app-pub-2526130301535877/3353686680',
            IOS_INTERSTITIAL: 'ca-app-pub-2526130301535877/5484191852',
            IOS_BANNER: 'ca-app-pub-2526130301535877/2315937180'
          }
        : {
            // TEST ID
            ANDROID_INTERSTITIAL: 'ca-app-pub-3940256099942544/1033173712',
            ANDROID_BANNER: 'ca-app-pub-3940256099942544/6300978111',
            IOS_INTERSTITIAL: 'ca-app-pub-3940256099942544/4411468910',
            IOS_BANNER: 'ca-app-pub-3940256099942544/2934735716'
          };
  }

  void _loadInterstitialAds() {
    InterstitialAd.load(
      adUnitId: UNIT_ID[User().os == 'iOS' ? IOS_INTERSTITIAL : ANDROID_INTERSTITIAL]!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
        print('InterstitialAd is loaded');
        _interstitialAd = ad;
        if (User().os == 'android') {
          _interstitialAd!.setImmersiveMode(true);
        }
      }, onAdFailedToLoad: (LoadAdError e) {
        print('Failed to load interstitialAd : $e');
      }),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(onAdShowedFullScreenContent: (InterstitialAd ad) {
      print('onAdShowedFullScreenContent');
    }, onAdDismissedFullScreenContent: (InterstitialAd ad) {
      print('onAdDismissedFullScreenContent');
    }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError e) {
      print('onAdFailedToShowFullScreenContent : $e');
      ad.dispose();
      _loadInterstitialAds();
    });
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  BannerAd getBannerAd(AdSize size) {
    return BannerAd(
      size: size,
      adUnitId: UNIT_ID[User().os == 'iOS' ? IOS_BANNER : ANDROID_BANNER]!,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError e) {
          print('Failed to load bannerAd : $e');
          ad.dispose();
        },
        onAdLoaded: (_) {
          print('BannerAd is loaded');
        }
      ),
      request: const AdRequest(),
    )..load();
  }
}
