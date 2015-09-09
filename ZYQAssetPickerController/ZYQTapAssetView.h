//
//  ZYQTapAssetView.h
//  MeiTuDemo
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 zhuofeng. All rights reserved.
//

// alvin 图片选中状态 图层

#import <UIKit/UIKit.h>

@protocol ZYQTapAssetViewDelegate <NSObject>

-(void)touchSelect:(BOOL)select; // 选中
-(BOOL)shouldTap; // 可否点击

@end

@interface ZYQTapAssetView : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, weak) id<ZYQTapAssetViewDelegate> delegate;

@end

