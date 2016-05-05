//
//  DownloadTableViewCell.h
//  DownloadDemo
//
//  Created by ken on 15/11/19.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DownloadBlock)(NSString *urlStr, NSInteger row);
@interface DownloadTableViewCell : UITableViewCell
@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, copy) DownloadBlock downloadBlock;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UIButton *stateBtn;
@property (nonatomic, strong) UIProgressView *progressView;
@end
