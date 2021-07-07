#import "CDVAppodeal.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <StackConsentManager/StackConsentManager.h>

static NSString *AppodealApiKey;

static const int INTERSTITIAL        = 3;
static const int BANNER              = 4;
static const int BANNER_BOTTOM       = 8;
static const int BANNER_TOP          = 16;
static const int REWARDED_VIDEO      = 128;
static const int NON_SKIPPABLE_VIDEO = 256;

static const int BANNER_X_SMART  = 0;
static const int BANNER_X_CENTER = 1;
static const int BANNER_X_LEFT   = 2;
static const int BANNER_X_RIGHT  = 3;

static float bannerHeight = 50.f;
static float statusBarHeight = 20.f;

static bool bannerOverlap;
static bool bannerOverlapBottom;
static bool bannerOverlapTop;
static bool bannerIsShowing;
static bool hasStatusBarPlugin = false;
static bool isIphone;

static APDBannerView* bannerView;

static NSString *CALLBACK_EVENT = @"event";
static NSString *CALLBACK_INIT = @"onInit";
static NSString *CALLBACK_LOADED = @"onLoaded";
static NSString *CALLBACK_FAILED = @"onFailedToLoad";
static NSString *CALLBACK_CLICKED = @"onClick";
static NSString *CALLBACK_SHOWN = @"onShown";
static NSString *CALLBACK_CLOSED = @"onClosed";
static NSString *CALLBACK_FINISHED = @"onFinished";

static bool isRewardedFinished = NO;
static bool isNonSkippableFinished = NO;
static bool isInterstitialPrecache = NO;
static bool isBannerPrecache = NO;

static int nativeAdTypesForType(int adTypes) {
    int nativeAdTypes = 0;

    if ((adTypes & INTERSTITIAL) > 0) {
        nativeAdTypes |= AppodealAdTypeInterstitial;
    }

    if ((adTypes & BANNER) > 0 ||
        (adTypes & BANNER_TOP) > 0 ||
        (adTypes & BANNER_BOTTOM) > 0) {

        nativeAdTypes |= AppodealAdTypeBanner;
    }

    if ((adTypes & REWARDED_VIDEO) > 0) {
        nativeAdTypes |= AppodealAdTypeRewardedVideo;
    }

    if ((adTypes & NON_SKIPPABLE_VIDEO) >0) {
        nativeAdTypes |= AppodealAdTypeNonSkippableVideo;
    }
    return nativeAdTypes;
}

static int nativeShowStyleForType(int adTypes) {

    if ((adTypes & INTERSTITIAL) > 0) {
        return AppodealShowStyleInterstitial;
    }

    if ((adTypes & BANNER_TOP) > 0) {
        return AppodealShowStyleBannerTop;
    }

    if ((adTypes & BANNER_BOTTOM) > 0) {
        return AppodealShowStyleBannerBottom;
    }

    if ((adTypes & REWARDED_VIDEO) > 0) {
        return AppodealShowStyleRewardedVideo;
    }

    if ((adTypes & NON_SKIPPABLE_VIDEO) > 0) {
        return AppodealShowStyleNonSkippableVideo;
    }

    return 0;
}

@interface CDVAppodeal () <STKConsentManagerDisplayDelegate>

@end

@implementation CDVAppodeal

// interface implementation
- (void) initialize:(CDVInvokedUrlCommand*)command
{
    if ([[[command arguments] objectAtIndex:1] intValue] & BANNER) {
        if (bannerOverlap) {
            [self setDelegateOnOverlap:(AppodealAdType)nativeAdTypesForType([[[command arguments] objectAtIndex:1] intValue])];
        }
        bannerHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 90.f : 50.f);
        isIphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? false : true);
    }
    AppodealApiKey = [[command arguments] objectAtIndex:0];
    if (STKConsentManager.sharedManager.consent != nil) {
        // using the StackConsentManager pod
        //id<STKConsent> consent = STKConsentManager.sharedManager.consent;
        [Appodeal initializeWithApiKey:[[command arguments] objectAtIndex:0]
            types:nativeAdTypesForType([[[command arguments] objectAtIndex:1] intValue])
            hasConsent:YES];
    } else {
        [Appodeal initializeWithApiKey:[[command arguments] objectAtIndex:0]
            types:nativeAdTypesForType([[[command arguments] objectAtIndex:1] intValue])];
    }
}

