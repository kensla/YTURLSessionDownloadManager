//
//  YTDownloaderManager.h
//  DownloadDemo
//
//  Created by ken on 15/11/20.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTURLSessionDownloadTaskOperation.h"
#define kCachePath (NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0])
#define k1MB (1024 * 1024) //一兆
#define kDownloadSpeedDuring (1.5)
@interface YTDownloaderManager : NSObject
+ (instancetype)manager;

/**
 *   开始下载 文件
 *
 *  @param url                     <#url description#>
 *  @param didStartBlock           <#didStartBlock description#>
 *  @param downloadProgressBlock   <#downloadProgressBlock description#>
 *  @param downloadCompletionBlock <#downloadCompletionBlock description#>
 *
 *  @return <#return value description#>
 */
- (YTURLSessionDownloadTaskOperation *)startDownloadWithURL:(NSString *)url
                                                  indexPath:(NSInteger)index
                                              downloadState:(void (^)(YTURLSessionDownloadTaskOperationState state, NSInteger identify))downloadStateBlock
                                      downloadProgressBlock:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify))downloadProgressBlock
                                    downloadCompletionBlock:(void (^)(NSError *error, NSURL *fileURL, NSInteger identify))downloadCompletionBlock;

@end
