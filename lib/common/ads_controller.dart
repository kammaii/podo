import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo/values/my_strings.dart';

// ANDROID_앱ID : ca-app-pub-4839718329129134~3804779337
// IOS_앱ID : ca-app-pub-4839718329129134~7214375459

class AdsController extends GetxController {
  final ANDROID_REWARD = 'android_reward';
  final ANDROID_BANNER = 'android_banner';
  final IOS_REWARD = 'ios_reward';
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
  BannerAd? bannerAd;
  bool isBannerAdLoaded = false;
  bool isAdFullWatched = false;

  _initAds() {
    UNIT_ID = kReleaseMode
        ? {
            ANDROID_REWARD: 'ca-app-pub-4839718329129134/6793016704',
            ANDROID_BANNER: 'ca-app-pub-4839718329129134/9972400735',
            IOS_REWARD: 'ca-app-pub-4839718329129134/1540690023',
            IOS_BANNER: 'ca-app-pub-4839718329129134/9614034432',
          }
        : {
            // TEST ID
            ANDROID_REWARD: 'ca-app-pub-3940256099942544/5354046379',
            ANDROID_BANNER: 'ca-app-pub-3940256099942544/6300978111',
            IOS_REWARD: 'ca-app-pub-3940256099942544/6978759866',
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
      ),
    );
  }

  void showRewardAd() {
    //TODO: 보상형 광고가 null일 경우 광고 없이 레슨이 시작하는 문제에 대해 고민할 것
    if (rewardedInterstitialAd != null) {
      rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdShowedFullScreenContent: (RewardedInterstitialAd ad) {
        print('onRewardAdShowed');
      }, onAdDismissedFullScreenContent: (ad) {
        print('onRewardAd Dismissed');
        if (!isAdFullWatched) {
          print('onRewardAd Stopped');
          Get.until((route) => Get.currentRoute == MyStrings.routeMainFrame);
        }
        ad.dispose();
        isAdFullWatched = false;
        loadRewardAds();
      }, onAdFailedToShowFullScreenContent: (RewardedInterstitialAd ad, AdError e) {
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

  void loadBannerAd(AdSize size) {
    // 기존 배너 광고를 정리
    bannerAd?.dispose();
    bannerAd = null;
    isBannerAdLoaded = false;

    bannerAd = BannerAd(
      size: size,
      adUnitId: UNIT_ID[Platform.isIOS ? IOS_BANNER : ANDROID_BANNER]!,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError e) {
          print('Failed to load bannerAd : $e');
          FirebaseCrashlytics.instance.recordError(
            Exception('Failed to load bannerAd : $e'),
            null,
            printDetails: true,
          );
          ad.dispose();
          // 상태 초기화 및 업데이트
          bannerAd = null;
          isBannerAdLoaded = false;
          update();
        },
        onAdLoaded: (Ad ad) {
          print('BannerAd is loaded');
          bannerAd = ad as BannerAd;
          isBannerAdLoaded = true;
          update();
        },
      ),
      request: const AdRequest(),
    )..load();
  }
}
