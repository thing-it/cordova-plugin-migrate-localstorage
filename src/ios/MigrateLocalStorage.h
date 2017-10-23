#import <Cordova/CDVPlugin.h>

@interface MigrateLocalStorage : CDVPlugin {}

- (BOOL) move:(NSString*)src to:(NSString*)dest;
- (BOOL) migrateLocalStorage;
- (BOOL) migrateIndexedDB;
- (void) pluginInitialize;

@end
