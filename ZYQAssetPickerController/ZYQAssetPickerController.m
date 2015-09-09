//
//  ZYQAssetPickerController.m
//  ZYQAssetPickerControllerDemo
//
//  Created by Zhao Yiqi on 13-12-25.
//  Copyright (c) 2013年 heroims. All rights reserved.
//

#import "ZYQAssetPickerController.h"
#import "AppDelegate.h"
#import "SINavigationMenuView.h"
#import "ZYQAssetViewController.h"
#import "ZYQAssetGroupViewController.h"
#import "MeituEditStyleViewController.h"
#import "CLImageEditor.h"


@interface ZYQAssetPickerController ()

//@property (nonatomic, copy) NSArray *indexPathsForSelectedItems;

@end


@implementation ZYQAssetPickerController
@synthesize delegate = delegate;
- (id)init{
    
//    ZYQAssetGroupViewController *groupViewController = [[ZYQAssetGroupViewController alloc] init];
    ZYQAssetViewController *AssetViewController = [[ZYQAssetViewController alloc]init];// alvin
    AssetViewController.isPhotoFromLocal = _isPhotoFromLocal;// alvin 20150909
    if (self = [super initWithRootViewController:AssetViewController]){
        
        _maximumNumberOfSelection      = 9;
        _minimumNumberOfSelection      = 0;
        _assetsFilter                  = [ALAssetsFilter allAssets];
        _showCancelButton              = YES;
        _showEmptyGroups               = NO;
        _selectionFilter               = [NSPredicate predicateWithValue:YES];
        _isFinishDismissViewController = YES;
        _isPhotoFromLocal              = YES;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        self.preferredContentSize=kPopoverContentSize;
#else
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
#endif
        
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:COLOR_NAV_TITLE, UITextAttributeTextColor,nil]];
        self.navigationBar.tintColor = COLOR_NAV_TINTCOLOR;
        self.navigationController.navigationBar.barTintColor = COLOR_NAV_BARTINTCOLOR;
        
    }
    
    return self;
}

// just for reselove the warning by alvin
- (id)init:(MobileBookTransferObject *)model{

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [D_Main_Appdelegate hiddenPreView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
