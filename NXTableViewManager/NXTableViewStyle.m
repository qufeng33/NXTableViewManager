//
//  NXTableViewStyle.m
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/2.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import "NXTableViewStyle.h"

@implementation NXTableViewStyle

+ (NXTableViewStyle *)globalStyle{
    static NXTableViewStyle *style;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        style = [[NXTableViewStyle alloc] init];
    });
    return style;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.detailTextFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
    return self;
}

@end
