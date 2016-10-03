//
//  NXActionBar.h
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/2.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NXActionBarDelegate;

@interface NXActionBar : UIToolbar

@property (strong, readonly , nonatomic) UISegmentedControl *navigationControl;
@property (weak  , readwrite, nonatomic) id<NXActionBarDelegate> actionBarDelegate;

- (id)initWithDelegate:(id)delegate;

@end

@protocol NXActionBarDelegate <NSObject>

- (void)actionBar:(NXActionBar *)actionBar navigationControlValueChanged:(UISegmentedControl *)navigationControl;
- (void)actionBar:(NXActionBar *)actionBar doneButtonPressed:(UIBarButtonItem *)doneButtonItem;

@end
