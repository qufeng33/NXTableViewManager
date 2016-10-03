//
//  NXTableViewCell.m
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/1.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import "NXTableViewCell.h"
#import "NXTableViewManager.h"

@implementation NXTableViewCell
@synthesize item = _item;

+ (BOOL)canFocus{
    return NO;
}

- (CGFloat)cellHeight{
    if (self.item.cellHeight == 0) {
        return UITableViewAutomaticDimension;
    }else{
        return self.item.cellHeight;
    }
}

- (CGFloat)estimatedCellHeight{
    if (self.item.estimatedCellHeight == 0) {
        return UITableViewAutomaticDimension;
    }else{
        return self.item.estimatedCellHeight;
    }
}

- (void)updateActionBarNavigationControl{
    [self.actionBar.navigationControl setEnabled:[self indexPathForPreviousResponder] != nil forSegmentAtIndex:0];
    [self.actionBar.navigationControl setEnabled:[self indexPathForNextResponder] != nil forSegmentAtIndex:1];
}

- (UIResponder *)responder{
    return nil;
}

- (NSIndexPath *)indexPathForPreviousResponderInSectionIndex:(NSUInteger)sectionIndex{
    NXTableViewSection *section = [self.tableViewManager.sections objectAtIndex:sectionIndex];
    NSUInteger indexInSection =  [section isEqual:self.section] ? [section.items indexOfObject:self.item] : section.items.count;
    for (NSInteger i = indexInSection - 1; i >= 0; i--) {
        NXTableViewItem *item = [section.items objectAtIndex:i];
        if ([item isKindOfClass:[NXTableViewItem class]]) {
            Class class = [self.tableViewManager classForCellAtIndexPath:item.indexPath];
            if ([class canFocus])
                return [NSIndexPath indexPathForRow:i inSection:sectionIndex];
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForPreviousResponder{
    for (NSInteger i = self.sectionIndex; i >= 0; i--) {
        NSIndexPath *indexPath = [self indexPathForPreviousResponderInSectionIndex:i];
        if (indexPath)
            return indexPath;
    }
    return nil;
}

- (NSIndexPath *)indexPathForNextResponderInSectionIndex:(NSUInteger)sectionIndex{
    NXTableViewSection *section = [self.tableViewManager.sections objectAtIndex:sectionIndex];
    NSUInteger indexInSection =  [section isEqual:self.section] ? [section.items indexOfObject:self.item] : -1;
    for (NSInteger i = indexInSection + 1; i < section.items.count; i++) {
        NXTableViewItem *item = [section.items objectAtIndex:i];
        if ([item isKindOfClass:[NXTableViewItem class]]) {
            Class class = [self.tableViewManager classForCellAtIndexPath:item.indexPath];
            if ([class canFocus])
                return [NSIndexPath indexPathForRow:i inSection:sectionIndex];
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForNextResponder{
    for (NSInteger i = self.sectionIndex; i < self.tableViewManager.sections.count; i++) {
        NSIndexPath *indexPath = [self indexPathForNextResponderInSectionIndex:i];
        if (indexPath)
            return indexPath;
    }
    return nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)cellDidLoad{
    
}

- (void)cellWillAppear{
    if ([self.item isKindOfClass:[NXTableViewItem class]]) {
        self.textLabel.attributedText = self.item.attributedTitle;
        self.textLabel.text = self.item.title;
        
        self.detailTextLabel.attributedText = self.item.attributedDetailText;
        self.detailTextLabel.text = self.item.detailText;
        
        self.accessoryType = self.item.accessoryType;
        self.accessoryView = self.item.accessoryView;
        self.selectionStyle = self.item.selectionStyle;
        self.imageView.image = self.item.image;
        self.imageView.highlightedImage = self.item.highlightedImage;
    }
}

#pragma mark - Config Cell
- (void)setupUI{
    self.actionBar = [[NXActionBar alloc] initWithDelegate:self];
    
    NXTableViewStyle *style = [NXTableViewStyle globalStyle];
    self.textLabel.font = style.titleFont?style.titleFont:self.textLabel.font;
    self.detailTextLabel.font = style.detailTextFont?style.detailTextFont:self.detailTextLabel.font;
    self.textLabel.textColor = style.titleColor?style.titleColor:self.textLabel.textColor;
    self.detailTextLabel.textColor = style.detailTextColor?style.detailTextColor:self.detailTextLabel.textColor;
    
    [self cellDidLoad];
}

#pragma mark REActionBar delegate
- (void)actionBar:(NXActionBar *)actionBar navigationControlValueChanged:(UISegmentedControl *)navigationControl{
    NSIndexPath *indexPath = navigationControl.selectedSegmentIndex == 0 ? [self indexPathForPreviousResponder] : [self indexPathForNextResponder];
    if (indexPath) {
        [self.parentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        NXTableViewCell *cell = (NXTableViewCell *)[self.parentTableView cellForRowAtIndexPath:indexPath];
        [cell.responder becomeFirstResponder];
    }
}

- (void)actionBar:(NXActionBar *)actionBar doneButtonPressed:(UIBarButtonItem *)doneButtonItem{
    [self.parentTableView endEditing:YES];
}

@end
