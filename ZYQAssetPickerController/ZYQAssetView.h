//
//  ZYQAssetView.h
//  MeiTuDemo
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 zhuofeng. All rights reserved.
//

// alvin 图片view

#import <UIKit/UIKit.h>
#import "ZYQTapAssetView.h"
#import "ZYQVideoTitleView.h"

#pragma mark - ZYQAssetView

@protocol ZYQAssetViewDelegate <NSObject>

-(BOOL)shouldSelectAsset:(ALAsset*)asset; // 可否选中
-(void)tapSelectHandle:(BOOL)select asset:(ALAsset*)asset;

@end

@interface ZYQAssetView : UIView
@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, weak) id<ZYQAssetViewDelegate> delegate;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) ZYQVideoTitleView *videoTitle;
@property (nonatomic, retain) ZYQTapAssetView *tapAssetView;

- (void)bind:(ALAsset *)asset selectionFilter:(NSPredicate*)selectionFilter isSeleced:(BOOL)isSeleced;

@end
