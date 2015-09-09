//
//  ZYQAssetViewController.m
//  MeiTuDemo
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 zhuofeng. All rights reserved.
//

#import "ZYQAssetViewController.h"
#import "SINavigationMenuView.h"
#import "ZYQAssetViewCell.h"
#import "CLImageEditor.h"
#import "CLFilterTool.h"
#import "CLStickerTool.h"

@interface ZYQAssetViewController ()<ZYQAssetViewCellDelegate,UITableViewDataSource,UITableViewDelegate,SINavigationMenuDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImageAddPreViewDelegate>{
    int columns;
    
    float minimumInteritemSpacing;
    float minimumLineSpacing;
    
    BOOL unFirst;
}

@property (nonatomic, strong) NSMutableArray *assets;// 相册图片资源
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;
@property (nonatomic, strong) NSMutableArray *itemsArr;// 分组名称
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups; // 相册分组
@property (nonatomic, strong) SINavigationMenuView *menu;// alvin
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, copy) NSString *customerID; // 拉取相册分组列表
@end

#define kAssetViewCellIdentifier           @"AssetViewCellIdentifier"

@implementation ZYQAssetViewController

- (id)init
{
    _indexPathsForSelectedItems=[[NSMutableArray alloc] init];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 2.0, 0, 2.0);
        
        minimumInteritemSpacing=3;
        minimumLineSpacing=3;
        
    }
    else
    {
        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);
        
        minimumInteritemSpacing=2;
        minimumLineSpacing=2;
    }
    
    if (self = [super init])
    {
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
    }

    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.imagePicker = [UIImagePickerController new];
    [self setupViews];
    [self setupButtons];
    [D_Main_Appdelegate preview].delegateSelectImage = self;// 20150909
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_isPhotoFromLocal) {
        if (!unFirst) {
            columns=3;// alvin 获取到各个相册分组
            self.itemsArr = [NSMutableArray array];
            __weak typeof(self)weakSelf = self;
            [self setUpGroupCallback:^(NSMutableArray *groups) {
                DLog(@"%d",groups.count);
                _groups = groups;
                _assetsGroup = self.groups[0];
                [weakSelf setupAssets];
                [weakSelf reloadData];
                
                for (ALAssetsGroup *group in groups) {
                    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                    [weakSelf.itemsArr addObject:name];
                }
                
                [weakSelf initSINavigationMenuViewWithItems:weakSelf.itemsArr];
            }];
            
            unFirst=YES;// alvin
        }
    }else{
        if (!unFirst) {
            columns=3;// alvin 获取到各个相册分组
            // 服务器获取 相册分组名称
            //获取UserDefault
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            self.customerID = [userDefault objectForKey:@"ID"];
            [[GroupAccessor new]getPhotoGroupListByCustomerID:self.customerID callback:^(NSMutableArray *groupListArr) {
                if (!groupListArr) {
                    return;
                }
                self.groups = groupListArr;
                _netWorkGroup = [NSMutableArray array];
                self.itemsArr = [NSMutableArray array];
                _netWorkGroup = self.groups[0];
    //            [self setupAssets];
    //            [self reloadData];
                for (PhotoGroupModel *model in self.groups) {
                    NSString *name = model.name;
                    [self.itemsArr addObject:name];
                }
                [self initSINavigationMenuViewWithItems:self.itemsArr];

            }];
            unFirst=YES;// alvin
        }
    }
    
}

#pragma mark - SINavigationMenuView alvin
- (void)initSINavigationMenuViewWithItems:(NSArray *)items
{
    if (self.navigationItem) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
        self.menu = [[SINavigationMenuView alloc] initWithFrame:frame title:[items firstObject]];
        [self.menu displayMenuInView:self.navigationController.view];
        self.menu.items = items;
        self.menu.delegate = self;
        self.navigationItem.titleView = self.menu;
    }
    
}

- (void)didSelectItemAtIndex:(NSUInteger)index{
    
    if (_isPhotoFromLocal) {
        // navigation menu
        self.menu.menuButton.title.text = [self.itemsArr objectAtIndex:index];
        _assetsGroup = [self.groups objectAtIndex:index];
        [self setupAssets];
        [self reloadData];
    }
    
}

