//
//  XLSocketManager.h
//  XLDistributionBoxApp
//
//  Created by JY on 13-7-10.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XLExternals.h"
#import "XL3761PackEntity.h"
#import "XL3761PackItem.h"
#import "XL3761PackUserData.h"

@protocol XLSocketStatusDelegate <NSObject>


-(void)statusDidConnected;
-(void)statusDidDisconnected;
-(void)statusDidRecevingData;

@end

@interface XLSocketManager : NSObject
{
    
}
@property (nonatomic, retain) GCDAsyncSocket* socket;
@property (nonatomic,weak) id<XLSocketStatusDelegate> delegate;

+(XLSocketManager*)sharedXLSocketManager;

-(void)packRequestFrame:(XL3761PackUserData*)userData;

@end
