//
//  NSDate+TimeInterval.h
//  MeiTuDemo
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 zhuofeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeInterval)

+ (NSDateComponents *)componetsWithTimeInterval:(NSTimeInterval)timeInterval;
+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval;

@end