- (void)dismiss:(id)sender
{
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(assetPickerControllerDidCancel:)])
        [picker.delegate assetPickerControllerDidCancel:picker];
    [D_Main_Appdelegate hiddenPreView];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

// Alvin
- (void)cameraAction:(UIButton *)sender
{
    // camera
    void(^blk)() =  ^() {
        UIImagePickerController *picker = self.imagePicker;
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear; // 后置
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        [self.navigationController presentViewController:picker animated:YES completion:^{
            
        }];
    };
    
    ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
    ALAuthorizationStatus authStatus;
    if (IOS_VERSION>=6)
        authStatus = [ALAssetsLibrary authorizationStatus];
    else
        authStatus = ALAuthorizationStatusAuthorized;
    
    if (authStatus == ALAuthorizationStatusAuthorized) {
        blk();
    } else if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
        TTAlertNoTitle(@"请设置授权情感账户使用你的相册");
    } else if (authStatus == ALAuthorizationStatusNotDetermined) {
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // Catch the final iteration, ignore the rest
            if (group == nil)
                dispatch_async(dispatch_get_main_queue(), ^{
                    blk();
                });
            *stop = YES;
        } failureBlock:^(NSError *error) {
            // failure :(
            dispatch_async(dispatch_get_main_queue(), ^{
                TTAlertNoTitle(@"请设置授权情感账户使用你的相册");
            });
        }];
    }
}

// 取消获取系统照片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // 退出系统相册
    [picker dismissViewControllerAnimated:YES completion:^(){
        [D_Main_Appdelegate showPreView];
    }];
}

#pragma mark  UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
        if (vc.delegate && [vc.delegate respondsToSelector:@selector(assetPickerCamera:image:)]) {
            [vc.delegate assetPickerCamera:vc image:image];
        }
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{}

- (void)setUpGroupCallback:(void(^)(NSMutableArray *groups))callbak
{
    NSMutableArray *groups = [NSMutableArray array];
    __block BOOL isFinish = NO;
    if (!self.assetsLibrary)
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
    ALAssetsFilter *assetsFilter = picker.assetsFilter;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group){
            [group setAssetsFilter:assetsFilter];
            if (group.numberOfAssets > 0 || picker.showEmptyGroups){
                [groups addObject:group];
            }
        }else{
            if (isFinish) {
                callbak(groups);
            }else{
                isFinish = YES;
            }
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        callbak(groups);
        [self showNotAllowed];
    };
    
    // Enumerate Camera roll first
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:resultsBlock failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type = ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    [self.assetsLibrary enumerateGroupsWithTypes:type usingBlock:resultsBlock failureBlock:failureBlock];
}

- (void)setupGroup
{
    if (!self.assetsLibrary)
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    
    if (!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
    
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
    ALAssetsFilter *assetsFilter = picker.assetsFilter;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group){
            [group setAssetsFilter:assetsFilter];
            if (group.numberOfAssets > 0 || picker.showEmptyGroups)
                [self.groups addObject:group];
        }else{
            NSLog(@"self.groups.count%d",self.groups.count);
            self.assetsGroup = self.groups[0];
            [self setupAssets];
            [self reloadData];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        [self showNotAllowed];
    };
    
    // Enumerate Camera roll first
//    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
//                                      usingBlock:resultsBlock
//                                    failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type = ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    [self.assetsLibrary enumerateGroupsWithTypes:type usingBlock:resultsBlock failureBlock:failureBlock];
}


#pragma mark - Reload Data

- (void)reloadData
{
    if (self.groups.count == 0)
        [self showNoAssets];
    
    [self.tableView reloadData];
}

#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


#pragma mark - Not allowed / No assets

