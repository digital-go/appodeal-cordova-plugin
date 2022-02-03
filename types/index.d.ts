interface Window {
    plugins: Plugins
}

interface Plugins {
    Appodeal: Appodeal
}

declare class Appodeal {
    initialize: (appKey: any, adTypes: any, hasConsent: any, callback: any) => void
    manageConsent: (appKey: any, adTypes: any, hasConsent: any, callback: any) => void
    show: (adType: any, callback: any) => void
    showWithPlacement: (adType: any, placement: any, callback: any) => void
    showBannerView: (xAxis: any, yAxis: any, placement: any) => void
    isLoaded: (adType: any, callback: any) => void
    cache: (adType: any) => void
    hide: (adType: any) => void
    destroy: (adType: any) => void
    onResume: (adType: any) => void
    setAutoCache: (adTypes: any, autoCache: any) => void
    isPrecache: (adType: any, callback: any) => void
    setBannerAnimation: (value: any) => void
    setSmartBanners: (value: any) => void
    set728x90Banners: (value: any) => void
    setBannerOverLap: (value: any) => void
    refreshWebViewForBanner: (value: any) => void
    setTesting: (testing: any) => void
    setLogLevel: (loglevel: any) => void
    setChildDirectedTreatment: (value: any) => void
    setTriggerOnLoadedOnPrecache: (set: any) => void
    disableNetwork: (network: any, adType: any) => void
    disableNetworkType: (network: any, adType: any) => void
    disableLocationPermissionCheck: () => void
    disableWriteExternalStoragePermissionCheck: () => void
    muteVideosIfCallsMuted: (value: any) => void
    showTestScreen: (value: any) => void
    getVersion: (callback: any) => void
    getPluginVersion: () => string
    isInitialized: (adTypes: any, callback: any) => void
    canShow: (adType: any, callback: any) => void
    canShowWithPlacement: (adType: any, placement: any, callback: any) => void
    getRewardParameters: (callback: any) => void
    getRewardParametersForPlacement: (placement: any, callback: any) => void
    setExtraData: (name: any, value: any) => void
    getPredictedEcpm: (adType: any, callback: any) => void
    setAge: (age: any) => void
    setGender: (gender: any) => void
    setUserId: (userid: any) => void
    trackInAppPurchase: (amount: any, currency: any) => void
    hasStatusBarPlugin: (value: any) => void
    setInterstitialCallbacks: (callback: any) => void
    setNonSkippableVideoCallbacks: (callbacks: any) => void
    setRewardedVideoCallbacks: (callbacks: any) => void
    setBannerCallbacks: (callbacks: any) => void
    setNativeCallbacks: (callback: any) => void
    getNativeAds: (callback: any) => void
    setNativeAdPosition: (x: any, y: any, w: any, h: any, tabH: any, callback: any) => void
    hideNativeAd: (callback: any) => void
    revealHiddenNativeAd: (callback: any) => void
}