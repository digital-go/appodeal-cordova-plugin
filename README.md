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
    Appodeal.BANNER | Appodeal.INTERSTITIAL | Appodeal.REWARDED_VIDEO,
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
```

appodeal SDK versions:<br>
iOS: 2.10.0.1-Beta<br>
android: 2.10.1

stack consent SDK versions:<br>
iOS: 1.1.1<br>
android: 1.0.4