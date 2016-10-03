//
//  NXTableViewStyle.h
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/2.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NXTableViewStyle : NSObject

#pragma mark - CellStyle
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIFont *detailTextFont;

@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *detailTextColor;

+ (NXTableViewStyle *)globalStyle;

@end
