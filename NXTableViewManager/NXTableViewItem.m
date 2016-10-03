//
//  NXTableViewItem.m
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/1.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import "NXTableViewItem.h"
#import "NXTableViewManager.h"

@implementation NXTableViewItem

#pragma mark - Initializing
+ (instancetype)item{
    return [[self alloc] init];
}

+ (instancetype)itemWithTitle:(NSString *)title{
    return [[self alloc] initWithTitle:title];
}

+ (instancetype)itemWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType selectionHandler:(selectionHandler)selectionHandler{
    return [[self alloc] initWithTitle:title accessoryType:accessoryType selectionHandler:selectionHandler accessoryButtonTapHandler:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType selectionHandler:(selectionHandler)selectionHandler accessoryButtonTapHandler:(accessoryButtonTapHandler)accessoryButtonTapHandler{
    return [[self alloc] initWithTitle:title accessoryType:accessoryType selectionHandler:selectionHandler accessoryButtonTapHandler:accessoryButtonTapHandler];
}

- (id)initWithTitle:(NSString *)Title{
    self = [self init];
    if (self){
        self.title = Title;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType selectionHandler:(selectionHandler)selectionHandler{
    return [self initWithTitle:title accessoryType:accessoryType selectionHandler:selectionHandler accessoryButtonTapHandler:nil];
}

- (id)initWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType selectionHandler:(selectionHandler)selectionHandler accessoryButtonTapHandler:(accessoryButtonTapHandler)accessoryButtonTapHandler{
    self = [self init];
    if (self){
        self.title = title;
        self.accessoryType = accessoryType;
        self.selectionHandler = selectionHandler;
        self.accessoryButtonTapHandler = accessoryButtonTapHandler;
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self){
        self.enabled             = YES;
        self.cellHeight          = UITableViewAutomaticDimension;
        self.estimatedCellHeight = 44;
        self.cellStyle           = UITableViewCellStyleDefault;
        self.selectionStyle      = UITableViewCellSelectionStyleDefault;
        self.editingStyle        = UITableViewCellEditingStyleNone;
        self.accessoryType       = UITableViewCellAccessoryNone;
    }
    return self;
}

- (NSIndexPath *)indexPath{
    return [NSIndexPath indexPathForRow:[self.section.items indexOfObject:self] inSection:self.section.index];
}

#pragma mark Manipulating table view row
- (void)selectRowAnimated:(BOOL)animated{
    [self selectRowAnimated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (void)selectRowAnimated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition{
    [self.section.tableViewManager.tableView selectRowAtIndexPath:self.indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectRowAnimated:(BOOL)animated{
    [self.section.tableViewManager.tableView deselectRowAtIndexPath:self.indexPath animated:animated];
}

- (void)reloadRowWithAnimation:(UITableViewRowAnimation)animation{
    [self.section.tableViewManager.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:animation];
}

- (void)deleteRowWithAnimation:(UITableViewRowAnimation)animation{
    NXTableViewSection *section = self.section;
    NSInteger row = self.indexPath.row;
    [section removeItemAtIndex:self.indexPath.row];
    [section.tableViewManager.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section.index]] withRowAnimation:animation];
}

@end
