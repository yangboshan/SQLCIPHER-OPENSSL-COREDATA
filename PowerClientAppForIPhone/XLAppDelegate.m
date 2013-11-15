//
//  XLAppDelegate.m
//  PowerClientAppForIPhone
//
//  Created by JY on 13-11-15.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//

#import "XLAppDelegate.h"

#import "XLViewController.h"
#import "CMDEncryptedSQLiteStore.h"

@implementation XLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[XLViewController alloc] initWithNibName:@"XLViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *coordinator = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *applicationSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory
                                                            inDomains:NSUserDomainMask] lastObject];
        
        [fileManager createDirectoryAtURL:applicationSupportURL
              withIntermediateDirectories:NO
                               attributes:nil
                                    error:nil];
        
        NSURL *databaseURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:
                              NSLocalizedString(@"DB_NAME", nil)];
        
        NSDictionary *options = nil;
        
//        if ([[XLSettingsManager sharedXLSettingsManager] useSecureDBKey]) {
        if (YES) {
            options = @{
                        CMDEncryptedSQLiteStorePassphraseKey : @"",
                        NSMigratePersistentStoresAutomaticallyOption : @YES,
                        NSInferMappingModelAutomaticallyOption : @YES
                        };
        }
        
        
        NSError *error = nil;
        NSPersistentStore *store = [coordinator
                                    addPersistentStoreWithType:CMDEncryptedSQLiteStoreType
                                    configuration:nil
                                    URL:databaseURL
                                    options:options
                                    error:&error];
        
        NSAssert(store, @"Unable to add persistent store\n%@", error);
        
    });
    return coordinator;
}

+ (NSManagedObjectContext *)managedObjectContext {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    });
    return context;
}

+ (NSURL *)applicationDocumentsDirectory
{
    
    
    NSURL *url=[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                       inDomains:NSUserDomainMask]
                lastObject];
    
    return url;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"device token is: %@", deviceToken);
    
//    [XLSettingsManager sharedXLSettingsManager].deviceToken = [[NSString alloc] initWithData:deviceToken
//                                                                                    encoding:NSUTF8StringEncoding];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get device token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //clear badge number
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

@end
