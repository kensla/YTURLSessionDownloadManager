//
//  DownloadModelDAO.h
//  DownloadDemo
//
//  Created by ken on 15/11/24.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadModel.h"

@interface DownloadModelDAO : NSObject

+ (DownloadModel *)getDownloadModelByUrl:(NSString *)url;

+ (BOOL)addNewDownloadModel:(DownloadModel *)model;

+ (BOOL)updateDownloadModelByUrl:(NSString *)url withResumeData:(NSString *)resumeData;

+ (BOOL)updateDownloadModelByUrl:(NSString *)url withTotalBytesExpectedToWrite:(CGFloat)totalBytesExpectedToWrite totalBytesWritten:(CGFloat)totalBytesWritten bytesWritten:(CGFloat)bytesWritten;

+ (NSArray *)getDownloadModelList;
@end
