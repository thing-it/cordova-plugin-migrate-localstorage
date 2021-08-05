/**
* Code Adapted from
* https://github.com/MaKleSoft/cordova-plugin-migrate-localstorage and
* https://github.com/Telerik-Verified-Plugins/WKWebView/blob/master/src/ios/MyMainViewController.m
*/

#import "MigrateLocalStorage.h"

#define TAG @"\nMigrateLS"

#define ORIG_LS_FILEPATH @"WebKit/WebsiteData/LocalStorage/ionic_thing-it.com_0.localstorage"
#define ORIG_LS_CACHE @"Caches/ionic_thing-it.com_0.localstorage"
#define TARGET_LS_FILEPATH @"WebKit/WebsiteData/LocalStorage/ionic_localhost_0.localstorage"

@implementation MigrateLocalStorage

/** File Utility Functions **/

/**
* Moves an item from src to dest. Works only if dest file has not already been created.
*/
- (BOOL) move:(NSString*)src to:(NSString*)dest
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    // Bail out if source file does not exist // not really necessary <- error case already handle by fileManager copyItemAtPath
    if (![fileManager fileExistsAtPath:src]) {
        NSLog(@"%@ Source file does not exist", TAG);
        return NO;
    }

    // Bail out if dest file exists
    if ([fileManager fileExistsAtPath:dest]) { // not really necessary <- error case already handle by fileManager copyItemAtPath
        NSLog(@"%@ Target file exists", TAG);
        return NO;
    }

    // create path to dest
    if (![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"%@ error creating target file", TAG);
        return NO;
    }

    // copy src to dest
    BOOL res = [fileManager moveItemAtPath:src toPath:dest error:nil];
    return res;
}

/** End File Utility Functions **/

/** LS Functions **/

/**
* Gets filepath of localStorage file we want to migrate from
*/
- (NSString*) resolveOriginalLSFile
{
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* original;

    NSString* originalLSFilePath = [appLibraryFolder stringByAppendingPathComponent:ORIG_LS_FILEPATH];

    if ([[NSFileManager defaultManager] fileExistsAtPath:originalLSFilePath]) {
        original = originalLSFilePath;
    } else {
        original = [appLibraryFolder stringByAppendingPathComponent:ORIG_LS_CACHE];
    }
    return original;
}

/**
* Gets filepath of localStorage file we want to migrate to
*/
- (NSString*) resolveTargetLSFile
{
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* target = [appLibraryFolder stringByAppendingPathComponent:TARGET_LS_FILEPATH];

#if TARGET_IPHONE_SIMULATOR
    // the simulator squeezes the bundle id into the path

        NSString* bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        bundleIdentifier = [@"/" stringByAppendingString:bundleIdentifier];

        NSMutableString* targetMutable = [NSMutableString stringWithString:target];
        NSRange range = [targetMutable rangeOfString:@"WebKit"];
        long idx = range.location + range.length;
        [targetMutable insertString:bundleIdentifier atIndex:idx];

        return targetMutable;

#endif

    return target;
}

/**
* Checks if localStorage file should be migrated. If so, migrate.
* NOTE: Will only migrate data if there is no localStorage data for WKWebView. This only happens when WKWebView is set up for the first time.
*/
- (BOOL) migrateLocalStorage
{
    // Migrate UIWebView local storage files to WKWebView.

    NSString* original = [self resolveOriginalLSFile];
    NSLog(@"%@ 📦 original %@", TAG, original);

    NSString* target = [self resolveTargetLSFile];
    NSLog(@"%@ 🏹 target %@", TAG, target);

    // Only copy data if no existing localstorage data exists yet for wkwebview
    if (![[NSFileManager defaultManager] fileExistsAtPath:target]) {
        NSLog(@"%@ 🕐 No existing localstorage data found for WKWebView. Migrating data from UIWebView", TAG);
        BOOL success1 = [self move:original to:target];
        BOOL success2 = [self move:[original stringByAppendingString:@"-shm"] to:[target stringByAppendingString:@"-shm"]];
        BOOL success3 = [self move:[original stringByAppendingString:@"-wal"] to:[target stringByAppendingString:@"-wal"]];
        NSLog(@"%@ copy status %d %d %d", TAG, success1, success2, success3);
        return success1 && success2 && success3;
    }
    else {
        NSLog(@"%@ ⚪️ found LS data. not migrating", TAG);
        return NO;
    }
}

/** End LS Functions **/

- (void)pluginInitialize
{
    BOOL lsResult = [self migrateLocalStorage];
    if (lsResult) {
        NSLog(@"%@ 🟢 Migration finished", TAG);
    } else {
        NSLog(@"%@ ⚪️ Migration not required", TAG);
    }
}

@end
