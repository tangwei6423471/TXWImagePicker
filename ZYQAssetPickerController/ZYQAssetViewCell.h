//
//  ZYQAssetViewCell.h
//  MeiTuDemo
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 zhuofeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZYQAssetViewCellDelegate;

@interface ZYQAssetViewCell : UITableViewCell

@property(nonatomic,weak)id<ZYQAssetViewCellDelegate> delegate;

- (void)bind:(NSArray *)assets selectionFilter:(NSPredicate*)selectionFilter minimumInteritemSpacing:(float)minimumInteritemSpacing minimumLineSpacing:(float)minimumLineSpacing columns:(int)columns assetViewX:(float)assetViewX;

@end
@protocol ZYQAssetViewCellDelegate <NSObject>

- (BOOL)shouldSelectAsset:(ALAsset*)asset;// alvin 是否可选中
- (void)didSelectAsset:(ALAsset*)asset;// alvin 选中
- (void)didDeselectAsset:(ALAsset*)asset;// alvin 取消选中

@end