- (void)showNotAllowed
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
    
    self.title              = nil;
    
    UIImageView *padlock    = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ZYQAssetPicker.Bundle/Images/AssetsPickerLocked@2x.png"]]];
    padlock.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;
    
    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;
    
    title.text              = NSLocalizedString(@"此应用无法使用您的照片或视频。", nil);
    title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedString(@"你可以在「隐私设置」中启用存取。", nil);
    message.font            = [UIFont systemFontOfSize:14.0];
    message.textColor       = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    [title sizeToFit];
    [message sizeToFit];
    
    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:padlock];
    [centerView addSubview:title];
    [centerView addSubview:message];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(padlock, title, message);
    
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:padlock attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[padlock]-[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
    
    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    self.tableView.backgroundView = backgroundView;
}

- (void)showNoAssets
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
    
    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;
    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;
    
    title.text              = NSLocalizedString(@"没有照片或视频。", nil);
    title.font              = [UIFont systemFontOfSize:26.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedString(@"您可以使用 iTunes 将照片和视频\n同步到 iPhone。", nil);
    message.font            = [UIFont systemFontOfSize:18.0];
    message.textColor       = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    [title sizeToFit];
    [message sizeToFit];
    
    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:title];
    [centerView addSubview:message];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(title, message);
    
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:title attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
    
    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    self.tableView.backgroundView = backgroundView;
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);
        
        minimumInteritemSpacing=3;
        minimumLineSpacing=3;
    }else{
        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);
        
        minimumInteritemSpacing=2;
        minimumLineSpacing=2;
    }
    
    //    columns=floor(self.view.frame.size.width/(kThumbnailSize.width+minimumInteritemSpacing));
    columns=3;// alvin
    [self.tableView reloadData];
}

#pragma mark - Setup

- (void)setupViews
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height - (D_ImagePreView_DefaultHeight+44+iOS7AddStatusHeight)) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)setupButtons
{
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
    
    if (picker.showCancelButton){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera"] style:UIBarButtonItemStylePlain target:self action:@selector(cameraAction:)];
    }
}

- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.numberOfPhotos = 0;
    self.numberOfVideos = 0;
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        
        if (asset){
            [self.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
                self.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                self.numberOfVideos ++;
        }else if (self.assets.count > 0){
            [self.tableView reloadData];
            
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ceil(self.assets.count*1.0/3)  inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

#pragma mark - UITableView DataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==ceil(self.assets.count*1.0/3)) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cellFooter"];
        
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellFooter"];
            cell.textLabel.font=[UIFont systemFontOfSize:18];
            cell.textLabel.backgroundColor=[UIColor clearColor];
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
            cell.textLabel.textColor=[UIColor blackColor];
            cell.backgroundColor=[UIColor clearColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        NSString *title;
        
        if (_numberOfVideos == 0)
            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 张照片", nil), (long)_numberOfPhotos];
        else if (_numberOfPhotos == 0)
            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 部视频", nil), (long)_numberOfVideos];
        else
            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 张照片, %ld 部视频", nil), (long)_numberOfPhotos, (long)_numberOfVideos];
        
        cell.textLabel.text=title;
        return cell;
    }
    
    NSMutableArray *tempAssets=[[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        if ((indexPath.row*columns+i)<self.assets.count) {
            [tempAssets addObject:[self.assets objectAtIndex:indexPath.row*columns+i]];
        }
    }
    
    static NSString *CellIdentifier = kAssetViewCellIdentifier;
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
    
    ZYQAssetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[ZYQAssetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate=self;
    
    // 设置cell的宽度
    //    [cell bind:tempAssets selectionFilter:picker.selectionFilter minimumInteritemSpacing:minimumInteritemSpacing minimumLineSpacing:minimumLineSpacing columns:columns assetViewX:(self.tableView.frame.size.width-kThumbnailSize.width*tempAssets.count-minimumInteritemSpacing*(tempAssets.count-1))/2];
    [cell bind:tempAssets selectionFilter:picker.selectionFilter minimumInteritemSpacing:KminimumInteritemSpacing minimumLineSpacing:KminimumLineSpacing columns:3 assetViewX:KminimumInteritemSpacing];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil(self.assets.count*1.0/columns)+1;
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==ceil(self.assets.count*1.0/columns)) {
        return 44;
    }
    //    return kThumbnailSize.height+minimumLineSpacing;
    
    return ZYQAssetViewCell_HEIGHT+KminimumLineSpacing;//alvin
}


#pragma mark - ZYQAssetViewCell Delegate
// 是否可以选中
- (BOOL)shouldSelectAsset:(ALAsset *)asset
{
    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
    BOOL selectable = [vc.selectionFilter evaluateWithObject:asset];
    BOOL canSelectable = [[D_Main_Appdelegate preview].imageassets containsObject:asset];// alvin 终于解决点击选中，点击取消问题
    if (_indexPathsForSelectedItems.count >= vc.maximumNumberOfSelection) {
        if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerControllerDidMaximum:)]) {
            [vc.delegate assetPickerControllerDidMaximum:vc];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:[NSString stringWithFormat:@"最多只能选择%d张图片哦～",vc.maximumNumberOfSelection]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        return YES;
        
    }
    
    return (canSelectable && selectable && _indexPathsForSelectedItems.count < vc.maximumNumberOfSelection);
}

