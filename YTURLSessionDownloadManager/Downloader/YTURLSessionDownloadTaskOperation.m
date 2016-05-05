//
//  YTURLSessionDownloadTaskOperation.m
//  DownloadDemo
//
//  Created by ken on 15/11/19.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import "YTURLSessionDownloadTaskOperation.h"
NSString *const YTURLSessionDownloadTaskOperationDidStartNotification = @"com.szhome.urlsessiondownloadtask.operation.start";
NSString *const YTURLSessionDownloadTaskOperationDidFinishNotification = @"com.szhome.urlsessiondownloadtask.operation.finish";
static inline NSString *YTKeyPathFromOperationState(YTURLSessionDownloadTaskOperationState state) {
    switch (state) {
    case YTURLSessionDownloadTaskOperationReadyState:
        return @"isReady";
    case YTURLSessionDownloadTaskOperationExecutingState:
        return @"isExecuting";
    case YTURLSessionDownloadTaskOperationFinishedState:
        return @"isFinished";
    case YTURLSessionDownloadTaskOperationPausedState:
        return @"isPaused";
    default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
        return @"state";
#pragma clang diagnostic pop
    }
    }
}

static inline BOOL YTStateTransitionIsValid(YTURLSessionDownloadTaskOperationState fromState, YTURLSessionDownloadTaskOperationState toState, BOOL isCancelled) {
    switch (fromState) {
    case YTURLSessionDownloadTaskOperationReadyState:
        switch (toState) {
        case YTURLSessionDownloadTaskOperationPausedState:
        case YTURLSessionDownloadTaskOperationExecutingState:
            return YES;
        case YTURLSessionDownloadTaskOperationFinishedState:
            return isCancelled;
        default:
            return NO;
        }
    case YTURLSessionDownloadTaskOperationExecutingState:
        switch (toState) {
        case YTURLSessionDownloadTaskOperationPausedState:
        case YTURLSessionDownloadTaskOperationFinishedState:
        case YTURLSessionDownloadTaskOperationCancelState:
            return YES;
        default:
            return NO;
        }
    case YTURLSessionDownloadTaskOperationFinishedState:
        return NO;
    case YTURLSessionDownloadTaskOperationPausedState:
        return toState == YTURLSessionDownloadTaskOperationReadyState;
    default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
        switch (toState) {
        case YTURLSessionDownloadTaskOperationPausedState:
        case YTURLSessionDownloadTaskOperationReadyState:
        case YTURLSessionDownloadTaskOperationExecutingState:
        case YTURLSessionDownloadTaskOperationFinishedState:
            return YES;
        default:
            return NO;
        }
    }
#pragma clang diagnostic pop
    }
}


/**
 *  <#Description#>
 *
 *  @param bytesWritten              每次写入的data字节数
 *  @param totalBytesWritten         当前一共写入的data字节数
 *  @param totalBytesExpectedToWrite 期望收到的所有data字节数
 *  @param identify                  任务标识
 */
typedef void (^YTURLSessionDownloadTaskOperationProgressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify);
typedef void (^YTURLSessionDownloadTaskOperationProgressBlockCompletionBlock)(YTURLSessionDownloadTaskOperation *operation, NSError *error, NSURL *fileURL, NSURLResponse *response);
typedef void (^YTURLSessionDownloadTaskOperationDownloadStateBlock)(YTURLSessionDownloadTaskOperationState state, YTURLSessionDownloadTaskOperation *operation);

static NSString *const YTURLSessionDownloadTaskOperationLockName = @"com.szhome.urlsessiondownloadtask.operation.lock";

@interface YTURLSessionDownloadTaskOperation ()

@property (readwrite, nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (strong, nonatomic) AFURLSessionManager *manager;

@property (readwrite, nonatomic, strong) NSError *error;

@property (readwrite, nonatomic, strong) NSURLRequest *request;

@property (readwrite, nonatomic, strong) NSData *resumeData;

@property (readwrite, nonatomic, strong) NSURL *saveLocation;

@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@property (readwrite, nonatomic, copy) YTURLSessionDownloadTaskOperationProgressBlock downloadProgress;
@property (readwrite, nonatomic, copy) YTURLSessionDownloadTaskOperationProgressBlockCompletionBlock completion;
@property (readwrite, nonatomic, copy) YTURLSessionDownloadTaskOperationDownloadStateBlock downloadState;


- (void)finish;
@end
@implementation YTURLSessionDownloadTaskOperation
#pragma mark -
- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest targetLocation:(NSURL *)destination URLSessionConfiguration:(NSURLSessionConfiguration *)config {

    NSParameterAssert(urlRequest);
    NSParameterAssert(destination);

    if (self == [super init]) {
        if (!self) {
            return nil;
        }
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
        _state = YTURLSessionDownloadTaskOperationReadyState;
        if (self.downloadState) {
            self.downloadState(self.state, self);
        }
        self.saveLocation = destination;
        self.request = urlRequest;

        [self registerCompletionBlock];
        [self registerDownloadTaskDidWriteDataBlock];

        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = YTURLSessionDownloadTaskOperationLockName;
    }
    return self;
}

- (instancetype)initWithResumeData:(NSData *)resumeData targetLocation:(NSURL *)destination URLSessionConfiguration:(NSURLSessionConfiguration *)config {
    NSParameterAssert(resumeData);
    NSParameterAssert(destination);

    if (self == [super init]) {
        if (!self) {
            return nil;
        }
    }

    _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    _state = YTURLSessionDownloadTaskOperationReadyState;

    if (self.downloadState) {
        self.downloadState(self.state, self);
    }
    self.saveLocation = destination;
    self.resumeData = resumeData;

    [self registerCompletionBlock2];
    [self registerDownloadTaskDidWriteDataBlock];

    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = YTURLSessionDownloadTaskOperationLockName;
    return self;
}


#pragma mark -
- (void)registerCompletionBlock {

    self.downloadTask = [self.manager downloadTaskWithRequest:self.request
        progress:nil
        destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            self.saveLocation = [self.saveLocation URLByAppendingPathComponent:[response suggestedFilename]];
            return self.saveLocation;
        }
        completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [self finish];
            self.error = error;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.completion) {
                    self.completion(self, error, filePath, response);
                }
            });
        }];
}


