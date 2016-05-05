//
//  YTURLSessionDownloadTaskOperationManager.h
//  DownloadDemo
//
//  Created by ken on 15/11/19.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTURLSessionDownloadTaskOperation.h"

@interface YTURLSessionDownloadTaskOperationManager : NSObject
/**
 *   线程池
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

/**
 The network reachability manager. `AFHTTPRequestOperationManager` uses the `sharedManager` by default.
 */
@property (readwrite, nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

+ (instancetype)manager;

/**
 *  set the MaxDownloadCount before operation run
 *
 *  @param count <#count description#>
 */
- (NSArray *)downloadList;

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
                                         downloadProgressBlock:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify))downloadProgressBlock;


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
                                            downloadProgressBlock:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify))downloadProgressBlock;

@end