// alvin 选中图片的方法
- (void)didSelectAsset:(ALAsset *)asset
{
    [_indexPathsForSelectedItems addObject:asset];
    
    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
    vc.indexPathsForSelectedItems = _indexPathsForSelectedItems;
    
    if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerController:didSelectAsset:)])
        [vc.delegate assetPickerController:vc didSelectAsset:asset];
    [[D_Main_Appdelegate preview] addImageWith:asset];
//        [self setTitleWithSelectedIndexPaths:_indexPathsForSelectedItems];
}

// alvin 取消选中图片的方法
- (void)didDeselectAsset:(ALAsset *)asset
{
    [_indexPathsForSelectedItems removeObject:asset];
    
    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
    vc.indexPathsForSelectedItems = _indexPathsForSelectedItems;
    
    if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerController:didDeselectAsset:)])
        [vc.delegate assetPickerController:vc didDeselectAsset:asset];
    [[D_Main_Appdelegate preview] deletePintuAction:asset];
    //    [self setTitleWithSelectedIndexPaths:_indexPathsForSelectedItems];
}

#pragma mark - Alvin ImageAddPreViewDelegate
- (void)deletePintuALAsset:(ALAsset *)sender
{
    [self didDeselectAsset:sender];
    [self.tableView reloadData];
}

#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
{
    // Reset title to group name
    if (indexPaths.count == 0)
    {
        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        return;
    }
    
    BOOL photosSelected = NO;
    BOOL videoSelected  = NO;
    
    for (int i=0; i<indexPaths.count; i++) {
        ALAsset *asset = indexPaths[i];
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
            photosSelected  = YES;
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
            videoSelected   = YES;
        
        if (photosSelected && videoSelected)
            break;
        
    }
    
    NSString *format;
    
    if (photosSelected && videoSelected)
        format = NSLocalizedString(@"已选择 %ld 个项目", nil);
    
    else if (photosSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"已选择 %ld 张照片", nil) : NSLocalizedString(@"已选择 %ld 张照片 ", nil);
    
    else if (videoSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"已选择 %ld 部视频", nil) : NSLocalizedString(@"已选择 %ld 部视频 ", nil);
    
    self.title = [NSString stringWithFormat:format, (long)indexPaths.count];
}


#pragma mark - Actions

- (void)finishPickingAssets:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
    //
    //    if (_indexPathsForSelectedItems.count < picker.minimumNumberOfSelection) {
    //        if (picker.delegate!=nil&&[picker.delegate respondsToSelector:@selector(assetPickerControllerDidMaximum:)]) {
    //            [picker.delegate assetPickerControllerDidMaximum:picker];
    //        }
    //    }
    //
    //
    //    if ([picker.delegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)])
    //        [picker.delegate assetPickerController:picker didFinishPickingAssets:_indexPathsForSelectedItems];
    //
    //    if (picker.isFinishDismissViewController) {
    //        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    //    }
}

@end


