# Appodeal Cordova Plugin

This is an unofficial Appodeal Cordova plugin, created to support Appodeal SDK with Apache Cordova / Ionic apps.<br>
Includes consent management with the StackConsentManager package.

## How to use:

```bash
cordova plugin add "repourl" --variable GOOGLE_MOBILE_ADS_SDK_APP_ID="ca-app-pub-xxxx~yyyy"
```

## initialize with consent management (GDPR requirement):

```javascript
let Appodeal = window['plugins'].Appodeal;
Appodeal.setLogLevel(Appodeal.LogLevel.DEBUG);
Appodeal.hasStatusBarPlugin(true); // true if cordova-plugin-statusbar is present in the app
Appodeal.muteVideosIfCallsMuted(true);
Appodeal.setBannerOverLap(true);

Appodeal.manageConsent(
    "Appodeal App Key",
    Appodeal.BANNER | Appodeal.INTERSTITIAL | Appodeal.REWARDED_VIDEO | Appodeal.NATIVE,
    hasConsent,
    callback
);
```

## set callbacks:

```javascript
Appodeal.setBannerCallbacks(function(container){
    console.log('banner callback event triggered:', container.event);
});
Appodeal.setInterstitialCallbacks(function(container){
    console.log('interstitial callback event triggered:', container.event);
});
Appodeal.setRewardedVideoCallbacks(function(container){
    console.log('rewarded video callback event triggered:', container.event);
    if (container.event === 'onClosed') {
         // reward is identified here for iOS
         console.log('rewarded video closed, was fully watched?', container.wasFullyWatched);
    } else if (container.event === 'onFinished') {
         // reward is identified here for android
         console.log('rewarded video finished and fully watched.');
    }
});
Appodeal.setNativeCallbacks(function(container){
    console.log('nativeAd callback event triggered:', container.event);
});
```

## show the ads:

```javascript
Appodeal.isInitialized(Appodeal.BANNER_TOP, function(status){
     console.log('initialization status for BANNER_TOP:', status);
});
Appodeal.canShow(Appodeal.BANNER_TOP, function(canShow){
     console.log('can show BANNER_TOP?', canShow);
});
Appodeal.show(Appodeal.BANNER_TOP, function(result){
     console.log('BANNER_TOP ad shown', result);
});

Appodeal.show(Appodeal.INTERSTITIAL, function(result){
     console.log('INTERSTITIAL ad shown', result);
});

Appodeal.show(Appodeal.REWARDED_VIDEO, function(result){
     console.log('REWARDED_VIDEO ad shown', result);
});

Appodeal.show(Appodeal.NATIVE, function(result){
     console.log('NATIVE ad shown', result);
});
```

## notes about Native Ad:

From inside the cordova/ionic app, the `setNativeAdPosition()` method can be hooked to the `onScroll` event of the desired content area, to make the NativeAd View get repositioned following scroll events.<br>
The final result is not perfect (also requires special controls from the javascript side), but works and allows Ionic/Cordova apps to show NativeAds from Appodeal.<br>
On Android, the Native Ad is created on a dedicated View object using the specific Appodeal template `NativeAdViewNewsFeed`. This View is drawn separated from the Cordova webview (as all other ad types), but can be positioned via the `setNativeAdPosition()` method (values for top/left/bottom/right must be provided, along with a 'tab height' value to define height boundaries).<br>
On iOS, the Native Ad is created on its own NIB (Native.xib). The loading is done automatically, and it will appear on screen upon a call to Appodeal.show(). The ad position can be changed via `setNativeAdPosition()` method.<br>
<hr />

appodeal SDK versions:<br>
iOS: 3.0.2 (must use XCode 14+, with Rosetta when on an Apple silicon processor)<br>
android: 2.11.0

stack consent SDK versions:<br>
iOS: included<br>
android: 1.0.5