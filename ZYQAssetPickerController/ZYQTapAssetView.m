//
//  ZYQTapAssetView.m
//  MeiTuDemo
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 zhuofeng. All rights reserved.
//

#import "ZYQTapAssetView.h"

@interface ZYQTapAssetView ()

@property(nonatomic,retain)UIImageView *selectView;

@end

@implementation ZYQTapAssetView

static UIImage *checkedIcon;
static UIColor *selectedColor;
static UIColor *disabledColor;

+ (void)initialize
{
    checkedIcon     = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"ZYQAssetPicker.Bundle/Images/%@@2x.png",(!IS_IOS7) ? @"AssetsPickerChecked~iOS6" : @"AssetsPickerChecked"]]];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    disabledColor   = [UIColor colorWithWhite:1 alpha:0.9];
}

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        _selectView=[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-checkedIcon.size.width, frame.size.height-checkedIcon.size.height, checkedIcon.size.width, checkedIcon.size.height)];
        [self addSubview:_selectView];
    }
    return self;
}

// Alvin 点击cell
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    if (_disabled) {
//        return;
//    }
//
//    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(shouldTap)]) {
//        if (![_delegate shouldTap]&&!_selected) {
//            return;
//        }
//    }
//
//    if ((_selected=!_selected)) {
//        self.backgroundColor=selectedColor;
//        [_selectView setImage:checkedIcon];
//    }
//    else{
//        self.backgroundColor=[UIColor clearColor];
//        [_selectView setImage:nil];
//    }
    
    
    
    // 点击事件
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(touchSelect:)]) {
        // 设置是否显示选中标识
        if (_delegate!=nil && [_delegate respondsToSelector:@selector(shouldTap)]) {
            self.selected = ![_delegate shouldTap];
            [_delegate touchSelect:_selected];
        }else{
            self.selected = _selected;
            [_delegate touchSelect:_selected];
        }
        
    }
}

-(void)setDisabled:(BOOL)disabled{
    _disabled=disabled;
    if (_disabled) {
        self.backgroundColor=disabledColor;
    }
    else{
        self.backgroundColor=[UIColor clearColor];
    }
}

-(void)setSelected:(BOOL)selected{
    if (_disabled) {
        self.backgroundColor=disabledColor;
        [_selectView setImage:nil];
        return;
    }
    
    _selected=selected;
    if (_selected) {
        self.backgroundColor=selectedColor;
        [_selectView setImage:checkedIcon];
    }
    else{
        self.backgroundColor=[UIColor clearColor];
        [_selectView setImage:nil];
    }
}

@end
