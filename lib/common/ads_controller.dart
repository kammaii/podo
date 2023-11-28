import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_strings.dart';

// ANDROID_앱ID : ca-app-pub-2526130301535877~2249268822
// IOS_앱ID : ca-app-pub-2526130301535877~5843284501

class AdsController extends GetxController {
  final ANDROID_REWARD = 'android_reward';
  final ANDROID_INTERSTITIAL = 'android_interstitial';
  final ANDROID_BANNER = 'android_banner';
  final IOS_REWARD = 'ios_reward';
  final IOS_INTERSTITIAL = 'ios_interstitial';
  final IOS_BANNER = 'ios_banner';

  static final AdsController _instance = AdsController.init();

  factory AdsController() {
    return _instance;
  }

  AdsController.init() {
    _initAds();
    loadRewardAds();
    print('Ads 초기화');
  }

  late final Map<String, String> UNIT_ID;
  RewardedInterstitialAd? rewardedInterstitialAd;
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;
  bool isBannerAdLoaded = false;
  bool isAdFullWatched = false;

  _initAds() {
    UNIT_ID = kReleaseMode
        ? {
            ANDROID_REWARD: 'ca-app-pub-2526130301535877/7087335299',
            ANDROID_INTERSTITIAL: 'ca-app-pub-2526130301535877/6871040113',
            ANDROID_BANNER: 'ca-app-pub-2526130301535877/3353686680',
            IOS_REWARD: 'ca-app-pub-2526130301535877/5521249982',
            IOS_INTERSTITIAL: 'ca-app-pub-2526130301535877/5484191852',
            IOS_BANNER: 'ca-app-pub-2526130301535877/2315937180',
          }
        : {
            // TEST ID
            ANDROID_REWARD: 'ca-app-pub-3940256099942544/5354046379',
            ANDROID_INTERSTITIAL: 'ca-app-pub-3940256099942544/1033173712',
            ANDROID_BANNER: 'ca-app-pub-3940256099942544/6300978111',
            IOS_REWARD: 'ca-app-pub-3940256099942544/6978759866',
            IOS_INTERSTITIAL: 'ca-app-pub-3940256099942544/4411468910',
            IOS_BANNER: 'ca-app-pub-3940256099942544/2934735716',
          };
  }

  void loadRewardAds() {
    RewardedInterstitialAd.load(
        adUnitId: UNIT_ID[Platform.isIOS ? IOS_REWARD : ANDROID_REWARD]!,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('RewardAd is loaded');
            rewardedInterstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError e) {
            debugPrint('RewardedInterstitialAd failed to load: $e');
            FirebaseCrashlytics.instance
                .recordError(Exception('Failed to load rewardAd : $e'), null, printDetails: true);
          },
        ),);
  }

  void showRewardAd() {
    if (rewardedInterstitialAd != null) {
      rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedInterstitialAd ad) {
            print('onRewardAdShowed');
          },
          onAdDismissedFullScreenContent: (ad) {
            print('onRewardAd Dismissed');
            if(!isAdFullWatched) {
              print('onRewardAd Stopped');
              Get.until((route) => Get.currentRoute == MyStrings.routeMainFrame);
            }
            ad.dispose();
            isAdFullWatched = false;
            loadRewardAds();
          },
          onAdFailedToShowFullScreenContent: (RewardedInterstitialAd ad, AdError e) {
            print('onRewardAdFailedToShow : $e');
            FirebaseCrashlytics.instance
                .recordError(Exception('onRewardAdFailedToShow : $e'), null, printDetails: true);
            ad.dispose();
          });
      rewardedInterstitialAd!.show(onUserEarnedReward: (ad, item) {
        print('onRewardAd Completed');
        isAdFullWatched = true;
      });
    } else {
      print('Warning: attempt to show interstitial before loaded.');
      FirebaseCrashlytics.instance.recordError(
          Exception('Warning: attempt to show interstitial before loaded.'), null,
          printDetails: true);
    }
  }

  void loadInterstitialAds() {
    InterstitialAd.load(
      adUnitId: UNIT_ID[Platform.isIOS ? IOS_INTERSTITIAL : ANDROID_INTERSTITIAL]!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
        print('InterstitialAd is loaded');
        interstitialAd = ad;
        if (Platform.isAndroid) {
          interstitialAd!.setImmersiveMode(true);
        }
      }, onAdFailedToLoad: (LoadAdError e) {
        print('Failed to load interstitialAd : $e');
        FirebaseCrashlytics.instance
            .recordError(Exception('Failed to load interstitialAd : $e'), null, printDetails: true);
      }),
    );
  }

  void showInterstitialAd(Function(InterstitialAd ad) f) {
    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad) {
            print('onAdShowedFullScreenContent');
          },
          onAdDismissedFullScreenContent: f,
          onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError e) {
            print('onAdFailedToShowFullScreenContent : $e');
            FirebaseCrashlytics.instance
                .recordError(Exception('onAdFailedToShowFullScreenContent : $e'), null, printDetails: true);
            ad.dispose();
          });
      interstitialAd!.show();
      interstitialAd = null;
    } else {
      print('Warning: attempt to show interstitial before loaded.');
      FirebaseCrashlytics.instance.recordError(
          Exception('Warning: attempt to show interstitial before loaded.'), null,
          printDetails: true);
    }
  }

  void loadBannerAd(AdSize size) {
    bannerAd = BannerAd(
      size: size,
      adUnitId: UNIT_ID[Platform.isIOS ? IOS_BANNER : ANDROID_BANNER]!,
      listener: BannerAdListener(onAdFailedToLoad: (Ad ad, LoadAdError e) {
        print('Failed to load bannerAd : $e');
        FirebaseCrashlytics.instance.recordError(
          Exception('Failed to load bannerAd : $e'),
          null,
          printDetails: true,
        );
        ad.dispose();
      }, onAdLoaded: (Ad ad) {
        print('BannerAd is loaded');
        bannerAd = ad as BannerAd;
        isBannerAdLoaded = true;
        update();
      }),
      request: const AdRequest(),
    )..load();
  }
}