- (void) manageConsent:(CDVInvokedUrlCommand*)command
{
    AppodealApiKey = [[command arguments] objectAtIndex:0];
    [self synchroniseConsent:command];
}

- (void)synchroniseConsent:(CDVInvokedUrlCommand*)command {
    __weak __typeof__(self) weakSelf = self;
    NSString* apiKey = [[command arguments] objectAtIndex:0];
    [STKConsentManager.sharedManager synchronizeWithAppKey:apiKey completion:^(NSError *error) {
        __strong __typeof__(self) strongSelf = weakSelf;
        if (error) {
            NSLog(@"Error while synchronising consent manager: %@", error);
        }
        
        if (STKConsentManager.sharedManager.shouldShowConsentDialog != STKConsentBoolTrue) {
            [strongSelf initialize:command];
            return ;
        }
        
        [STKConsentManager.sharedManager loadConsentDialog:^(NSError *error) {
            if (error) {
                NSLog(@"Error while loading consent dialog: %@", error);
            }
            
            if (!STKConsentManager.sharedManager.isConsentDialogReady) {
                [strongSelf initialize:command];
                return ;
            }
            UIViewController *rootViewController = [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
            [STKConsentManager.sharedManager showConsentDialogFromRootViewController:rootViewController delegate:strongSelf];
        }];
    }];
}

- (void) show:(CDVInvokedUrlCommand*)command {
    if (bannerOverlap) {
        if (([[[command arguments] objectAtIndex:0] intValue]) == 8) {
            if (bannerIsShowing)
                [self hide:command];
            bannerOverlapBottom = true;
            bannerOverlapTop = false;
        }
        else if (([[[command arguments] objectAtIndex:0] intValue]) == 16) {
            if (bannerIsShowing)
                [self hide:command];
            bannerOverlapBottom = false;
            bannerOverlapTop = true;
        }
        
        if (bannerOverlap)
            [self changeWebViewWithOverlappedBanner];
    }
    CDVPluginResult* pluginResult = nil;
    if([Appodeal showAd:nativeShowStyleForType((int)[[[command arguments] objectAtIndex:0] integerValue]) rootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) showWithPlacement:(CDVInvokedUrlCommand*)command {
    if (bannerOverlap){
        if (([[[command arguments] objectAtIndex:0] intValue]) == 8) {
            if (bannerIsShowing)
                [self hide:command];
            bannerOverlapBottom = true;
            bannerOverlapTop = false;
        }
        else if (([[[command arguments] objectAtIndex:0] intValue]) == 16) {
            if (bannerIsShowing)
                [self hide:command];
            bannerOverlapBottom = false;
            bannerOverlapTop = true;
        }
    }
    CDVPluginResult* pluginResult = nil;
    if([Appodeal showAd:nativeShowStyleForType((int)[[[command arguments] objectAtIndex:0] intValue]) forPlacement:[[command arguments] objectAtIndex:1] rootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isLoaded:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    
    if([Appodeal isReadyForShowWithStyle:nativeShowStyleForType([[[command arguments] objectAtIndex:0] intValue])])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) cache:(CDVInvokedUrlCommand*)command {
    [Appodeal cacheAd:nativeAdTypesForType([[[command arguments] objectAtIndex:0] intValue])];
}

- (void) hide:(CDVInvokedUrlCommand*)command {
    if(bannerView) {
        [bannerView removeFromSuperview];
    }
    
    [Appodeal hideBanner];
    if (bannerOverlap) {
        [self returnNativeSize];
    }
    bannerIsShowing = false;
}

- (void) setAutoCache:(CDVInvokedUrlCommand*)command {
    [Appodeal setAutocache:[[[command arguments] objectAtIndex:1] boolValue] types:nativeAdTypesForType([[[command arguments] objectAtIndex:0] intValue])];
}

- (void) isPrecache:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    switch ([[[command arguments] objectAtIndex:0] intValue]) {
        case INTERSTITIAL:
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isInterstitialPrecache];
            break;
        case BANNER:
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isBannerPrecache];
            break;
        default:
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
            break;
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) setBannerBackground:(CDVInvokedUrlCommand*)command {
    [Appodeal setBannerBackgroundVisible:[[[command arguments] objectAtIndex:0] boolValue]];
}

- (void) setBannerAnimation:(CDVInvokedUrlCommand*)command {
    [Appodeal setBannerAnimationEnabled:[[[command arguments] objectAtIndex:0] boolValue]];
}

- (void) setSmartBanners:(CDVInvokedUrlCommand*)command {
    if(bannerView) {
        bannerView.usesSmartSizing = [[[command arguments] objectAtIndex:0] boolValue];
    }
    [Appodeal setSmartBannersEnabled:[[[command arguments] objectAtIndex:0] boolValue]];
}

- (void) set728x90Banners:(CDVInvokedUrlCommand*)command {
    //handled by sdk
}

- (void) setBannerOverLap:(CDVInvokedUrlCommand*)command {
    if (![Appodeal isInitalizedForAdType:AppodealAdTypeBanner]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeFrame:) name: UIApplicationDidChangeStatusBarFrameNotification object:nil];
        bannerOverlap = [[[command arguments] objectAtIndex:0] boolValue];
    }
}

- (void) refreshWebViewForBanner:(CDVInvokedUrlCommand*)command {
    if (bannerIsShowing && bannerOverlap)
        [self changeWebViewWithOverlappedBanner];
}

- (void) setLogLevel:(CDVInvokedUrlCommand*)command {
    switch ([[[command arguments] objectAtIndex:0] intValue]) {
        case 0:
            [Appodeal setLogLevel:APDLogLevelOff];
            break;
        case 1:
            [Appodeal setLogLevel:APDLogLevelDebug];
            break;
        case 2:
            [Appodeal setLogLevel:APDLogLevelVerbose];
            break;
        default:
            [Appodeal setLogLevel:APDLogLevelOff];
            break;
    }
}

- (void) setTesting:(CDVInvokedUrlCommand*)command {
    [Appodeal setTestingEnabled:[[[command arguments] objectAtIndex:0] boolValue]];
}

- (void) setChildDirectedTreatment:(CDVInvokedUrlCommand*)command {
    [Appodeal setChildDirectedTreatment:[[[command arguments] objectAtIndex:0] boolValue]];
}

- (void) setTriggerOnLoadedOnPrecache:(CDVInvokedUrlCommand*)command {
    //not implemented yet
}

- (void) disableNetwork:(CDVInvokedUrlCommand*)command {
    [Appodeal disableNetworkForAdType:AppodealAdTypeInterstitial name:[[command arguments] objectAtIndex:0]];
    [Appodeal disableNetworkForAdType:AppodealAdTypeBanner name:[[command arguments] objectAtIndex:0]];
    [Appodeal disableNetworkForAdType:AppodealAdTypeRewardedVideo name:[[command arguments] objectAtIndex:0]];
    [Appodeal disableNetworkForAdType:AppodealAdTypeNonSkippableVideo name:[[command arguments] objectAtIndex:0]];
}

- (void) disableNetworkType:(CDVInvokedUrlCommand*)command {
    [Appodeal disableNetworkForAdType:nativeAdTypesForType([[[command arguments] objectAtIndex:1] intValue]) name:[[command arguments] objectAtIndex:0]];
}

- (void) disableLocationPermissionCheck:(CDVInvokedUrlCommand*)command {
    [Appodeal setLocationTracking:NO];
}

- (void) disableWriteExternalStoragePermissionCheck:(CDVInvokedUrlCommand*)command {
    //not supported by os
}

- (void) muteVideosIfCallsMuted:(CDVInvokedUrlCommand*)command {
    //handled by os
}

- (void) showTestScreen:(CDVInvokedUrlCommand*)command {
    //not implemented yet
}

- (void) getVersion:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[Appodeal getVersion]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) setPluginVersion:(CDVInvokedUrlCommand*)command {
    NSString *pluginVersion = [[command arguments] objectAtIndex:0];
    [Appodeal setPluginVersion:pluginVersion];
}

