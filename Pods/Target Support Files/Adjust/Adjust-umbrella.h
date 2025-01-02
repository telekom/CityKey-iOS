#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ADJAdRevenue.h"
#import "ADJAppStorePurchase.h"
#import "ADJAppStoreSubscription.h"
#import "ADJAttribution.h"
#import "ADJConfig.h"
#import "ADJDeeplink.h"
#import "ADJEvent.h"
#import "ADJEventFailure.h"
#import "ADJEventSuccess.h"
#import "ADJLinkResolution.h"
#import "ADJLogger.h"
#import "ADJPurchaseVerificationResult.h"
#import "ADJSessionFailure.h"
#import "ADJSessionSuccess.h"
#import "ADJThirdPartySharing.h"
#import "Adjust.h"
#import "AdjustSdk.h"

FOUNDATION_EXPORT double AdjustSdkVersionNumber;
FOUNDATION_EXPORT const unsigned char AdjustSdkVersionString[];

