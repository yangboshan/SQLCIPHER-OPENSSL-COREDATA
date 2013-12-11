//
//  XLDataBase.m
//  XLDistributionBoxApp
//
//  1.数据库接口
//
//  2.数据库安全操作接口
//    NOTE:调用此接口后需相应修改FMDB的设置
//
//  Created by JY on 13-7-10.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//

#import "XLDataBase.h"
#import "XLSettingsManager.h"
#import "SynthesizeSingleton.h"

@implementation XLDataBase

SYNTHESIZE_SINGLETON_FOR_CLASS(XLDataBase)

//static FMDatabase *db = nil;

#pragma mark -dataBase


/*－－－－－－－－－－－－－－－－－
 如已存在实例，直接返回之，
 
 否则实例化并打开数据库连接
 －－－－－－－－－－－－－－－－－*/
//-(FMDatabase*)dataBase
//{
//    if (db!=nil) {
//        return db;
//    }
// 
//    NSString *dbPath = [[[XLSettingsManager sharedXLSettingsManager] documentPath]
//                        stringByAppendingPathComponent:
//                        NSLocalizedString(@"DB_NAME", nil)];
//    
//    db = [FMDatabase databaseWithPath:dbPath];
//    
//    if (![db open]) {
//        
//        NSLog(@"failed open db!");
//        
//        return nil;
//    }
//    
//    return db;
//}
#pragma mark -

#pragma mark -secure DB


/*－－－－－－－－－－－－－－－－－
  加密Sqlite数据库，
 
  Sqlcipher + openSS
 －－－－－－－－－－－－－－－－－*/

-(void)encryptDB
{
    
    sqlite3 *unencrypted_DB;
    
    XLSettingsManager *settings = [XLSettingsManager sharedXLSettingsManager];
    
    NSString *dbPath = [[settings documentPath] stringByAppendingPathComponent:NSLocalizedString(@"DB_NAME", nil)];
    
    NSString *secureDbPath = [[settings documentPath] stringByAppendingPathComponent:@"encrypted.sqlite"];
    
    NSString *attaString = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';",
                            secureDbPath,
                            [settings secureKey]];
    
    if (sqlite3_open([dbPath UTF8String], &unencrypted_DB) == SQLITE_OK) {
        
        sqlite3_exec(unencrypted_DB, [attaString UTF8String], NULL, NULL, NULL);
        
        sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
        
        sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
    } else {
    
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
    }
    sqlite3_close(unencrypted_DB);
}


/*－－－－－－－－－－－－－－－－－
  解密Sqlite数据库，
 
  置Key为空
 －－－－－－－－－－－－－－－－－*/

-(void)decryptDB
{
    
    sqlite3 *encrypted_DB;
    
    XLSettingsManager *settings = [XLSettingsManager sharedXLSettingsManager];
    
    NSString *dbPath = [[settings documentPath] stringByAppendingPathComponent:@"encrypted.sqlite"];
    
    NSString *decrypedPath = [[settings documentPath] stringByAppendingPathComponent:@"decrypted.sqlite"];
    
    NSString *pragma = [NSString stringWithFormat:@"PRAGMA key = '%@';",settings.secureKey];
    
    NSString *attaString = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS plaintext KEY '';",decrypedPath];
    
    if (sqlite3_open([dbPath UTF8String], &encrypted_DB) == SQLITE_OK) {
        
        sqlite3_exec(encrypted_DB, [pragma UTF8String], NULL, NULL, NULL);
        
        sqlite3_exec(encrypted_DB, [attaString UTF8String], NULL, NULL, NULL);
        
        sqlite3_exec(encrypted_DB, "SELECT sqlcipher_export('plaintext');", NULL, NULL, NULL);
        
        sqlite3_exec(encrypted_DB, "DETACH DATABASE plaintext;", NULL, NULL, NULL);
        
    } else {
    
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(encrypted_DB));
    }
    sqlite3_close(encrypted_DB);
}
#pragma mark -

@end
