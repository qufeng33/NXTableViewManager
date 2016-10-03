//
//  NXTableViewManager.h
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/1.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NXTableViewSection.h"
#import "NXTableViewStyle.h"
#import "NXTableViewItem.h"
#import "NXTableViewCell.h"

@protocol NXTableViewManagerDelegate;

@interface NXTableViewManager : NSObject<UITableViewDataSource,UITableViewDelegate>

@property (strong, readonly , nonatomic) NSArray *sections;
@property (weak  , readwrite, nonatomic) UITableView *tableView;
@property (assign, readwrite, nonatomic) id<NXTableViewManagerDelegate> delegate;
@property (strong, readwrite, nonatomic) NSMutableDictionary *registeredClasses;
@property (strong, readwrite, nonatomic) NXTableViewStyle *style;

#pragma mark - register
- (void)registerClass:(NSString *)objectClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(NSString *)objectClass forCellWithReuseIdentifier:(NSString *)identifier bundle:(NSBundle *)bundle;
- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)addSection:(NXTableViewSection *)section;

#pragma mark - Section
- (void)addSectionsFromArray:(NSArray *)array;
- (void)insertSection:(NXTableViewSection *)section atIndex:(NSUInteger)index;
- (void)insertSections:(NSArray *)sections atIndexes:(NSIndexSet *)indexes;
- (void)removeSection:(NXTableViewSection *)section;
- (void)removeAllSections;
- (void)removeSectionIdenticalTo:(NXTableViewSection *)section inRange:(NSRange)range;
- (void)removeSectionIdenticalTo:(NXTableViewSection *)section;
- (void)removeSectionsInArray:(NSArray *)otherArray;
- (void)removeSectionsInRange:(NSRange)range;
- (void)removeSection:(NXTableViewSection *)section inRange:(NSRange)range;
- (void)removeLastSection;
- (void)removeSectionAtIndex:(NSUInteger)index;
- (void)removeSectionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceSectionAtIndex:(NSUInteger)index withSection:(NXTableViewSection *)section;
- (void)replaceSectionsWithSectionsFromArray:(NSArray *)otherArray;
- (void)replaceSectionsAtIndexes:(NSIndexSet *)indexes withSections:(NSArray *)sections;
- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray *)otherArray;
- (void)exchangeSectionAtIndex:(NSUInteger)idx1 withSectionAtIndex:(NSUInteger)idx2;
- (void)sortSectionsUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
- (void)sortSectionsUsingSelector:(SEL)comparator;

@end

@protocol NXTableViewManagerDelegate <UITableViewDelegate>

@optional

- (void)tableView:(UITableView *)tableView willLayoutCellSubviews:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;


- (void)tableView:(UITableView *)tableView didLoadCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