- (void) isInitialized:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    if([Appodeal isInitalizedForAdType:(AppodealAdType)nativeAdTypesForType([[[command arguments] objectAtIndex:0] intValue])])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) canShow:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    if([Appodeal canShow:nativeShowStyleForType([[[command arguments] objectAtIndex:0] intValue]) forPlacement:@""])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) canShowWithPlacement:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    
    if([Appodeal canShow:nativeShowStyleForType([[[command arguments] objectAtIndex:0] intValue]) forPlacement:[[command arguments] objectAtIndex:0]])
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void) setCustomDoubleRule:(CDVInvokedUrlCommand*)command {
    NSString *jsonString = [[command arguments] objectAtIndex:0];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [Appodeal setCustomState:json];
}

- (void) setCustomIntegerRule:(CDVInvokedUrlCommand*)command {
    NSString *jsonString = [[command arguments] objectAtIndex:0];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [Appodeal setCustomState:json];
}

- (void) setCustomStringRule:(CDVInvokedUrlCommand*)command {
    NSString *jsonString = [[command arguments] objectAtIndex:0];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [Appodeal setCustomState:json];
}

- (void) setCustomBooleanRule:(CDVInvokedUrlCommand*)command {
    NSString *jsonString = [[command arguments] objectAtIndex:0];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [Appodeal setCustomState:json];
}

