//
//  XLSettingsManager.m
//  XLDistributionBoxApp
//
//  Created by JY on 13-7-10.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//


#import "XLSettingsManager.h"
#import "SynthesizeSingleton.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import <ifaddrs.h>

//#import "UIDeviceHardware.h"

static NSString *SETTING_SERVER   = @"SETTING_SERVER";
static NSString *SETTING_USERNAME = @"SETTING_USERNAME";
static NSString *SETTING_PASSWORD = @"SETTING_PASSWORD";

static NSString *SETTING_FIRST_TIME_RUN = @"SETTING_FIRST_TIME_RUN";
static NSString *SETTING_VERSION_NUMBER = @"SETTING_VERSION_NUMBER";
static NSString *SETTING_USE_SELF_SIGNED_CERTIFICATE = @"SETTING_USE_SELF_SIGNED_CERTIFICATE";

static NSString *SETTING_IPSTRING = @"SETTING_IPSTRING";
static NSString *SETTING_PORT     = @"SETTING_PORT";
static NSString *SETTING_USE_SECURE_DB_KEY     = @"SETTING_USE_SECURE_DB_KEY";
static NSString *SETTING_SECURE_DB_KEY         = @"SETTING_SECURE_DB_KEY";

static NSString *SETTING_CANCEL            = @"SETTING_CANCEL";
static NSString *SETTING_NOTIFY_PREFIX     = @"SETTING_NOTIFY_PREFIX";
static NSString *SETTING_DEVICETOKE     = @"SETTING_DEVICETOKE";

static NSString *SETTING_SEND_PACKET    = @"SETTING_SEND_PACKET";
static NSString *SETTING_RECEIVE_PACKET = @"SETTING_RECEIVE_PACKET";
static NSString *SETTING_SEND_PACKET_TIME    = @"SETTING_SEND_PACKET_TIME";
static NSString *SETTING_RECEIVE_PACKET_TIME = @"SETTING_RECEIVE_PACKET_TIME";

#define DB_Psw_Key @"T0pSecret!"

@interface XLSettingsManager ()

@property (nonatomic, retain) NSUserDefaults *userDefaults;

@end


@implementation XLSettingsManager

SYNTHESIZE_SINGLETON_FOR_CLASS(XLSettingsManager)

@dynamic server;
@dynamic username;
@dynamic password;
@dynamic useSelfSignedSSLCertificates;
@dynamic versionNumber;

@dynamic ipString;
@dynamic port;
@dynamic useSecureDBKey;
@dynamic secureKey;
@dynamic cancelSend;
@dynamic notifyPrefix;
@dynamic deviceToken;

@synthesize userDefaults = _userDefaults;

/*－－－－－－－－－－－－－－－－－
             配置
 
 检测第一次运行配置环境 
 复制SQLite 
 初始化变量 
－－－－－－－－－－－－－－－－－*/
- (id)init
{
    if (self = [super init])
    {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        self.ipString = @"10.10.2.1";
        self.port = @"2222";
        
        
        /*－－－－－－－－－－－－－－－
         APP是否初次运行 做一些配置
         －－－－－－－－－－－－－－－*/
        
        NSObject *setting = [self.userDefaults objectForKey:SETTING_FIRST_TIME_RUN];
        if (setting == nil)
        {
            [self.userDefaults setObject:[NSNumber numberWithInt:1] forKey:SETTING_FIRST_TIME_RUN];
            self.useSelfSignedSSLCertificates = NO;

            
            /*－－－－－－－－－－－－－－－－－－－－－－－－－－－
             初次运行判断沙盒下是否存在Sqlite 文件，如无则复制之。
             
             CORE DATA生成SQLITE文件后 导入离线配置数据打包进IPA
             －－－－－－－－－－－－－－－－－－－－－－－－－－－*/
//            NSString *destPath = [[self documentPath] stringByAppendingPathComponent:
//                                  NSLocalizedString(@"DB_NAME", nil)];
//              
//            if (![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
//                
//                NSError *error;
//                
//                NSString *srcPath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"DB_NAME", nil)
//                                                                    ofType:nil];
//                
//                if(![[NSFileManager defaultManager] copyItemAtPath:srcPath
//                                                            toPath:destPath
//                                                             error:&error]){
//                    NSLog(@"%@",[error description]);
//                }
//            }            
            
            if (self.secureKey == nil) {
                self.secureKey = DB_Psw_Key;
            }
            [self.userDefaults synchronize];
        }
    }
    return self;
}

