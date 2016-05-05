//
//  DataBaseManager.h
//  Decoration
//
//  Created by ken on 15/8/28.
//  Copyright (c) 2015年 ken. All rights reserved.
//

#import "DPCommonDatabaseAccess.h"
@interface DBHelper : DPCommonDatabaseAccess
#pragma mark - 单例公有方法
#pragma mark-- 单例
/**
 *  单例
 *
 *  @return <#return value description#>
 */
+ (DBHelper *)shareInstance;

/**
 *  删除数据库表
 *
 *  @param tableName 表名
 *
 *  @return <#return value description#>
 */
- (BOOL)deleteTableWithName:(NSString *)tableName;

/**
 *  执行数据查询操作，返回用户对象数组
 *
 *  @param querySQL         sql查询语句
 *  @param itemConvertBlock 用于转换FMResultSet成自定义对象的block
 *
 *  @return 自定义对象数组
 */
- (NSArray *)executeQueryWithSql:(NSString *)querySQL itemConvertBlock:(id (^)(FMResultSet *rs))itemConvertBlock;

/**
 *  执行数据库更新操作
 *
 *  @param sql        sql sql语句
 *  @param actionDesc 操作描述，用于打LOG
 *
 *  @return 执行成功或失败
 */
- (BOOL)executeUpdateWithSql:(NSString *)sql actionDesc:(NSString *)actionDesc;

/**
 *  打开数据库开启事务，一般用于批量操作
 *
 *  @param sqls       sql语句
 *  @param actionDesc 操作描述，用于打LOG
 */
- (void)beginTransactionWithSqls:(NSArray *)sqls actionDesc:(NSString *)actionDesc;

@end
