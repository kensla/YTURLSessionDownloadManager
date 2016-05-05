//
//  DownloadTableViewCell.m
//  DownloadDemo
//
//  Created by ken on 15/11/19.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import "DownloadTableViewCell.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/BlocksKit+UIKit.h>
@interface DownloadTableViewCell ()
//@property (nonatomic, strong) UILabel *nameLabel;
//@property (nonatomic, strong) UILabel *sizeLabel;
//@property (nonatomic, strong) UILabel *speedLabel;
//@property (nonatomic, strong) UIButton *stateBtn;
//@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation DownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //        self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
        //        self.contentView.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00];
        [self setupView];
        [self setttingViewAtuoLayout];
    }
    return self;
}

- (void)setupView {

    self.nameLabel = [[UILabel alloc] init];
    // self.nameLabel.text = @"QQ_V4.0.4.dmg";
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.nameLabel];

    self.sizeLabel = [[UILabel alloc] init];
    // self.sizeLabel.text = @"49.3M";
    self.sizeLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.sizeLabel];

    self.speedLabel = [[UILabel alloc] init];
    self.speedLabel.text = @"26.23M";
    self.speedLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.speedLabel];

    self.stateBtn = [UIButton new];
    self.stateBtn.layer.borderColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1].CGColor;
    self.stateBtn.layer.borderWidth = 1;
    self.stateBtn.layer.cornerRadius = 5;
    [self.stateBtn setTitle:@"下载" forState:UIControlStateNormal];
    [self.stateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.stateBtn bk_addEventHandler:^(id sender) {
        if (self.downloadBlock) {
            self.downloadBlock(self.urlStr, self.tag);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.stateBtn];


    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.contentView addSubview:self.progressView];
}


- (void)setttingViewAtuoLayout {

    UIView *superView = self.contentView;
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superView.mas_left).offset(10);
        make.top.equalTo(superView.mas_top).offset(10);
        make.right.equalTo(superView.mas_right).offset(-10);
    }];

    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superView.mas_left).offset(10);
        make.right.equalTo(superView.mas_right).offset(-10);
        make.centerY.equalTo(superView.mas_centerY);
    }];

    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superView.mas_left).offset(10);
        make.top.equalTo(self.progressView.mas_bottom).offset(5);
    }];

    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sizeLabel.mas_right).offset(10);
        make.top.equalTo(self.progressView.mas_bottom).offset(5);
    }];

    [self.stateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superView.mas_right).offset(-10);
        make.top.equalTo(superView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(60, 35));
    }];
}

@end
