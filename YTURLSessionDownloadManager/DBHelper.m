//
//  DataBaseManager.m
//  Decoration
//
//  Created by ken on 15/8/28.
//  Copyright (c) 2015年 ken. All rights reserved.
//

#import "DBHelper.h"
#import "FMDatabase.h"
#import "DPDatabaseFactory.h"

static DBHelper *shareInstance = nil;
@interface DBHelper ()
/// 路径参数
@property (strong, nonatomic) NSString *databasePath;
/// Targets Name
@property (strong, nonatomic) NSString *bundleName;
/// 数据库
@property (strong, nonatomic) FMDatabase *database;
@end
@implementation DBHelper
#pragma mark - 单例方法

/**
 *  释放
 */
- (void)dealloc {
    self.databasePath = nil;
    self.bundleName = nil;
    self.database = nil;
}

/**
 *  初始化
 *
 *  @return <#return value description#>
 */
- (id)init {
    self = [super init];
    if (self) {
        // sqlite 文件路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirector = [paths objectAtIndex:0];
        self.bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        self.databasePath = [NSString stringWithFormat:@"%@/Application Support/%@/", libraryDirector, self.bundleName];
        self.database = [DPDatabaseFactory sharedDatabaseWithPath:self.databasePath withDatabaseName:[NSString stringWithFormat:@"%@_Data.db", self.bundleName]];
        [self.databaseAccessTemplate beginTransactionInDatabase:self.database
                                                     actionDesc:@"创建表"
                                               withExecuteBlock:^{
                                                   for (NSString *sql in [self createTable]) {
                                                       [self.database executeUpdate:sql];
                                                   }
                                               }];
#if !defined(APPSTORE)
        NSLog(@"[Decoration]/[databasePath]: %@", self.databasePath);
#endif
    }
    return self;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+ (DBHelper *)shareInstance {
    @synchronized(self) {
        if (shareInstance == nil) {
            shareInstance = [[DBHelper alloc] init];
        }
    }
    return shareInstance;
}

/**
 *  <#Description#>
 *
 *  @param zone <#zone description#>
 *
 *  @return <#return value description#>
 */
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (shareInstance == nil) {
            shareInstance = [super allocWithZone:zone];
            return shareInstance;
        }
    }
    return nil;
}

/**
 *  <#Description#>
 *
 *  @param zone <#zone description#>
 *
 *  @return <#return value description#>
 */
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - 公有方法
/**
 *  创建数据库表
 *
 *  @param tableName 表名
 *
 *  @return <#return value description#>
 */

/**
 *  创建表
 *
 *  @return <#return value description#>
 */
- (NSMutableArray *)createTable {
    NSMutableArray *sqlArray = [[NSMutableArray alloc] init];

    NSString *sql = @"create table if not exists DownloadEntity (id integer not null primary key autoincrement, fileID integer , fileUrl text not null, fileName text ,fileSavePath text ,fileSize float ,fileMD5 text ,resumeData text ,downloadState integer , totalBytesExpectedToWrite float, "
        @"totalBytesWritten float , bytesWritten float )";
    [sqlArray addObject:sql];

    return sqlArray;
}

/**
 *  删除数据库表
 *
 *  @param tableName 表名
 *
 *  @return <#return value description#>
 */
- (BOOL)deleteTableWithName:(NSString *)tableName {
    return [self deleteTableWithTableName:tableName inDatabase:self.database];
}

/**
 *  执行数据查询操作，返回用户对象数组
 *
 *  @param querySQL         sql查询语句
 *  @param itemConvertBlock 用于转换FMResultSet成自定义对象的block
 *
 *  @return 自定义对象数组
 */
- (NSArray *)executeQueryWithSql:(NSString *)querySQL itemConvertBlock:(id (^)(FMResultSet *rs))itemConvertBlock {

    return [self executeQueryWithSql:querySQL inDatabase:self.database itemConvertBlock:itemConvertBlock];
}

/**
 *  执行数据库更新操作
 *
 *  @param sql        sql sql语句
 *  @param actionDesc 操作描述，用于打LOG
 *
 *  @return 执行成功或失败
 */
- (BOOL)executeUpdateWithSql:(NSString *)sql actionDesc:(NSString *)actionDesc {
    return [self executeUpdateWithSql:sql inDatabase:self.database actionDesc:actionDesc];
}

/**
 *  打开数据库开启事务，一般用于批量操作
 *
 *  @param sqls       sql语句
 *  @param actionDesc 操作描述，用于打LOG
 */
- (void)beginTransactionWithSqls:(NSArray *)sqls actionDesc:(NSString *)actionDesc {
    [self.databaseAccessTemplate beginTransactionInDatabase:self.database
                                                 actionDesc:actionDesc
                                           withExecuteBlock:^{
                                               for (NSString *sql in sqls) {
                                                   [self.database executeUpdate:sql];
                                               }
                                           }];
}

@end
