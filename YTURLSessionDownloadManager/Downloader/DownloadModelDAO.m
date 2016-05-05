//
//  DownloadModelDAO.m
//  DownloadDemo
//
//  Created by ken on 15/11/24.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import "DownloadModelDAO.h"

#import "DBHelper.h"

@implementation DownloadModelDAO

+ (DownloadModel *)getDownloadModelByUrl:(NSString *)url {

    NSString *sql = [NSString stringWithFormat:@"select * from DownloadEntity where fileUrl = '%@'", url];
    NSArray *models = [[DBHelper shareInstance] executeQueryWithSql:sql
                                                   itemConvertBlock:^id(FMResultSet *rs) {
                                                       DownloadModel *model = [[DownloadModel alloc] initWithFMResultSet:rs];
                                                       return model;
                                                   }];
    return [models firstObject];
}

+ (BOOL)addNewDownloadModel:(DownloadModel *)model {
    if ([self getDownloadModelByUrl:model.fileUrl]) {
        NSString *sql = [NSString stringWithFormat:@"update DownloadEntity set fileID = '%ld',fileUrl = '%@',fileName = '%@',fileSavePath = '%@',fileSize = '%f',fileMD5 ='%@', downloadState = '%ld'  where fileUrl = '%@'", (long)model.fileID, model.fileUrl, model.fileName, model.fileSavePath,
                                                   model.fileSize, model.fileMD5, (long)model.downloadState, model.fileUrl];
        return [[DBHelper shareInstance] executeUpdateWithSql:sql actionDesc:nil];
    } else {
        NSString *sql = [NSString stringWithFormat:@"insert into  DownloadEntity ('fileID','fileUrl','fileName','fileSavePath','fileSize','fileMD5','downloadState') values ('%ld','%@','%@','%@','%f','%@','%ld')", model.fileID, model.fileUrl, model.fileName, model.fileSavePath, model.fileSize,
                                                   model.fileMD5, (long)model.downloadState];
        return [[DBHelper shareInstance] executeUpdateWithSql:sql actionDesc:nil];
    }
}

+ (BOOL)updateDownloadModelByUrl:(NSString *)url withResumeData:(NSString *)resumeData {
    NSString *sql = [NSString stringWithFormat:@"update DownloadEntity set resumeData = '%@' where fileUrl = '%@'", resumeData, url];
    return [[DBHelper shareInstance] executeUpdateWithSql:sql actionDesc:nil];
}

+ (BOOL)updateDownloadModelByUrl:(NSString *)url withTotalBytesExpectedToWrite:(CGFloat)totalBytesExpectedToWrite totalBytesWritten:(CGFloat)totalBytesWritten bytesWritten:(CGFloat)bytesWritten {
    NSString *sql = [NSString stringWithFormat:@"update DownloadEntity set totalBytesExpectedToWrite = '%f',totalBytesWritten = '%f',bytesWritten = '%f' where fileUrl = '%@'", totalBytesExpectedToWrite, totalBytesWritten, bytesWritten, url];
    return [[DBHelper shareInstance] executeUpdateWithSql:sql actionDesc:nil];
}

/**
 *  获取 所有DownloadModel
 *
 *  @return <#return value description#>
 */
+ (NSArray *)getDownloadModelList {
    NSString *sql = [NSString stringWithFormat:@"select * from DownloadEntity"];
    return [[DBHelper shareInstance] executeQueryWithSql:sql
                                        itemConvertBlock:^id(FMResultSet *rs) {
                                            DownloadModel *model = [[DownloadModel alloc] initWithFMResultSet:rs];
                                            return model;
                                        }];
}


@end
