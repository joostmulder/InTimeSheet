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

#import "INSDataStackContainer.h"
#import "INSPersistentContainer.h"
#import "INSPersistentContainerMacros.h"
#import "INSPersistentStoreDescription.h"
#import "NSManagedObjectContext+iOS10Additions.h"
#import "NSPersistentStoreCoordinator+INSPersistentStoreDescription.h"

FOUNDATION_EXPORT double INSPersistentContainerVersionNumber;
FOUNDATION_EXPORT const unsigned char INSPersistentContainerVersionString[];

