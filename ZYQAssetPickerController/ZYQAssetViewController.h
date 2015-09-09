//
//  ZYQAssetViewController.h
//  MeiTuDemo
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 zhuofeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYQAssetPickerController.h"

@interface ZYQAssetViewController : UIViewController

// local photo
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *indexPathsForSelectedItems;
@property (nonatomic, strong) UITableView   *tableView;

// network photo
@property (nonatomic,strong) NSArray *netWorkGroup;
@property (nonatomic,assign) BOOL isPhotoFromLocal; // alvin 20150909 照片读取本地，还是网络拉取
@end