- (void) trackInAppPurchase:(CDVInvokedUrlCommand*)command {
    NSNumber *amount = [NSNumber numberWithInt:[[[command arguments] objectAtIndex:0] intValue]];
    [[APDSdk sharedSdk] trackInAppPurchase:amount currency:[[command arguments] objectAtIndex:0]];
}

- (void) getRewardParameters:(CDVInvokedUrlCommand*)command {
    NSString *rewardCurrencyName = [[Appodeal rewardForPlacement:@""] currencyName];
    NSNumber *rewardAmount = [NSNumber numberWithUnsignedInteger:[[Appodeal rewardForPlacement:@""] amount]];
    if(rewardAmount != nil && rewardCurrencyName !=nil) {
        NSDictionary *vals = @{@"amount": rewardAmount, @"currency": rewardCurrencyName};
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        NSDictionary *vals = @{@"amount": @0, @"currency": @""};
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void) getRewardParametersForPlacement:(CDVInvokedUrlCommand*)command {
    NSString *rewardCurrencyName = [[Appodeal rewardForPlacement:[[command arguments] objectAtIndex:0]] currencyName];
    NSNumber *rewardAmount = [NSNumber numberWithUnsignedInteger:[[Appodeal rewardForPlacement:[[command arguments] objectAtIndex:0]] amount]];
    if(rewardAmount != nil && rewardCurrencyName !=nil) {
        NSDictionary *vals = @{@"amount": rewardAmount, @"currency": rewardCurrencyName};
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        NSDictionary *vals = @{@"amount": @0, @"currency": @""};
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void) setUserId:(CDVInvokedUrlCommand*)command {
    NSString *userID = [[command arguments] objectAtIndex:0];
    [Appodeal setUserId: userID];
}

- (void) setAge:(CDVInvokedUrlCommand*)command {
    [Appodeal setUserAge:[[[command arguments] objectAtIndex:0] integerValue]];
}

- (void) setGender:(CDVInvokedUrlCommand*)command {
    switch ([[[command arguments] objectAtIndex:0] integerValue]) {
        case 0:
            [Appodeal setUserGender:AppodealUserGenderOther];
            break;
        case 1:
            [Appodeal setUserGender:AppodealUserGenderMale];
            break;
        case 2:
            [Appodeal setUserGender:AppodealUserGenderFemale];
            break;
        default:
            break;
    }
}

//Banner overlap
- (void) returnNativeSize {
    CGRect bounds = [self.viewController.view.window bounds];
    if (CGRectEqualToRect(bounds, CGRectZero)) {
        bounds = [[UIScreen mainScreen] bounds];
    }
    if (CGRectEqualToRect(bounds, CGRectZero)) {
        bounds = [self.viewController.view bounds];
    }
    self.viewController.view.frame = bounds;
    [self.webView setFrame:bounds];
}

- (BOOL)isiPhoneX
{
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat topPadding = window.safeAreaInsets.top;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        return topPadding > 20 || bottomPadding > 20;
    } else {
        return false;
    }
}

- (void) changeWebViewWithOverlappedBanner {
    CGRect bounds = [self.viewController.view.window bounds];
    if (CGRectEqualToRect(bounds, CGRectZero)) {
        bounds = [[UIScreen mainScreen] bounds];
    }
    if (CGRectEqualToRect(bounds, CGRectZero)) {
        bounds = [self.viewController.view bounds];
    }
    self.viewController.view.frame = bounds;
    if (hasStatusBarPlugin){
        statusBarHeight = 20.f;
    } else {
        if (isIphone && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
            statusBarHeight = 0.f;
        else
            statusBarHeight = 20.f;
    }

    float extraPadding = 0.f;
    if ([self isiPhoneX]) {
        extraPadding = 35.f;
        bounds.origin.y += 30.f;
    }
    if (bannerOverlapTop) {
        [self.webView setFrame:CGRectMake(bounds.origin.x, bounds.origin.y + bannerHeight + statusBarHeight, bounds.size.width, bounds.size.height - bannerHeight - statusBarHeight - extraPadding)];
    } else if (bannerOverlapBottom) {
        [self.webView setFrame:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height - bannerHeight - extraPadding)];
    }
}

- (void) statusBarDidChangeFrame:(NSNotification *)note {
    if (bannerOverlap && bannerIsShowing)
        [self changeWebViewWithOverlappedBanner];
}

- (void) setDelegateOnOverlap:(AppodealAdType) types {
    switch (types) {
        case AppodealAdTypeBanner:
            [Appodeal setBannerDelegate:self];
        case AppodealAdTypeInterstitial:
            [Appodeal setInterstitialDelegate:self];
        case AppodealAdTypeRewardedVideo:
            [Appodeal setRewardedVideoDelegate:self];
        default:
            break;
    }
}

- (void) hasStatusBarPlugin:(CDVInvokedUrlCommand*)command {
    hasStatusBarPlugin = [[[command arguments] objectAtIndex:0] boolValue];
}

- (void)setSharedBannerFrame:(CGFloat)XAxis YAxis:(CGFloat)YAxis {
    if(!bannerView) {
        CGSize size = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kAPDAdSize728x90 : kAPDAdSize320x50;
        bannerView = [[APDBannerView alloc] initWithSize:size];
    }
    
    UIViewAutoresizing mask = UIViewAutoresizingNone;
    
    CGSize  superviewSize = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject].frame.size;
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    CGFloat bannerHeight    = bannerView.frame.size.height;
    CGFloat bannerWidth     = bannerView.frame.size.width;
    
    CGFloat xOffset = .0f;
    CGFloat yOffset = .0f;
    
    //Сalculate X offset
    if (XAxis == BANNER_X_SMART) { //Smart banners
        mask |= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        bannerView.usesSmartSizing = YES;
        bannerWidth = superviewSize.width;
    } else if (XAxis == BANNER_X_LEFT) { //Left
        mask |= UIViewAutoresizingFlexibleRightMargin;
        bannerView.usesSmartSizing = NO;
    } else if (XAxis == BANNER_X_RIGHT) { //Right
        mask |= UIViewAutoresizingFlexibleLeftMargin;
        xOffset = superviewSize.width - bannerWidth;
        bannerView.usesSmartSizing = NO;
    } else if (XAxis == BANNER_X_CENTER) { //Center
        xOffset = (superviewSize.width - bannerWidth) / 2;
        mask |= UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        bannerView.usesSmartSizing = NO;
    } else if (XAxis / screenScale > superviewSize.width - bannerWidth) { //User defined offset more than screen width
        NSLog(@"[Appodeal Banner view][error] Banner view x offset can'not be more than Screen width - acutual banner width");
        xOffset = superviewSize.width - bannerWidth;
        mask |= UIViewAutoresizingFlexibleLeftMargin;
        bannerView.usesSmartSizing = NO;
    } else if (XAxis < -5) {
        bannerView.usesSmartSizing = NO;
        NSLog(@"[Appodeal Banner view][error] Banner view x offset can'not be less than 0");
        xOffset = 0;
    } else {
        bannerView.usesSmartSizing = NO;
        mask |= UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        xOffset = XAxis / screenScale;
    }
    
    //Calculate Y offset
    if (YAxis / screenScale > superviewSize.height - bannerHeight) { //User defined offset more than banner width
        NSLog(@"[Appodeal Banner view][error] Banner view y offset can'not be more than Screen height - acutual banner height");
        yOffset = superviewSize.height - bannerHeight;
        mask |= UIViewAutoresizingFlexibleTopMargin;
    } else if (YAxis == 8) {
        yOffset = superviewSize.height - bannerHeight;
        mask |= UIViewAutoresizingFlexibleTopMargin;
    } else if (YAxis == 16) {
        yOffset = 0;
    } else if (YAxis < 0) {
        NSLog(@"[Appodeal Banner view][error] Banner view y offset can'not be less than 0");
        yOffset = 0;
    } else if (YAxis == .0f) { // All good
        mask |= UIViewAutoresizingFlexibleBottomMargin;
    } else {
        yOffset = YAxis / screenScale;
        mask |= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    NSLog(@"Creating banner frame with parameters: xOffset = %f, yOffset = %f", xOffset, yOffset);
    CGRect bannerRect = CGRectMake(xOffset, yOffset, bannerWidth, bannerHeight);
    [bannerView setAutoresizingMask:mask];
    [bannerView setFrame:bannerRect];
    [bannerView layoutSubviews];
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)showBannerView:(CDVInvokedUrlCommand*)command {
    [bannerView removeFromSuperview];
    
    UIViewController* rootViewController = [self topViewController];
    CGFloat XAxis = (CGFloat) [[[command arguments] objectAtIndex:0] intValue];
    CGFloat YAxis = (CGFloat) [[[command arguments] objectAtIndex:1] intValue];
    
    bannerView.rootViewController = rootViewController;
    if([[command arguments] objectAtIndex:2] != nil)
        bannerView.placement = [[command arguments] objectAtIndex:2];
    [rootViewController.view addSubview:bannerView];
    [rootViewController.view bringSubviewToFront:bannerView];
    [self setSharedBannerFrame:XAxis YAxis:YAxis];
    [bannerView loadAd];
}

-(void)hideBannerView {
    if(bannerView) {
        [bannerView removeFromSuperview];
    }
}

- (void) setInterstitialCallbacks:(CDVInvokedUrlCommand*)command {
    [Appodeal setInterstitialDelegate:self];
    self.interstitialCallbackID = command.callbackId;
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_INIT};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCallbackID];
}

