//
//  ViewController.m
//  YTURLSessionDownloadManager
//
//  Created by 钟远科 on 16/5/5.
//  Copyright © 2016年 钟远科. All rights reserved.
//

#import "DownloadListViewController.h"
#import "DownloadModel.h"
#import "DownloadModelDAO.h"
#import "ViewController.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import <Masonry/Masonry.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [[UIButton alloc] init];
    btn.layer.borderColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1].CGColor;
    btn.layer.borderWidth = 1;
    btn.layer.cornerRadius = 5;
    [btn setTitle:@"下载" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 45));
        make.center.equalTo(self.view);
    }];

    [btn bk_addEventHandler:^(id sender) {
        DownloadListViewController *vc = [[DownloadListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
           forControlEvents:UIControlEventTouchUpInside];


    UIButton *btn2 = [[UIButton alloc] init];
    btn2.layer.borderColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1].CGColor;
    btn2.layer.borderWidth = 1;
    btn2.layer.cornerRadius = 5;
    [btn2 setTitle:@"上传" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 45));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(btn.mas_bottom).offset(30);
    }];

    [btn2 bk_addEventHandler:^(id sender) {
        DownloadListViewController *vc = [[DownloadListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
            forControlEvents:UIControlEventTouchUpInside];


    NSArray *downloadUrlList = @[
        @{ @"name": @"QQ_V4.0.4.dmg",
           @"url": @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.4.dmg" },
        @{ @"name": @"QQIntl2.11.exe",
           @"url": @"http://dldir1.qq.com/qqfile/QQIntl/QQi_PC/QQIntl2.11.exe" },
        @{ @"name": @"QQ7.7Light.exe",
           @"url": @"http://dldir1.qq.com/qqfile/qq/QQ7.7Light/14298/QQ7.7Light.exe" },
        @{ @"name": @"mobileqq_android.apk",
           @"url": @"http://113.107.238.16/sqdd.myapp.com/myapp/qqteam/AndroidQQ/mobileqq_android.apk?mkey=564d407772774a84&f=d488&p=.apk" },
        @{ @"name": @"QQ7.8.exe",
           @"url": @"http://dldir1.qq.com/qqfile/qq/QQ7.8/16379/QQ7.8.exe" },
        @{ @"name": @"qq_2013_0_0_2000_s60v3_signed.sisx",
           @"url": @"http://113.107.238.17/softfile.3g.qq.com/msoft/179/1105/91186/qq_2013_0_0_2000_s60v3_signed.sisx?mkey=564d407a72774a84&f=1225&p=.sisx" },
        @{ @"name": @"qq_2013_0_0_1220_s60v5_signed.sisx",
           @"url": @"http://121.15.220.150/softfile.3g.qq.com/msoft/179/1105/91128/qq_2013_0_0_1220_s60v5_signed.sisx?mkey=564d406572774a84&f=1324&p=.sisx" },
        @{ @"name": @"TM2013Preview2.exe",
           @"url": @"http://dldir1.qq.com/qqfile/qq/tm/2013Preview2/10913/TM2013Preview2.exe" },
        @{ @"name": @"QQ_V4.0.6.dmg",
           @"url": @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.6.dmg" },
        @{ @"name": @"TeamTalk-Mac.zip",
           @"url": @"http://s21.mogucdn.com/download/TeamTalk/OpenSource/TeamTalk-Mac.zip" },
        @{ @"name": @"TaiGjailbreak_V110.dmg",
           @"url": @"http://res.taig.com/installer/mac/TaiGjailbreak_V110.dmg" }
    ];

    for (NSDictionary *dict in downloadUrlList) {
        DownloadModel *model = [DownloadModelDAO getDownloadModelByUrl:dict[@"url"]];
        if (!model) {
            model = [[DownloadModel alloc] init];
        }
        model.fileUrl = dict[@"url"];
        model.fileName = dict[@"name"];
        model.resumeData = [[NSData alloc] init];
        [DownloadModelDAO addNewDownloadModel:model];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
