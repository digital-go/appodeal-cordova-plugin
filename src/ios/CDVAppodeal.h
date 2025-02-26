#import <Cordova/CDV.h>
#import <Appodeal/Appodeal.h>
#import "NativeAdView.h"

@interface CDVAppodeal : CDVPlugin <AppodealBannerDelegate, APDBannerViewDelegate, AppodealInterstitialDelegate, AppodealRewardedVideoDelegate, AppodealNonSkippableVideoDelegate, APDNativeAdQueueDelegate, APDNativeAdPresentationDelegate>

@property (nonatomic, copy) NSString *interstitialCallbackID;
@property (nonatomic, copy) NSString *bannerCallbackID;
@property (nonatomic, copy) NSString *nonSkippbaleCallbackID;
@property (nonatomic, copy) NSString *rewardedCallbackID;
@property (nonatomic, copy) NSString *nativeCallbackID;

@property (nonatomic, strong) APDNativeAdQueue *nativeAdQueue;
@property (nonatomic, strong) APDNativeAd *nativeAd;

- (void) initialize:(CDVInvokedUrlCommand*)command;
- (void) manageConsent:(CDVInvokedUrlCommand*)command;

- (void) show:(CDVInvokedUrlCommand*)command;
- (void) showWithPlacement:(CDVInvokedUrlCommand*)command;
- (void) showBannerView:(CDVInvokedUrlCommand*)command;
- (void) isLoaded:(CDVInvokedUrlCommand*)command;
- (void) cache:(CDVInvokedUrlCommand*)command;
- (void) hide:(CDVInvokedUrlCommand*)command;
- (void) setAutoCache:(CDVInvokedUrlCommand*)command;
- (void) isPrecache:(CDVInvokedUrlCommand*)command;

- (void) setBannerAnimation:(CDVInvokedUrlCommand*)command;
- (void) setSmartBanners:(CDVInvokedUrlCommand*)command;
- (void) set728x90Banners:(CDVInvokedUrlCommand*)command;
- (void) setBannerOverLap:(CDVInvokedUrlCommand*)command;
- (void) refreshWebViewForBanner:(CDVInvokedUrlCommand*)command;
- (void) setLogLevel:(CDVInvokedUrlCommand*)command;
- (void) setTesting:(CDVInvokedUrlCommand*)command;
- (void) setChildDirectedTreatment:(CDVInvokedUrlCommand*)command;
- (void) setTriggerOnLoadedOnPrecache:(CDVInvokedUrlCommand*)command;
- (void) disableNetwork:(CDVInvokedUrlCommand*)command;
- (void) disableNetworkType:(CDVInvokedUrlCommand*)command;
- (void) disableLocationPermissionCheck:(CDVInvokedUrlCommand*)command;
- (void) disableWriteExternalStoragePermissionCheck:(CDVInvokedUrlCommand*)command;
- (void) muteVideosIfCallsMuted:(CDVInvokedUrlCommand*)command;
- (void) showTestScreen:(CDVInvokedUrlCommand*)command;
- (void) getVersion:(CDVInvokedUrlCommand*)command;
- (void) setPluginVersion:(CDVInvokedUrlCommand*)command;
- (void) isInitialized:(CDVInvokedUrlCommand*)command;
- (void) setNativeAdPosition:(CDVInvokedUrlCommand*)command;
- (void) hideNativeAd:(CDVInvokedUrlCommand*)command;
- (void) revealHiddenNativeAd:(CDVInvokedUrlCommand*)command;

- (void) canShow:(CDVInvokedUrlCommand*)command;
- (void) canShowWithPlacement:(CDVInvokedUrlCommand*)command;
- (void) setCustomDoubleRule:(CDVInvokedUrlCommand*)command;
- (void) setCustomIntegerRule:(CDVInvokedUrlCommand*)command;
- (void) setCustomStringRule:(CDVInvokedUrlCommand*)command;
- (void) setCustomBooleanRule:(CDVInvokedUrlCommand*)command;
- (void) getRewardParameters:(CDVInvokedUrlCommand*)command;
- (void) getRewardParametersForPlacement:(CDVInvokedUrlCommand*)command;

- (void) setAge:(CDVInvokedUrlCommand*)command;
- (void) setGender:(CDVInvokedUrlCommand*)command;
- (void) setUserId:(CDVInvokedUrlCommand*)command;
- (void) trackInAppPurchase:(CDVInvokedUrlCommand*)command;
- (void) hasStatusBarPlugin:(CDVInvokedUrlCommand*)command;

- (void) setInterstitialCallbacks:(CDVInvokedUrlCommand*)command;
- (void) setBannerCallbacks:(CDVInvokedUrlCommand*)command;
- (void) setRewardedVideoCallbacks:(CDVInvokedUrlCommand*)command;
- (void) setNonSkippableVideoCallbacks:(CDVInvokedUrlCommand*)command;
- (void) setNativeCallbacks:(CDVInvokedUrlCommand*)command;

@end
