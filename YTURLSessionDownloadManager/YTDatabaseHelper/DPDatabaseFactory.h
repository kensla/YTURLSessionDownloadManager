//
//  DPDatabaseFactory.h
//  Decoration
//
//  Created by ken on 15/8/28.
//  Copyright (c) 2015年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

/**
 *  创建数据库工厂类
 */
@interface DPDatabaseFactory : NSObject
/**
 *  @brief  获取单例数据库对象
 *
 *  @param path   路径
 *  @param dbName 数据库名称
 *
 *  @return FMDatabase对象
 */
+ (FMDatabase *)sharedDatabaseWithPath:(NSString *)path withDatabaseName:(NSString *)dbName;

/**
 *  @brief  生成一个新的数据库对象
 *
 *  @param path   路径
 *  @param dbName 数据库名称
 *
 *  @return FMDatabase对象
 */
+ (FMDatabase *)newDatabaseWithPath:(NSString *)path withDatabaseName:(NSString *)dbName;

@end