-(NSString*)documentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES)
            objectAtIndex:0];
}

/*－－－－－－－－－－－－－－－－－
 终端WIFI可达
 －－－－－－－－－－－－－－－－－*/
-(BOOL)hostWithPortReachable{
    
    const char *serverIPChar = [self.ipString cStringUsingEncoding:NSASCIIStringEncoding];
    
    struct sockaddr_in address;
    
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons([self.port integerValue]);
    address.sin_addr.s_addr = inet_addr(serverIPChar);
    
    
    Reachability *reachability = [Reachability reachabilityWithAddress:&address];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    
    return status == 1;
}

/*－－－－－－－－－－－－－－－－－
 Local WIFI可达
 －－－－－－－－－－－－－－－－－*/
-(BOOL)localWifiReachable{
 
    Reachability *reachability = [Reachability reachabilityForLocalWiFi];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == 1) {
        NSString *ipAddress = [self getIPAddress];
        if (![ipAddress isEqualToString:@"0.0.0.0"]) {
            
            NSRange range =  [ipAddress rangeOfString:@"." options:NSBackwardsSearch];
            NSRange range1 = [self.ipString rangeOfString:@"." options:NSBackwardsSearch];
            
            if ([[ipAddress substringToIndex:range.location]
                 isEqualToString: [self.ipString substringToIndex:range1.location]]) {
                return YES;
            }
        }
    }
    
    return NO;
}


/*－－－－－－－－－－－－－－－－－
 INTERNET可达
 －－－－－－－－－－－－－－－－－*/
-(BOOL)internetReachability{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == NotReachable) {
        return NO;
    }
    return YES;
}

- (NSString *)getIPAddress
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    if(!getifaddrs(&interfaces)) {

        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                
                
//                NSLog(@"NAME: \"%@\" addr: %@", name, addr);
                
                NSString *type = @"en0";
                
#ifdef DEBUG
                if ([[[UIDevice currentDevice] model]
                                isEqualToString:@"iPhone Simulator"]) {
                    type = @"en1";
                }
#endif
                
                if([name isEqualToString:type]) {
                    wifiAddress = addr;
                }
                else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        cellAddress = addr;
                    }

            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}

#pragma mark -
#pragma mark Public methods

/*－－－－－－－－－－－－－－－－－
 是否开启密钥
－－－－－－－－－－－－－－－－－*/
-(BOOL)useSecureDBKey{

    return [self.userDefaults boolForKey:SETTING_USE_SECURE_DB_KEY];
}

-(void)setUseSecureDBKey:(BOOL)vaule{

    [self.userDefaults setBool:vaule forKey:SETTING_USE_SECURE_DB_KEY];
    [self.userDefaults synchronize];
}

/*－－－－－－－－－－－－－－－－－
 DB KEY
－－－－－－－－－－－－－－－－－*/
-(NSString*)secureKey{

    return [self.userDefaults stringForKey:SETTING_SECURE_DB_KEY];
}

-(void)setSecureKey:(NSString *)value{

    [self.userDefaults setObject:value forKey:SETTING_SECURE_DB_KEY];
    [self.userDefaults synchronize];
}

/*－－－－－－－－－－－－－－－－－
 
－－－－－－－－－－－－－－－－－*/
- (NSString *)server{

    return [self.userDefaults stringForKey:SETTING_SERVER];
}

- (void)setServer:(NSString *)value{

    [self.userDefaults setObject:value forKey:SETTING_SERVER];
    [self.userDefaults synchronize];
}

/*－－－－－－－－－－－－－－－－－
 user name
－－－－－－－－－－－－－－－－－*/
- (NSString *)username{

    return [self.userDefaults stringForKey:SETTING_USERNAME];
}
- (void)setUsername:(NSString *)value{

    [self.userDefaults setObject:value forKey:SETTING_USERNAME];
    [self.userDefaults synchronize];
}

