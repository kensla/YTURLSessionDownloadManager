//
//  YTURLSessionDownloadTaskOperation.h
//  DownloadDemo
//
//  Created by ken on 15/11/19.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"

typedef NS_ENUM(NSInteger, YTURLSessionDownloadTaskOperationState) {
    YTURLSessionDownloadTaskOperationPausedState = -1,
    YTURLSessionDownloadTaskOperationReadyState = 1,
    YTURLSessionDownloadTaskOperationExecutingState = 2,
    YTURLSessionDownloadTaskOperationFinishedState = 3,
    YTURLSessionDownloadTaskOperationCancelState = 4,
};


NS_ASSUME_NONNULL_BEGIN
@interface YTURLSessionDownloadTaskOperation : NSOperation

@property (nonatomic, assign) NSInteger identify;

- (nullable instancetype)initWithRequest:(NSURLRequest *)urlRequest targetLocation:(NSURL *)destination URLSessionConfiguration:(NSURLSessionConfiguration *)config NS_DESIGNATED_INITIALIZER;

/**
 *  断点续传
 *
 *  @param resumeData  <#resumeData description#>
 *  @param destination <#destination description#>
 *
 *  @return <#return value description#>
 */
- (nullable instancetype)initWithResumeData:(NSData *)resumeData targetLocation:(NSURL *)destination URLSessionConfiguration:(NSURLSessionConfiguration *)config NS_DESIGNATED_INITIALIZER;

- (void)pause;
- (void)resume;
- (BOOL)isPaused;
- (BOOL)isExecuting;
/**
 *  中断文件下载
 *
 *  @param completionHandler <#completionHandler description#>
 */
- (void)cancelByProducingResumeData:(void (^)(NSData *__nullable resumeData, YTURLSessionDownloadTaskOperation *operation))completionHandler;


- (void)setDownloadProgressBlock:(nullable void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify))block;

- (void)setDownloadCompletionBlock:(nullable void (^)(YTURLSessionDownloadTaskOperation *_Nullable operation, NSError *_Nullable error, NSURL *_Nullable fileURL, NSURLResponse *_Nullable response))block;

- (void)setDownloadStateBlock:(void (^)(YTURLSessionDownloadTaskOperationState state, YTURLSessionDownloadTaskOperation *operation))block;

@property (readonly, nonatomic, strong, nullable) NSError *error;


extern NSString *const YTURLSessionDownloadTaskOperationDidStartNotification;


extern NSString *const YTURLSessionDownloadTaskOperationDidFinishNotification;

@property (readwrite, nonatomic, assign) YTURLSessionDownloadTaskOperationState state;
@end
NS_ASSUME_NONNULL_END