- (void)registerCompletionBlock2 {
    self.downloadTask = [self.manager downloadTaskWithResumeData:self.resumeData
        progress:nil
        destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
            self.saveLocation = [self.saveLocation URLByAppendingPathComponent:[response suggestedFilename]];
            return self.saveLocation;
        }
        completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
            [self finish];
            self.error = error;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.completion) {
                    self.completion(self, error, filePath, response);
                }
            });
        }];
}


- (void)registerDownloadTaskDidWriteDataBlock {

    __weak typeof(self) weakSelf = self;

    [self.manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *_Nonnull session, NSURLSessionDownloadTask *_Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if (weakSelf.downloadProgress) {
                weakSelf.downloadProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, weakSelf.identify);
            }
        });

    }];
}


#pragma mark -


- (void)setDownloadProgressBlock:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify))block {

    self.downloadProgress = block;
}

- (void)setDownloadCompletionBlock:(void (^)(YTURLSessionDownloadTaskOperation *, NSError *, NSURL *, NSURLResponse *))block {
    self.completion = block;
}

- (void)setDownloadStateBlock:(void (^)(YTURLSessionDownloadTaskOperationState state, YTURLSessionDownloadTaskOperation *operation))block {
    self.downloadState = block;
    self.downloadState(YTURLSessionDownloadTaskOperationReadyState, self);
}

#pragma mark -
- (void)setState:(YTURLSessionDownloadTaskOperationState)state {
    if (!YTStateTransitionIsValid(self.state, state, [self isCancelled])) {
        return;
    }

    [self.lock lock];
    NSString *oldStateKey = YTKeyPathFromOperationState(self.state);
    NSString *newStateKey = YTKeyPathFromOperationState(state);

    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    [self.lock unlock];
}


#pragma mark - NSOperation & Operation Control
- (void)resume {

    if (![self isPaused]) {
        return;
    }

    if (self.downloadTask) {
        [self.lock lock];
        self.state = YTURLSessionDownloadTaskOperationReadyState;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.downloadState) {
                self.downloadState(self.state, self);
            }
        });
        [self start];
        [self.lock unlock];
    }
}


- (void)pause {
    if ([self isPaused] || [self isFinished] || [self isCancelled]) {
        return;
    }

    [self.lock lock];

    if ([self isExecuting]) {

        if (self.downloadTask) {

            [self.downloadTask suspend];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:YTURLSessionDownloadTaskOperationDidFinishNotification object:self];
            });
        }
    }

    self.state = YTURLSessionDownloadTaskOperationPausedState;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.downloadState) {
            self.downloadState(self.state, self);
        }
    });
    [self.lock unlock];
}

- (void)cancel {

    [self.lock lock];
    if (![self isFinished] && ![self isCancelled]) {
        [super cancel];
        if ([self isExecuting]) {
            [self.downloadTask cancel];
            [self finish];
        } else {
            //[self finish];
        }
    }
    [self.lock unlock];
}


/**
 *  中断文件下载
 *
 *  @param completionHandler <#completionHandler description#>
 */
- (void)cancelByProducingResumeData:(void (^)(NSData *__nullable resumeData, YTURLSessionDownloadTaskOperation *operation))completionHandler {

    [self.lock lock];
    if (![self isFinished] && ![self isCancelled]) {
        [super cancel];

        if ([self isExecuting]) {
            [self.downloadTask cancelByProducingResumeData:^(NSData *_Nullable resumeData) {
                if (completionHandler) {
                    completionHandler(resumeData, self);
                }
            }];
            [self finish];
        }
    }
    [self.lock unlock];
}


- (void)start {

    [self.lock lock];
    if ([self isCancelled]) {
        NSLog(@"%@任务取消\n\n", self.name);
        [self finish];
        return;
    } else if ([self isReady]) {
        self.state = YTURLSessionDownloadTaskOperationExecutingState;
        NSLog(@"%@任务开始\n\n", self.name);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:YTURLSessionDownloadTaskOperationDidStartNotification object:self];
            if (self.downloadState) {
                self.downloadState(self.state, self);
            }
        });
        [self.downloadTask resume];
    }

    [self.lock unlock];
}

- (void)finish {

    [self.lock lock];
    self.state = YTURLSessionDownloadTaskOperationFinishedState;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.downloadState) {
            self.downloadState([self isCancelled] ? YTURLSessionDownloadTaskOperationCancelState : self.state, self);
        }
    });
    [self.lock unlock];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:YTURLSessionDownloadTaskOperationDidFinishNotification object:self];
    });
}


- (BOOL)isPaused {
    return self.state == YTURLSessionDownloadTaskOperationPausedState;
}


- (BOOL)isReady {
    return self.state == YTURLSessionDownloadTaskOperationReadyState && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == YTURLSessionDownloadTaskOperationExecutingState;
}

- (BOOL)isFinished {
    return self.state == YTURLSessionDownloadTaskOperationFinishedState;
}

- (BOOL)isConcurrent {
    return YES;
}

@end