/*－－－－－－－－－－－－－－－－－
 password
－－－－－－－－－－－－－－－－－*/
- (NSString *)password{

    return [self.userDefaults stringForKey:SETTING_PASSWORD];
}
- (void)setPassword:(NSString *)value{

    [self.userDefaults setObject:value forKey:SETTING_PASSWORD];
    [self.userDefaults synchronize];
}

- (BOOL)useSelfSignedSSLCertificates{

    return [self.userDefaults boolForKey:SETTING_USE_SELF_SIGNED_CERTIFICATE];
}

- (void)setUseSelfSignedSSLCertificates:(BOOL)value{

    [self.userDefaults setBool:value forKey:SETTING_USE_SELF_SIGNED_CERTIFICATE];
    [self.userDefaults synchronize];
}


//从UserDefaulut获取版本号
- (NSString *)versionNumber
{
    return [self.userDefaults stringForKey:SETTING_VERSION_NUMBER];
}


//保存版本号到UserDefault
- (void)setVersionNumber:(NSString *)value
{
    [self.userDefaults setObject:value forKey:SETTING_VERSION_NUMBER];
    [self.userDefaults synchronize];
}

//从UserDefaulut获取IP地址
- (NSString*)ipString
{
    return [self.userDefaults stringForKey:SETTING_IPSTRING];
}


//保存IP地址到UserDefault
- (void)setIpString:(NSString *)ipString
{
    [self.userDefaults setObject:ipString forKey:SETTING_IPSTRING];
    [self.userDefaults synchronize];
}


//从UserDefaulut获取端口号
-(NSString*)port
{
    return [self.userDefaults stringForKey:SETTING_PORT] ;
}


//保存端口号到UserDefaulut
-(void)setPort:(NSString*)port
{
    [self.userDefaults setObject:port forKey:SETTING_PORT];
    [self.userDefaults synchronize];
}

- (BOOL)cancelSend{
    
    return [self.userDefaults boolForKey:SETTING_CANCEL];
}

- (void)setCancelSend:(BOOL)value{
    
    [self.userDefaults setBool:value forKey:SETTING_CANCEL];
    [self.userDefaults synchronize];
}

- (NSString *)notifyPrefix{
    
    return [self.userDefaults stringForKey:SETTING_NOTIFY_PREFIX];
}

- (void)setNotifyPrefix:(NSString *)value{
    
    [self.userDefaults setObject:value forKey:SETTING_NOTIFY_PREFIX];
    [self.userDefaults synchronize];
}

- (NSString *)deviceToken{
    
    return [self.userDefaults stringForKey:SETTING_DEVICETOKE];
}

- (void)setDeviceToken:(NSString *)value{
    
    [self.userDefaults setObject:value forKey:SETTING_DEVICETOKE];
    [self.userDefaults synchronize];
}

- (NSString*)sendPacket{
    NSString *value = [self.userDefaults stringForKey:SETTING_SEND_PACKET];
    return (value == nil) ? @"" : value ;
}

-(void)setSendPacket:(NSString *)value{
    [self.userDefaults setObject:value forKey:SETTING_SEND_PACKET];
    [self.userDefaults synchronize];
}

- (NSString*)sendPacketTime{
    NSString *value = [self.userDefaults stringForKey:SETTING_SEND_PACKET_TIME];
    return (value == nil) ? @"" : value ;
}

-(void)setSendPacketTime:(NSString *)value{
    [self.userDefaults setObject:value forKey:SETTING_SEND_PACKET_TIME];
    [self.userDefaults synchronize];
}

- (NSString*)receivePacket{
    NSString *value = [self.userDefaults stringForKey:SETTING_RECEIVE_PACKET];
    return (value == nil) ? @"" : value ;
}

-(void)setReceivePacket:(NSString *)value{
    [self.userDefaults setObject:value forKey:SETTING_RECEIVE_PACKET];
    [self.userDefaults synchronize];
}

- (NSString*)receivePacketTime{
    NSString *value = [self.userDefaults stringForKey:SETTING_RECEIVE_PACKET_TIME];
    return (value == nil) ? @"" : value ;
}

-(void)setReceivePacketTime:(NSString *)value{
    [self.userDefaults setObject:value forKey:SETTING_RECEIVE_PACKET_TIME];
    [self.userDefaults synchronize];
}

@end