//
//  CMDEncryptedSQLiteStore.h
//  XLDistributionBoxApp
//
//  Created by JY on 13-7-15.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//

#import <CoreData/CoreData.h>

extern NSString * const CMDEncryptedSQLiteStoreType;
extern NSString * const CMDEncryptedSQLiteStorePassphraseKey;
extern NSString * const CMDEncryptedSQLiteStoreErrorDomain;
extern NSString * const CMDEncryptedSQLiteStoreErrorMessageKey;

@interface CMDEncryptedSQLiteStore : NSIncrementalStore

@end
