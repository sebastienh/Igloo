//
//  IglooKit.h
//  IglooKit
//
//  Created by Sebastien hamel on 2017-12-16.
//

// see https://stackoverflow.com/questions/30704268/no-umbrella-header-found-for-target-module-map-will-not-be-generated
// see https://stackoverflow.com/questions/15323109/creating-an-ios-os-x-cross-platform-class
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
    #import <Cocoa/Cocoa.h>
#endif

//! Project version number for IglooKit.
FOUNDATION_EXPORT double IglooKit_VersionNumber;

//! Project version string for IglooKit_macOS.
FOUNDATION_EXPORT const unsigned char IglooKit_VersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <IglooKit/PublicHeader.h>
