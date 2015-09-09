//
//  ZYQAssetPickerController.h
//  ZYQAssetPickerControllerDemo
//
//  Created by Zhao Yiqi on 13-12-25.
//  Copyright (c) 2013年 heroims. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageAddPreView.h"

@protocol ZYQAssetPickerControllerDelegate;

@interface ZYQAssetPickerController : UINavigationController

@property (nonatomic, weak) id <UINavigationControllerDelegate, ZYQAssetPickerControllerDelegate> delegate;

@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

@property (nonatomic, strong) NSArray *indexPathsForSelectedItems;
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;
@property (nonatomic, assign) NSInteger minimumNumberOfSelection;

@property (nonatomic, strong) NSPredicate *selectionFilter;

@property (nonatomic, assign) BOOL showCancelButton;

@property (nonatomic, assign) BOOL showEmptyGroups;

@property (nonatomic, assign) BOOL isFinishDismissViewController;

@property (nonatomic, strong) ImageAddPreView    *preView;
@property (nonatomic, strong) UIViewController    *vc;
//@property (nonatomic,strong) NSMutableArray *groups;// alvin
@property (nonatomic,assign) BOOL isPhotoFromLocal; // alvin 20150909 照片读取本地，还是网络拉取

- (id)init:(MobileBookTransferObject *)model;
@end

@protocol ZYQAssetPickerControllerDelegate <NSObject>

@optional
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets;

-(void)assetPickerControllerDidCancel:(ZYQAssetPickerController *)picker;

-(void)assetPickerController:(ZYQAssetPickerController *)picker didSelectAsset:(ALAsset*)asset;

-(void)assetPickerController:(ZYQAssetPickerController *)picker didDeselectAsset:(ALAsset*)asset;

-(void)assetPickerControllerDidMaximum:(ZYQAssetPickerController *)picker;

-(void)assetPickerControllerDidMinimum:(ZYQAssetPickerController *)picker;

- (void)assetPickerCamera:(ZYQAssetPickerController *)picker image:(UIImage *)image;// 拍照回调 alvin

@end


