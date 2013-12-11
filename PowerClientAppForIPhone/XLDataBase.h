//
//  XLDataBase.h
//  XLDistributionBoxApp
//
//  Created by JY on 13-7-10.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

//#import "FMDatabase.h"

@interface XLDataBase : NSObject

+(XLDataBase *)sharedXLDataBase;

/*获取数据库实例*/
//-(FMDatabase*)dataBase;

/*加密数据库*/
-(void)encryptDB;

/*解密数据库*/
-(void)decryptDB;

@end
