#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.t-systems.citykey.dev.Widget";

/// The "WCHeader" asset catalog color resource.
static NSString * const ACColorNameWCHeader AC_SWIFT_PRIVATE = @"WCHeader";

/// The "WCbackground" asset catalog color resource.
static NSString * const ACColorNameWCbackground AC_SWIFT_PRIVATE = @"WCbackground";

/// The "restmullWasteColor" asset catalog color resource.
static NSString * const ACColorNameRestmullWasteColor AC_SWIFT_PRIVATE = @"restmullWasteColor";

/// The "separator" asset catalog color resource.
static NSString * const ACColorNameSeparator AC_SWIFT_PRIVATE = @"separator";

/// The "wasteCalendarBackground" asset catalog color resource.
static NSString * const ACColorNameWasteCalendarBackground AC_SWIFT_PRIVATE = @"wasteCalendarBackground";

/// The "person" asset catalog image resource.
static NSString * const ACImageNamePerson AC_SWIFT_PRIVATE = @"person";

/// The "trash" asset catalog image resource.
static NSString * const ACImageNameTrash AC_SWIFT_PRIVATE = @"trash";

#undef AC_SWIFT_PRIVATE