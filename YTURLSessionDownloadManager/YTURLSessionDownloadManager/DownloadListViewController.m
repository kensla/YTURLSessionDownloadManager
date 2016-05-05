//
//  FirstViewController.m
//  DownloadDemo
//
//  Created by ken on 15/11/19.
//  Copyright © 2015年 szhome. All rights reserved.
//

#import "DownloadListViewController.h"
#import "DownloadTableViewCell.h"
#import <Masonry/Masonry.h>
#import "YTURLSessionDownloadTaskOperationManager.h"
#import "YTDownloaderManager.h"
#import <MagicalRecord/MagicalRecord.h>
#import "DownloadModelDAO.h"
static NSString *DownloadCellIdentifier = @"downloadCellIdentifier";
@interface DownloadListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *downloadTableView;
@property (nonatomic, strong) NSMutableArray *downloadUrlList;
@end

@implementation DownloadListViewController


/**
 *  数据表格
 *
 *  @return <#return value description#>
 */
- (UITableView *)downloadTableView {
    if (_downloadTableView == nil) {
        _downloadTableView = ({
            UITableView *downloadTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            downloadTableView.delegate = self;
            downloadTableView.dataSource = self;
            [downloadTableView registerClass:[DownloadTableViewCell class] forCellReuseIdentifier:DownloadCellIdentifier];

            downloadTableView;
        });
    }
    return _downloadTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _downloadUrlList = [DownloadModelDAO getDownloadModelList].mutableCopy;

    [self.view addSubview:self.downloadTableView];
    [self.downloadTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}


#pragma mark - 列表代理方法
#pragma mark - UITableViewDelegate UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _downloadUrlList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DownloadCellIdentifier forIndexPath:indexPath];
    DownloadModel *entity = _downloadUrlList[indexPath.row];
    CGFloat downloadPercentage = 0;
    if (entity.totalBytesExpectedToWrite > 0) {
        downloadPercentage = entity.totalBytesWritten / entity.totalBytesExpectedToWrite;
    }

    cell.progressView.progress = downloadPercentage;
    if (downloadPercentage > 0) {
        cell.speedLabel.text = [NSString stringWithFormat:@"%.0f%%", downloadPercentage * 100];
    }

    cell.urlStr = entity.fileUrl;
    cell.nameLabel.text = entity.fileName;
    cell.tag = indexPath.row;
    __weak typeof(self) weakself = self;
    cell.downloadBlock = ^(NSString *urlStr, NSInteger row) {
        [weakself startDownloadWithURL:urlStr indexPath:row];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


/**
 *  下载文件
 *
 *  @param url   <#url description#>
 *  @param index <#index description#>
 */
- (void)startDownloadWithURL:(NSString *)url indexPath:(NSInteger)index {
    [[YTDownloaderManager manager] startDownloadWithURL:url
        indexPath:index
        downloadState:^(YTURLSessionDownloadTaskOperationState state, NSInteger identify) {

            DownloadTableViewCell *cell = [_downloadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:identify inSection:0]];
            switch (state) {
            case YTURLSessionDownloadTaskOperationExecutingState:
                [cell.stateBtn setTitle:@"下载中" forState:UIControlStateNormal];
                break;
            case YTURLSessionDownloadTaskOperationFinishedState:
                [cell.stateBtn setTitle:@"查看" forState:UIControlStateNormal];
                break;
            case YTURLSessionDownloadTaskOperationReadyState:
                [cell.stateBtn setTitle:@"等待" forState:UIControlStateNormal];
                break;
            case YTURLSessionDownloadTaskOperationCancelState:
                [cell.stateBtn setTitle:@"暂停" forState:UIControlStateNormal];
                break;
            default:
                break;
            }
        }
        downloadProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSInteger identify) {

            CGFloat downloadPercentage = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
            NSString *currentDownloadLen = [NSString stringWithFormat:@"%.1fMB", ((CGFloat)(totalBytesWritten) / k1MB)];
            NSString *totalLen = [NSString stringWithFormat:@"%.1fMB", ((CGFloat)(totalBytesExpectedToWrite) / k1MB)];
            NSLog(@"进度:%.2f, %@/%@ ", downloadPercentage, currentDownloadLen, totalLen);

            DownloadModel *entity = _downloadUrlList[identify];
            entity.totalBytesWritten = totalBytesWritten;
            entity.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
            [_downloadUrlList replaceObjectAtIndex:identify withObject:entity];

            DownloadTableViewCell *cell = [_downloadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:identify inSection:0]];

            cell.progressView.progress = downloadPercentage;
            if (downloadPercentage > 0) {
                cell.speedLabel.text = [NSString stringWithFormat:@"%.0f%%", downloadPercentage * 100];
            }

            cell.urlStr = entity.fileUrl;
            cell.nameLabel.text = entity.fileName;

        }

        downloadCompletionBlock:^(NSError *error, NSURL *fileURL, NSInteger identify){
            //[weakCell.stateBtn setTitle:@"查看" forState:UIControlStateNormal];

        }];
}


@end