- (void) setBannerCallbacks:(CDVInvokedUrlCommand*)command {
    if(bannerView) {
        bannerView.delegate = self;
    }
    [Appodeal setBannerDelegate:self];
    self.bannerCallbackID = command.callbackId;
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_INIT};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

- (void) setRewardedVideoCallbacks:(CDVInvokedUrlCommand*)command {
    [Appodeal setRewardedVideoDelegate:self];
    self.rewardedCallbackID = command.callbackId;
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_INIT};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void) setNonSkippableVideoCallbacks:(CDVInvokedUrlCommand*)command {
    [Appodeal setNonSkippableVideoDelegate:self];
    self.nonSkippbaleCallbackID = command.callbackId;
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_INIT};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.nonSkippbaleCallbackID];
}

// banner view
- (void)bannerViewDidLoadAd:(APDBannerView *)bannerView {
    isBannerPrecache = false;
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_LOADED, @"isPrecache": @false, @"height": @"0"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

- (void)bannerViewDidInteract:(APDBannerView *)bannerView {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_CLICKED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

- (void)bannerView:(APDBannerView *)bannerView didFailToLoadAdWithError:(NSError *)error {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_FAILED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

- (void)bannerViewDidRefresh:(APDBannerView *)bannerView {
    bannerIsShowing = true;
    if (bannerOverlap)
        [self changeWebViewWithOverlappedBanner];
    
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_SHOWN};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

// banner
- (void)bannerDidLoadAdIsPrecache:(BOOL)precache {
    isBannerPrecache = precache;
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_LOADED, @"isPrecache": [NSNumber numberWithBool:precache], @"height": @"0"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

- (void)bannerDidFailToLoadAd {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_FAILED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

- (void)bannerDidClick {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_CLICKED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

- (void)bannerDidShow {
    bannerIsShowing = true;
    if (bannerOverlap)
        [self changeWebViewWithOverlappedBanner];
    
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_SHOWN};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCallbackID];
}

// interstitial
- (void)interstitialDidLoadAdIsPrecache:(BOOL)precache {
    isInterstitialPrecache = precache;
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_LOADED, @"isPrecache": [NSNumber numberWithBool:precache]};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCallbackID];
}

- (void)interstitialDidFailToLoadAd {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_FAILED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCallbackID];
}

- (void)interstitialWillPresent {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_SHOWN};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCallbackID];
}

