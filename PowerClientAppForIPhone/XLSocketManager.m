//
//  XLSocketManager.m
//  XLDistributionBoxApp
//
//  Created by JY on 13-7-10.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//


#import "XLSocketManager.h"
#import "XLSettingsManager.h"
#import "XLFrameData.h"
#import "XL3761PackRequest.h"

#import "XLSocketOperation.h"

@interface XLSocketManager()

@property (nonatomic, retain) NSOperationQueue* operatrionQueue;

@property (nonatomic, retain) NSData *frameData;
@property (nonatomic, retain) XLSettingsManager *setting;

@end

@implementation XLSocketManager

SYNTHESIZE_SINGLETON_FOR_CLASS(XLSocketManager)

@synthesize operatrionQueue=_operatrionQueue;
@synthesize socket=_socket;
@synthesize frameData;

- (id)init
{
    if ((self = [super init]) != nil) {   
        self.operatrionQueue = [[NSOperationQueue alloc] init];
        [self.operatrionQueue setMaxConcurrentOperationCount:1];
        self.setting = [XLSettingsManager sharedXLSettingsManager];
    }
    return self;
}

#pragma mark -Socket delegate Methods
/*－－－－－－－－－－－－－－－－－
  初始化并连接Socket
－－－－－－－－－－－－－－－－－*/
-(void)connection{
    self.socket = nil;
    self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *err = nil;
    
    NSString *ipString  = [[XLSettingsManager sharedXLSettingsManager] ipString];
    NSInteger port = [[[XLSettingsManager sharedXLSettingsManager] port] integerValue];
    
    if(![self.socket connectToHost:ipString onPort:port error:&err])    {
        NSLog(@"连接错误");
    }
}

/*－－－－－－－－－－－－－－－－－
 已连接到HOST
－－－－－－－－－－－－－－－－－*/
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"已成功连接到HOST!");
    [self.delegate statusDidConnected];
    
    [self.setting setCancelSend:NO];
    
    NSLog(@"发送报文:%@",[self.frameData description]);
    [self.socket writeData:self.frameData withTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
}

/*－－－－－－－－－－－－－－－－－
 收到返回数据
－－－－－－－－－－－－－－－－－*/
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSLog(@"接收返回报文");
    NSLog(@"返回报文:%@",[data description]);
    
    [self.setting setReceivePacket:[data description]];
    [self.setting setReceivePacketTime:[NSString stringWithFormat:@"%@",[self stringFromDate:[NSDate date]]]];
    
    NSLog(@"%@",[NSDate date]);
 
    [self.delegate statusDidRecevingData];

    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        XLFrameData *frame = [[XLFrameData alloc] initWithData:data];
        [frame parseUserData];
    });

    [sock readDataWithTimeout:-1 tag:0];
}

/*－－－－－－－－－－－－－－－－－
 SOCKET连接已断开
 －－－－－－－－－－－－－－－－－*/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"SOCKET连接已断开");
    [self.delegate statusDidDisconnected];
    [self.setting setCancelSend:YES];
}


#pragma mark -methods..

-(void)performOperation{
    XLSocketOperation *operation = [[XLSocketOperation alloc] init];
    operation.target = self;
    
    [self.operatrionQueue addOperation:operation];
}

/*－－－－－－－－－－－－－－－－－
 连接SOCKET
－－－－－－－－－－－－－－－－－*/
-(void)packRequestFrame:(XL3761PackUserData*)userData{
    
    XL3761PackRequest *request  = [[XL3761PackRequest alloc] init];
    NSData *data = [request packFrame:userData];
    self.frameData = data;
    
    NSLog(@"请求报文:%@",[self.frameData description]);
    
    [self.setting setSendPacket:[self.frameData description]];
    [self.setting setSendPacketTime:[NSString stringWithFormat:@"%@",[self stringFromDate:[NSDate date]]]];
    
    [self.setting setReceivePacket:@""];
    [self.setting setReceivePacketTime:@""];
    
    if (self.frameData) {
        if (self.socket.isConnected) {
            [self.setting setCancelSend:NO];
            [self.socket writeData:self.frameData withTimeout:-1 tag:0];
            [self.socket readDataWithTimeout:-1 tag:0];
        } else{
            [self connection];
        }
    }
}

- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

- (void)dealloc
{
    [_operatrionQueue cancelAllOperations];
}

@end
