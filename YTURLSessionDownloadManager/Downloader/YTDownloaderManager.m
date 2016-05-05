//
//  YTDownloaderManager.m
//  DownloadDemo
//
//  Created by ken on 15/11/20.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import "YTDownloaderManager.h"
#import "YTURLSessionDownloadTaskOperation.h"
#import "YTURLSessionDownloadTaskOperationManager.h"
#import "DownloadModel.h"
#import "DownloadModelDAO.h"
#define FilePathCreateFailTxt (@"DownloadTaskOperationManager ：文件存储路径创建失败")
#define FilePathErrorTxt (@"DownloadTaskOperationManager ：文件存储路径错误不能为空")
#define DownloadObjectNilTxt (@"下载对象为Nil")

@interface YTDownloaderManager ()
@property (nonatomic, strong) NSMutableArray *cancleDownloadArr; //所取消的下载
@property (nonatomic, strong) YTURLSessionDownloadTaskOperationManager *downloadTaskOperationMgr;


@end

@implementation YTDownloaderManager

static YTDownloaderManager *downloadFileMgr = nil;

+ (instancetype)manager {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        downloadFileMgr = [[YTDownloaderManager alloc] init];
    });
    return downloadFileMgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cancleDownloadArr = [NSMutableArray new];
        _downloadTaskOperationMgr = [YTURLSessionDownloadTaskOperationManager manager];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadTaskOperationDidFinishNotification:) name:YTURLSessionDownloadTaskOperationDidFinishNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];

        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadTaskOperationDidStartNotification:) name:YTURLSessionDownloadTaskOperationDidStartNotification object:nil];
    }
    return self;
}


- (void)appWillTerminate {
    //    for (YTURLSessionDownloadTaskOperation *downloadOperation in _downloadTaskOperationMgr.downloadList) {
    //        if (downloadOperation && downloadOperation.isExecuting) {
    //            [downloadOperation cancelByProducingResumeData:^(NSData *_Nullable resumeData, YTURLSessionDownloadTaskOperation *operation) {
    //                NSLog(@"取消下载!");
    //                NSString *resumeDataStr = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
    //                [DownloadModelDAO updateDownloadModelByUrl:downloadOperation.name withResumeData:resumeDataStr];
    //            }];
    //        }
    //    }
}

- (void)handleDownloadTaskOperationDidStartNotification:(NSNotification *)notify {
    // YTURLSessionDownloadTaskOperation *operation = notify.object;
    // NSLog(@"%@任务开始...", operation.name);
}

- (void)handleDownloadTaskOperationDidFinishNotification:(NSNotification *)notify {
    YTURLSessionDownloadTaskOperation *operation = notify.object;
    if (operation.state != YTURLSessionDownloadTaskOperationFinishedState) {
        [_cancleDownloadArr addObject:operation];
    } else if ([_cancleDownloadArr containsObject:operation]) {
        [_cancleDownloadArr removeObject:operation];
    }
    if (operation.state == YTURLSessionDownloadTaskOperationFinishedState) {
        operation = nil;
    }
}

/**
 *  是否存在取消的下载
 *
 *  @return <#return value description#>
 */
- (BOOL)existCancelDownload {
    return _cancleDownloadArr.count > 0;
}

/**
 *  是否存在需要恢复下载的任务
 *
 *  @param url <#url description#>
 *
 *  @return <#return value description#>
 */
- (DownloadModel *)existCancelDownloadWithUrl:(NSString *)url {
    DownloadModel *model = [DownloadModelDAO getDownloadModelByUrl:url];
    if (model && model.resumeData != nil) {
        return model;
    }
    return nil;
}


/**
 *  返回指定的下载任务
 *
 *  @param url <#url description#>
 *
 *  @return <#return value description#>
 */
- (YTURLSessionDownloadTaskOperation *)downloadOperationWithUrl:(NSString *)url {
    for (YTURLSessionDownloadTaskOperation *operation in _downloadTaskOperationMgr.downloadList) {
        if ([url isEqualToString:operation.name]) {
            return operation;
        }
    }
    return nil;
}


/**
 *  取消下载任务
 *
 *  @param url <#url description#>
 */