- (void)interstitialDidDismiss {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_CLOSED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCallbackID];
}

- (void)interstitialDidClick {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_CLICKED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCallbackID];
}

// rewarded video
- (void)rewardedVideoDidLoadAd {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_LOADED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void)rewardedVideoDidFailToLoadAd {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_FAILED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void)rewardedVideoDidPresent {
    isRewardedFinished = NO;
    
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_SHOWN};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void)rewardedVideoWillDismissAndWasFullyWatched:(BOOL)wasFullyWatched {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_CLOSED, @"wasFullyWatched": [NSNumber numberWithBool:wasFullyWatched]};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void)rewardedVideoDidFinish:(float)rewardAmount name:(NSString *)rewardName {
    isRewardedFinished = YES;
    
    NSMutableDictionary * rewardDict = [NSMutableDictionary new];
    rewardDict[CALLBACK_EVENT] = CALLBACK_FINISHED;
    rewardDict[@"rewardName"] = rewardName;
    rewardDict[@"rewardCount"] = @(rewardAmount);
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:rewardDict];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}


// non skippable video
- (void)nonSkippableVideoDidLoadAd {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_LOADED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void)nonSkippableVideoDidFailToLoadAd {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_FAILED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void)nonSkippableVideoDidPresent {
    isNonSkippableFinished = NO;
    
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_SHOWN};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void)nonSkippableVideoWillDismiss {
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_CLOSED, @"finished": [NSNumber numberWithBool:isNonSkippableFinished]};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

- (void)nonSkippableVideoDidFinish {
    isNonSkippableFinished = YES;
    
    NSDictionary *vals = @{CALLBACK_EVENT: CALLBACK_FINISHED};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:vals];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCallbackID];
}

#pragma mark - STKConsentManagerDisplayDelegate

- (void)consentManagerWillShowDialog:(STKConsentManager *)consentManager {}

- (void)consentManagerDidDismissDialog:(STKConsentManager *)consentManager {
    AppodealAdType adTypes = AppodealAdTypeBanner | AppodealAdTypeInterstitial | AppodealAdTypeRewardedVideo;
    [Appodeal initializeWithApiKey:AppodealApiKey
        types:adTypes
        hasConsent:YES];
}

- (void)consentManager:(STKConsentManager *)consentManager didFailToPresent:(NSError *)error {
    AppodealAdType adTypes = AppodealAdTypeBanner | AppodealAdTypeInterstitial | AppodealAdTypeRewardedVideo;
    [Appodeal initializeWithApiKey:AppodealApiKey
        types:adTypes
        hasConsent:YES];
}

@end
