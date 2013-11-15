//
//  XLAppDelegate.h
//  PowerClientAppForIPhone
//
//  Created by JY on 13-11-15.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class XLViewController;

@interface XLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) XLViewController *viewController;

+ (NSManagedObjectContext *)managedObjectContext;
@end
