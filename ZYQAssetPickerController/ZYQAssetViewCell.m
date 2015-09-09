//
//  ZYQAssetViewCell.m
//  MeiTuDemo
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 zhuofeng. All rights reserved.
//

#import "ZYQAssetViewCell.h"
#import "ZYQAssetView.h"
#import "ZYQAssetViewController.h"

@interface ZYQAssetViewCell ()<ZYQAssetViewDelegate>

@end

@class ZYQAssetViewController;

@implementation ZYQAssetViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

// alcin set the cell frame
- (void)bind:(NSArray *)assets selectionFilter:(NSPredicate*)selectionFilter minimumInteritemSpacing:(float)minimumInteritemSpacing minimumLineSpacing:(float)minimumLineSpacing columns:(int)columns assetViewX:(float)assetViewX
{

    for (int i=0; i<assets.count; i++) {

        // alvin 新增
        if (i>((NSInteger)self.contentView.subviews.count-1)) {
            ZYQAssetView *assetView=[[ZYQAssetView alloc] initWithFrame:CGRectMake(assetViewX+(ZYQAssetViewCell_WIDTH+assetViewX)*i, minimumLineSpacing, ZYQAssetViewCell_WIDTH, ZYQAssetViewCell_HEIGHT)];
            [assetView bind:assets[i] selectionFilter:selectionFilter isSeleced:[((ZYQAssetViewController*)_delegate).indexPathsForSelectedItems containsObject:assets[i]]];// 设置图片，初始化tapAssetView.selected = NO;
            assetView.delegate=self;
//                NSLog(@"%@",NSStringFromCGRect(assetView.frame));
            [self.contentView addSubview:assetView];
        }else{ // alvin 滚动刷新的时候
            ((ZYQAssetView*)self.contentView.subviews[i]).frame=CGRectMake(assetViewX+(ZYQAssetViewCell_WIDTH+assetViewX)*(i), minimumLineSpacing, ZYQAssetViewCell_WIDTH, ZYQAssetViewCell_HEIGHT);
            [(ZYQAssetView*)self.contentView.subviews[i] bind:assets[i] selectionFilter:selectionFilter isSeleced:[((ZYQAssetViewController*)_delegate).indexPathsForSelectedItems containsObject:assets[i]]];
        }
        
    }

}

#pragma mark - ZYQAssetView Delegate

-(BOOL)shouldSelectAsset:(ALAsset *)asset
{
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(shouldSelectAsset:)]) {
        return [_delegate shouldSelectAsset:asset];
    }
    return YES;
}

-(void)tapSelectHandle:(BOOL)select asset:(ALAsset *)asset
{
    if (select) {
        if (_delegate!=nil&&[_delegate respondsToSelector:@selector(didSelectAsset:)]) {
            [_delegate didSelectAsset:asset];
        }
    }else{
        if (_delegate!=nil&&[_delegate respondsToSelector:@selector(didDeselectAsset:)]) {
            [_delegate didDeselectAsset:asset];
        }
    }
}

@end


