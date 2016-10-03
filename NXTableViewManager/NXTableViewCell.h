//
//  NXTableViewCell.h
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/1.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXTableViewSection.h"
#import "NXActionBar.h"

@class NXTableViewManager;
@class NXTableViewItem;

@interface NXTableViewCell : UITableViewCell

@property (weak  , readwrite, nonatomic) UITableView *parentTableView;
@property (weak  , readwrite, nonatomic) NXTableViewManager *tableViewManager;

+ (BOOL)canFocus;

@property (strong, readonly , nonatomic) UIResponder *responder;
@property (strong, readonly , nonatomic) NSIndexPath *indexPathForPreviousResponder;
@property (strong, readonly , nonatomic) NSIndexPath *indexPathForNextResponder;
@property (strong, readwrite, nonatomic) NXActionBar *actionBar;

@property (assign, readwrite, nonatomic) NSInteger rowIndex;
@property (assign, readwrite, nonatomic) NSInteger sectionIndex;
@property (weak  , readwrite, nonatomic) NXTableViewSection *section;
@property (strong, readwrite, nonatomic) NXTableViewItem *item;

- (CGFloat)cellHeight;
- (CGFloat)estimatedCellHeight;

- (void)cellDidLoad;
- (void)cellWillAppear;

@end
