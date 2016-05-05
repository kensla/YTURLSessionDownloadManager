//
//  DownloadModel.m
//  DownloadDemo
//
//  Created by ken on 15/11/24.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import "DownloadModel.h"


@implementation DownloadModel
- (instancetype)initWithFMResultSet:(FMResultSet *)rs {
    self = [super init];
    if (self) {
        self.fileID = [rs intForColumn:@"fileID"];
        self.fileUrl = [rs stringForColumn:@"fileUrl"];
        self.fileName = [rs stringForColumn:@"fileName"];
        self.fileSavePath = [rs stringForColumn:@"fileSavePath"];
        self.fileSize = [rs doubleForColumn:@"fileSize"];
        self.fileMD5 = [rs stringForColumn:@"fileMD5"];

        NSString *str = [rs stringForColumn:@"resumeData"];
        self.resumeData = (str && [str length] > 0) ? [str dataUsingEncoding:NSUTF8StringEncoding] : nil;
        self.downloadState = [rs intForColumn:@"downloadState"];
        self.totalBytesExpectedToWrite = [rs doubleForColumn:@"totalBytesExpectedToWrite"];
        self.totalBytesWritten = [rs doubleForColumn:@"totalBytesWritten"];
        self.bytesWritten = [rs doubleForColumn:@"bytesWritten"];
    }
    return self;
}

+ (instancetype)dataWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {

    if (self = [super init]) {

        self.fileID = [dictionary[@"fileID"] intValue];
        self.fileUrl = dictionary[@"fileUrl"];
        self.fileName = dictionary[@"fileName"];
        self.fileSavePath = dictionary[@"fileSavePath"];
        self.fileSize = [dictionary[@"fileSize"] floatValue];
        self.fileMD5 = dictionary[@"fileMD5"];
        self.resumeData = [dictionary[@"resumeData"] dataUsingEncoding:NSUTF8StringEncoding];
        self.downloadState = [dictionary[@"downloadState"] floatValue];
        self.totalBytesExpectedToWrite = [dictionary[@"totalBytesExpectedToWrite"] floatValue];
        self.totalBytesWritten = [dictionary[@"totalBytesWritten"] floatValue];
        self.bytesWritten = [dictionary[@"bytesWritten"] floatValue];
    }
    return self;
}
@end
