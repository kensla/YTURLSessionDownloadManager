//
//  DownloadModel.h
//  DownloadDemo
//
//  Created by ken on 15/11/24.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FMResultSet.h"

@interface DownloadModel : NSObject
@property (nonatomic, assign) NSInteger fileID;
@property (nonatomic, retain) NSString *fileUrl;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileSavePath;
@property (nonatomic, retain) NSString *fileMD5;
@property (nonatomic, retain) NSData *resumeData;
@property (nonatomic, assign) NSInteger downloadState;
@property (nonatomic, assign) CGFloat fileSize;
@property (nonatomic, assign) CGFloat totalBytesExpectedToWrite;
@property (nonatomic, assign) CGFloat totalBytesWritten;
@property (nonatomic, assign) CGFloat bytesWritten;
- (instancetype)initWithFMResultSet:(FMResultSet *)rs;

+ (instancetype)dataWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
