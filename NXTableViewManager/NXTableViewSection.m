//
//  NXTableViewSection.m
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/1.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import "NXTableViewSection.h"
#import "NXTableViewManager.h"

@interface NXTableViewSection ()

@property (strong, readwrite, nonatomic) NSMutableArray *mutableItems;

@end

@implementation NXTableViewSection

#pragma mark - Initializing
+ (instancetype)section{
    return [[self alloc] init];
}

+ (instancetype)sectionWithHeaderTitle:(NSString *)headerTitle{
    return [[self alloc ] initWithHeaderTitle:headerTitle];
}

+ (instancetype)sectionWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle{
    return [[self alloc] initWithHeaderTitle:headerTitle footerTitle:footerTitle];
}

+ (instancetype)sectionWithHeaderView:(UIView *)headerView{
    return [[self alloc] initWithHeaderView:headerView footerView:nil];
}

+ (instancetype)sectionWithHeaderView:(UIView *)headerView footerView:(UIView *)footerView{
    return [[self alloc] initWithHeaderView:headerView footerView:footerView];
}

- (id)init{
    self = [super init];
    if (self){
        self.mutableItems = [[NSMutableArray alloc] init];
        self.headerHeight = UITableViewAutomaticDimension;
        self.footerHeight = UITableViewAutomaticDimension;
        self.cellTitlePadding = 5;
    }
    return self;
}

- (id)initWithHeaderTitle:(NSString *)headerTitle{
    return [self initWithHeaderTitle:headerTitle footerTitle:nil];
}

- (id)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle{
    self = [self init];
    if (self){
        self.headerTitle = headerTitle;
        self.footerTitle = footerTitle;
    }
    return self;
}

- (id)initWithHeaderView:(UIView *)headerView{
    return [self initWithHeaderView:headerView footerView:nil];
}

- (id)initWithHeaderView:(UIView *)headerView footerView:(UIView *)footerView{
    self = [self init];
    if (self){
        self.headerView = headerView;
        self.footerView = footerView;
    }
    return self;
}

#pragma mark - Reading information

- (NSUInteger)index{
    NXTableViewManager *tableViewManager = self.tableViewManager;
    return [tableViewManager.sections indexOfObject:self];
}

#pragma mark - Managing items
- (NSArray *)items{
    return self.mutableItems;
}

- (void)addItem:(id)item{
    if ([item isKindOfClass:[NXTableViewItem class]]){
        ((NXTableViewItem *)item).section = self;
        [self.mutableItems addObject:item];
    }
}

- (void)addItemsFromArray:(NSArray *)array{
    if ([array.firstObject isKindOfClass:[NXTableViewItem class]]) {
        for (NXTableViewItem *item in array){
            item.section = self;
        }
        [self.mutableItems addObjectsFromArray:array];
    }
}

- (void)insertItem:(id)item atIndex:(NSUInteger)index{
    if ([item isKindOfClass:[NXTableViewItem class]]){
        ((NXTableViewItem *)item).section = self;
        [self.mutableItems insertObject:item atIndex:index];
    }
    
}

- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes{
    if ([items.firstObject isKindOfClass:[NXTableViewItem class]]) {
        for (NXTableViewItem *item in items){
            item.section = self;
        }
        [self.mutableItems insertObjects:items atIndexes:indexes];
    }
}

- (void)removeItem:(id)item inRange:(NSRange)range{
    [self.mutableItems removeObject:item inRange:range];
}

- (void)removeLastItem{
    [self.mutableItems removeLastObject];
}

- (void)removeItemAtIndex:(NSUInteger)index{
    [self.mutableItems removeObjectAtIndex:index];
}

- (void)removeItem:(id)item{
    [self.mutableItems removeObject:item];
}

- (void)removeAllItems{
    [self.mutableItems removeAllObjects];
}

- (void)removeItemIdenticalTo:(id)item inRange:(NSRange)range{
    [self.mutableItems removeObjectIdenticalTo:item inRange:range];
}

- (void)removeItemIdenticalTo:(id)item{
    [self.mutableItems removeObjectIdenticalTo:item];
}

- (void)removeItemsInArray:(NSArray *)otherArray{
    [self.mutableItems removeObjectsInArray:otherArray];
}

- (void)removeItemsInRange:(NSRange)range{
    [self.mutableItems removeObjectsInRange:range];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes{
    [self.mutableItems removeObjectsAtIndexes:indexes];
}

- (void)replaceItemAtIndex:(NSUInteger)index withItem:(id)item{
    if ([item isKindOfClass:[NXTableViewItem class]]){
        ((NXTableViewItem *)item).section = self;
         [self.mutableItems replaceObjectAtIndex:index withObject:item];
    }
}

- (void)replaceItemsWithItemsFromArray:(NSArray *)otherArray{
    [self removeAllItems];
    [self addItemsFromArray:otherArray];
}

- (void)replaceItemsInRange:(NSRange)range withItemsFromArray:(NSArray *)otherArray range:(NSRange)otherRange{
    if ([otherArray.firstObject isKindOfClass:[NXTableViewItem class]]) {
        for (NXTableViewItem *item in otherArray){
            item.section = self;
        }
        [self.mutableItems replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
    }
}

- (void)replaceItemsInRange:(NSRange)range withItemsFromArray:(NSArray *)otherArray{
    if ([otherArray.firstObject isKindOfClass:[NXTableViewItem class]]) {
        for (NXTableViewItem *item in otherArray){
            item.section = self;
        }
        [self.mutableItems replaceObjectsInRange:range withObjectsFromArray:otherArray];
    }
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)items{
    if ([items.firstObject isKindOfClass:[NXTableViewItem class]]) {
        for (NXTableViewItem *item in items){
            item.section = self;
        }
        [self.mutableItems replaceObjectsAtIndexes:indexes withObjects:items];
    }
}

- (void)exchangeItemAtIndex:(NSUInteger)idx1 withItemAtIndex:(NSUInteger)idx2{
    [self.mutableItems exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)sortItemsUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context{
    [self.mutableItems sortUsingFunction:compare context:context];
}

- (void)sortItemsUsingSelector:(SEL)comparator{
    [self.mutableItems sortUsingSelector:comparator];
}

#pragma mark - Manipulating table view section
- (void)reloadSectionWithAnimation:(UITableViewRowAnimation)animation{
    [self.tableViewManager.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.index] withRowAnimation:animation];
}

@end