- (BOOL)cancelDownloadOperationWithUrl:(NSString *)url {
    YTURLSessionDownloadTaskOperation *downloadOperation = [self downloadOperationWithUrl:url];
    if (downloadOperation && downloadOperation.isExecuting) {
        // 取消 正在下载的任务
        [downloadOperation cancelByProducingResumeData:^(NSData *_Nullable resumeData, YTURLSessionDownloadTaskOperation *operation) {
            NSString *resumeDataStr = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
            [DownloadModelDAO updateDownloadModelByUrl:url withResumeData:resumeDataStr];
        }];
        return YES;
    } else if (downloadOperation) {
        // 取消 等待中的下载任务
        [downloadOperation cancel];
        return YES;
    }
    return NO;
}


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
                                    downloadCompletionBlock:(void (^)(NSError *error, NSURL *fileURL, NSInteger identify))downloadCompletionBlock {

    if ([self cancelDownloadOperationWithUrl:url]) { //取消下载,如果此文件已经在下载则取消下载任务，并返回
        return nil;
    }

    if ([self existCancelDownloadWithUrl:url]) { // 恢复下载,如果此文件已经在下载部分文件，则恢复下载任务，并返回

        DownloadModel *downloadEntity = [DownloadModelDAO getDownloadModelByUrl:url];
        YTURLSessionDownloadTaskOperation *downloadOperation = [self startDownloadWithResumeData:downloadEntity.resumeData indexPath:index url:downloadEntity.fileUrl downloadState:downloadStateBlock downloadProgressBlock:downloadProgressBlock downloadCompletionBlock:downloadCompletionBlock];
        [DownloadModelDAO updateDownloadModelByUrl:url withResumeData:@""];
        return downloadOperation;
    }


    { //下载,开始下载文件
        DownloadModel *model = [DownloadModelDAO getDownloadModelByUrl:url];
        NSString *path = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
        NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
        YTURLSessionDownloadTaskOperation *downloadOperation = [_downloadTaskOperationMgr downloadTaskWithRequest:request
            identify:index
            destination:[NSURL fileURLWithPath:path]
            downloadStateBlock:^(YTURLSessionDownloadTaskOperationState state, YTURLSessionDownloadTaskOperation *operation) {
                NSLog(@"%@任务状态:%ld \n\n", operation.name, (long)state);

                if (downloadStateBlock) {
                    downloadStateBlock(state, operation.identify);
                }
            }
            downloadCompletionBlock:^(YTURLSessionDownloadTaskOperation *operation, NSError *error, NSURL *fileURL, NSURLResponse *response) {
                // NSLog(@"File downloaded to: %@, 下载线程：%lu", fileURL, (unsigned long)[_downloadTaskOperationMgr.downloadList count]);
                [DownloadModelDAO updateDownloadModelByUrl:url withTotalBytesExpectedToWrite:model.totalBytesExpectedToWrite totalBytesWritten:model.totalBytesWritten bytesWritten:model.bytesWritten];

                if (downloadCompletionBlock) {
                    downloadCompletionBlock(error, fileURL, operation.identify);
                }

            }
            downloadProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify) {
                if (downloadProgressBlock) {
                    downloadProgressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, identify);
                }
                model.bytesWritten = bytesWritten;
                model.totalBytesWritten = totalBytesWritten;
                model.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
            }];
        return downloadOperation;
    }
}


/**
 *  开始断点续传
 *
 *  @param resumeData              <#resumeData description#>
 *  @param didStartBlock           <#didStartBlock description#>
 *  @param downloadProgressBlock   <#downloadProgressBlock description#>
 *  @param downloadCompletionBlock <#downloadCompletionBlock description#>
 *
 *  @return <#return value description#>
 */

- (YTURLSessionDownloadTaskOperation *)startDownloadWithResumeData:(NSData *)resumeData
                                                         indexPath:(NSInteger)index
                                                               url:(NSString *)url
                                                     downloadState:(void (^)(YTURLSessionDownloadTaskOperationState state, NSInteger identify))downloadStateBlock
                                             downloadProgressBlock:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify))downloadProgressBlock
                                           downloadCompletionBlock:(void (^)(NSError *error, NSURL *fileURL, NSInteger identify))downloadCompletionBlock {

    DownloadModel *model = [DownloadModelDAO getDownloadModelByUrl:url];
    YTURLSessionDownloadTaskOperation *downloadOperation = nil;
    NSString *path = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    downloadOperation = [_downloadTaskOperationMgr downloadTaskWithResumeData:resumeData
        identify:index
        url:url
        targetLocation:[NSURL fileURLWithPath:path]
        downloadStateBlock:^(YTURLSessionDownloadTaskOperationState state, YTURLSessionDownloadTaskOperation *operation) {
            NSLog(@"任务状态:%ld", (long)state);
            if (downloadStateBlock) {
                downloadStateBlock(state, operation.identify);
            }
        }
        downloadCompletionBlock:^(YTURLSessionDownloadTaskOperation *operation, NSError *error, NSURL *fileURL, NSURLResponse *response) {

            [DownloadModelDAO updateDownloadModelByUrl:url withTotalBytesExpectedToWrite:model.totalBytesExpectedToWrite totalBytesWritten:model.totalBytesWritten bytesWritten:model.bytesWritten];

            if (downloadCompletionBlock) {
                downloadCompletionBlock(error, fileURL, operation.identify);
            }
        }
        downloadProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify) {
            if (downloadProgressBlock) {
                downloadProgressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, identify);
            }
            model.bytesWritten = bytesWritten;
            model.totalBytesWritten = totalBytesWritten;
            model.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
        }];
    return downloadOperation;
}


@end
