//
//  XLSettingsManager.h
//  XLDistributionBoxApp
//
//  Created by JY on 13-7-10.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


@interface XLSettingsManager : NSObject

@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic) BOOL useSelfSignedSSLCertificates;
@property (nonatomic, copy) NSString *versionNumber;


/*IP*/
@property (nonatomic,copy) NSString *ipString;

/*端口*/
@property (nonatomic,copy) NSString *port;

/*是否使用Key*/
@property (nonatomic) BOOL useSecureDBKey;

/*db key*/
@property (nonatomic,copy) NSString *secureKey;

/*取消发送Flag*/
@property (nonatomic,assign) BOOL cancelSend;

/*通知前缀*/
@property (nonatomic,copy) NSString *notifyPrefix;

/*设备Token*/
@property (nonatomic,copy) NSString *deviceToken;

/*最近一次发送报文*/
@property (nonatomic,copy) NSString *sendPacket;

/*最近一次发送报文时间*/
@property (nonatomic,copy) NSString *sendPacketTime;

/*最近一次接受报文*/
@property (nonatomic,copy) NSString *receivePacket;

/*最近一次接受报文时间*/
@property (nonatomic,copy) NSString *receivePacketTime;

+ (XLSettingsManager *)sharedXLSettingsManager;

-(NSString*)documentPath;

-(BOOL)hostWithPortReachable;

-(BOOL)localWifiReachable;

@end
