//
//  YTURLSessionDownloadTaskOperationManager.m
//  DownloadDemo
//
//  Created by ken on 15/11/19.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import "YTURLSessionDownloadTaskOperationManager.h"

#define DefaultMaxDownloadCount (1) //默认最大并发下载数量

@interface YTURLSessionDownloadTaskOperationManager ()
@property (nonatomic, assign) NSInteger mMaxDownloadCount; //最大下载数
@end

@implementation YTURLSessionDownloadTaskOperationManager

+ (instancetype)manager {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        _operationQueue.maxConcurrentOperationCount = DefaultMaxDownloadCount;
        self.mMaxDownloadCount = DefaultMaxDownloadCount;
    }
    return self;
}


#pragma mark - public Method
/**
 *  get the download operationQueue
 *
 *  @return <#return value description#>
 */
- (NSArray *)downloadList {
    return _operationQueue.operations;
}


/**
 *  set the MaxDownloadCount before operation run
 *
 *  @param count <#count description#>
 */
- (void)setMMaxDownloadCount:(NSInteger)mMaxDownloadCount {
    _mMaxDownloadCount = mMaxDownloadCount;
    _operationQueue.maxConcurrentOperationCount = _mMaxDownloadCount;
}

/**
 *  return the MaxDownloadCount in the operationQueue
 *
 *  @return <#return value description#>
 */
- (NSInteger)maxDownloadCount {
    return _operationQueue.maxConcurrentOperationCount;
}


/**
 *  Creates an `YTURLSessionDownloadTaskOperation`
 *
 *  @param request                 <#request description#>
 *  @param destination             <#destination description#>
 *  @param didStart                <#didStart description#>
 *  @param downloadCompletionBlock <#downloadCompletionBlock description#>
 *  @param downloadProgressBlock   <#downloadProgressBlock description#>
 *
 *  @return <#return value description#>
 */
- (YTURLSessionDownloadTaskOperation *)downloadTaskWithRequest:(NSURLRequest *)request
                                                      identify:(NSInteger)identify
                                                   destination:(NSURL *)destination
                                            downloadStateBlock:(void (^)(YTURLSessionDownloadTaskOperationState state, YTURLSessionDownloadTaskOperation *operation))downloadStateBlock
                                       downloadCompletionBlock:(void (^)(YTURLSessionDownloadTaskOperation *operation, NSError *error, NSURL *fileURL, NSURLResponse *response))downloadCompletionBlock
                                         downloadProgressBlock:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify))downloadProgressBlock {
    YTURLSessionDownloadTaskOperation *operation = nil;
    NSURLSessionConfiguration *config;
    //    NSInteger randomNumber = arc4random() % 1000000;
    //    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
    //        // iOS7 or earlier
    //        config = [NSURLSessionConfiguration backgroundSessionConfiguration:[NSString stringWithFormat:@"com.shenzhenhome.download_%ld", (long)randomNumber]];
    //    } else {
    //        // iOS8 or later
    //        config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"com.shenzhenhome.download_%ld", (long)randomNumber]];
    //    }
    
    config = [NSURLSessionConfiguration defaultSessionConfiguration];
    operation = [[YTURLSessionDownloadTaskOperation alloc] initWithRequest:request targetLocation:destination URLSessionConfiguration:config];
    operation.name = request.URL.absoluteString;
    operation.identify = identify;
    [operation setDownloadStateBlock:downloadStateBlock];
    [operation setDownloadCompletionBlock:downloadCompletionBlock];
    [operation setDownloadProgressBlock:downloadProgressBlock];
    [_operationQueue addOperation:operation];
    return operation;
}

/**
 *  Creates an `YTURLSessionDownloadTaskOperation`
 *
 *  @param resumeData              <#resumeData description#>
 *  @param destination             <#destination description#>
 *  @param didStart                <#didStart description#>
 *  @param downloadCompletionBlock <#downloadCompletionBlock description#>
 *  @param downloadProgressBlock   <#downloadProgressBlock description#>
 *
 *  @return <#return value description#>
 */
- (YTURLSessionDownloadTaskOperation *)downloadTaskWithResumeData:(NSData *)resumeData
                                                         identify:(NSInteger)identify
                                                              url:(NSString *)url
                                                   targetLocation:(NSURL *)destination
                                               downloadStateBlock:(void (^)(YTURLSessionDownloadTaskOperationState state, YTURLSessionDownloadTaskOperation *operation))downloadStateBlock
                                          downloadCompletionBlock:(void (^)(YTURLSessionDownloadTaskOperation *operation, NSError *error, NSURL *fileURL, NSURLResponse *response))downloadCompletionBlock
                                            downloadProgressBlock:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify))downloadProgressBlock {
    YTURLSessionDownloadTaskOperation *operation = nil;
    NSURLSessionConfiguration *config;
    //    NSInteger randomNumber = arc4random() % 1000000;
    //    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
    //        // iOS7 or earlier
    //        config = [NSURLSessionConfiguration backgroundSessionConfiguration:[NSString stringWithFormat:@"com.shenzhenhome.download_%ld", (long)randomNumber]];
    //    } else {
    //        // iOS8 or later
    //        config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"com.shenzhenhome.download_%ld", (long)randomNumber]];
    //    }

    config = [NSURLSessionConfiguration defaultSessionConfiguration];
    operation = [[YTURLSessionDownloadTaskOperation alloc] initWithResumeData:resumeData targetLocation:destination URLSessionConfiguration:config];
    operation.name = url;
    operation.identify = identify;
    [operation setDownloadStateBlock:downloadStateBlock];
    [operation setDownloadCompletionBlock:downloadCompletionBlock];
    [operation setDownloadProgressBlock:downloadProgressBlock];
    [_operationQueue addOperation:operation];
    
    return operation;
}

@end
