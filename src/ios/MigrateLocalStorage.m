#import "MigrateLocalStorage.h"

#define TAG @"ジェレミー"
#define ORIG_LS_FILEPATH @"WebKit/LocalStorage/file__0.localstorage"
#define ORIG_LS_CACHE @"Caches/file__0.localstorage"
// #define TARGET_LS_FILEPATH @"WebsiteData/LocalStorage/file__0.localstorage"
#define TARGET_LS_FILEPATH @"WebsiteData/LocalStorage/http_localhost_9002.localstorage"

// TODO: test IndexedDB
// TODO: test remigration

@implementation MigrateLocalStorage

- (BOOL) copyFrom:(NSString*)src to:(NSString*)dest
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    // Bail out if source file does not exist
    if (![fileManager fileExistsAtPath:src]) {
        NSLog(@"%@ Source file does not exist", TAG);
        return NO;
    }

    // Bail out if dest file exists
    if ([fileManager fileExistsAtPath:dest]) {
        NSLog(@"%@ Target file exists", TAG);
        return NO;
    }

    // create path to dest
    if (![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"%@ error creating target file", TAG);
        return NO;
    }

    // copy src to dest
    return [fileManager copyItemAtPath:src toPath:dest error:nil];
    // return YES;
}

/**
* Gets filepath of localStorage file we want to copy from
*/
- (NSString*) resolveOriginalFile
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
* Gets filepath of localStorage file we want to copy to
*/
- (NSString*) resolveTargetFile
{
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString* target = [[NSString alloc] initWithString: [appLibraryFolder stringByAppendingPathComponent:@"WebKit"]];
    #if TARGET_IPHONE_SIMULATOR
        NSLog(@"%@ 🌕 I am a simulator", TAG);
        // the simulutor squeezes the bundle id into the path
        NSString* bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        target = [target stringByAppendingPathComponent:bundleIdentifier];
    #endif

    return [target stringByAppendingPathComponent:TARGET_LS_FILEPATH];
}

/**
* Checks if localStorage file should be migrated. If so, migrate.
* NOTE: Will only migrate data if there is no localStorage data for WKWebView. This only happens when WKWebView is set up for the first time.
*/
- (void) migrateLocalStorage
{
    // Migrate UIWebView local storage files to WKWebView. Adapted from
    // https://github.com/MaKleSoft/cordova-plugin-migrate-localstorage and
    // https://github.com/Telerik-Verified-Plugins/WKWebView/blob/master/src/ios/MyMainViewController.m

    NSString* original = [self resolveOriginalFile];
    NSLog(@"%@ 📦 original %@", TAG, original);

    NSString* target = [self resolveTargetFile];
    NSLog(@"%@ 🏹 target %@", TAG, target);

    // Only copy data if no existing localstorage data exists yet for wkwebview
    if (![[NSFileManager defaultManager] fileExistsAtPath:target]) {
        NSLog(@"%@ 🕐 No existing localstorage data found for WKWebView. Migrating data from UIWebView", TAG);
        BOOL success = [self copyFrom:original to:target];
        BOOL success2 = [self copyFrom:[original stringByAppendingString:@"-shm"] to:[target stringByAppendingString:@"-shm"]];
        BOOL success3 = [self copyFrom:[original stringByAppendingString:@"-wal"] to:[target stringByAppendingString:@"-wal"]];
        NSLog(@"%@ copy status %d %d %d", TAG, success, success2, success3);
    }
    else {
        // NSLog(@"%@ ⚪️ found data. not migrating", TAG);
        NSLog(@"%@ 🔴 found data. STILL migrating", TAG);
    }
}

- (void)pluginInitialize
{
    NSLog(@"%@ ✅ plugin initialised", TAG);
    [self migrateLocalStorage];
}


@end
