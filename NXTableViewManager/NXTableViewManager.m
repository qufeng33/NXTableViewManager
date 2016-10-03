//
//  NXTableViewManager.m
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/1.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import "NXTableViewManager.h"

@interface NXTableViewManager ()

@property (strong, readwrite, nonatomic) NSMutableDictionary *registeredXIBs;
@property (strong, readwrite, nonatomic) NSMutableArray *mutableSections;

@end

@implementation NXTableViewManager

- (id)init{
    @throw [NSException exceptionWithName:NSGenericException reason:@"init not supported, use initWithTableView: instead." userInfo:nil];
    return nil;
}

- (id)initWithTableView:(UITableView *)tableView delegate:(id<NXTableViewManagerDelegate>)delegate{
    self = [self initWithTableView:tableView];
    if (self){
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithTableView:(UITableView *)tableView{
    self = [super init];
    if (self){
        tableView.delegate = self;
        tableView.dataSource = self;
        self.tableView = tableView;
        
        self.mutableSections = [[NSMutableArray alloc] init];
        self.registeredClasses = [[NSMutableDictionary alloc] init];
        self.registeredXIBs = [[NSMutableDictionary alloc] init];
        self.style = [NXTableViewStyle globalStyle];
        
         [self registerDefaultClasses];
    }
   return self;
}

- (void)registerDefaultClasses{
    self[@"NXTableViewItem"] = @"NXTableViewCell";
    
//    self[@"RERadioItem"] = @"RETableViewOptionCell";
//    self[@"REBoolItem"] = @"RETableViewBoolCell";
//    self[@"RETextItem"] = @"RETableViewTextCell";
//    self[@"RELongTextItem"] = @"RETableViewLongTextCell";
//    self[@"RENumberItem"] = @"RETableViewNumberCell";
//    self[@"REFloatItem"] = @"RETableViewFloatCell";
//    self[@"REDateTimeItem"] = @"RETableViewDateTimeCell";
//    self[@"RECreditCardItem"] = @"RETableViewCreditCardCell";
//    self[@"REMultipleChoiceItem"] = @"RETableViewOptionCell";
//    self[@"REPickerItem"] = @"RETableViewPickerCell";
//    self[@"RESegmentedItem"] = @"RETableViewSegmentedCell";
//    self[@"REInlineDatePickerItem"] = @"RETableViewInlineDatePickerCell";
//    self[@"REInlinePickerItem"] = @"RETableViewInlinePickerCell";
}

- (void)registerClass:(NSString *)objectClass forCellWithReuseIdentifier:(NSString *)identifier{
    [self registerClass:objectClass forCellWithReuseIdentifier:identifier bundle:nil];
}

- (void)registerClass:(NSString *)objectClass forCellWithReuseIdentifier:(NSString *)identifier bundle:(NSBundle *)bundle{
    NSAssert(NSClassFromString(objectClass), ([NSString stringWithFormat:@"Item class '%@' does not exist.", objectClass]));
    NSAssert(NSClassFromString(identifier), ([NSString stringWithFormat:@"Cell class '%@' does not exist.", identifier]));
    self.registeredClasses[(id <NSCopying>)NSClassFromString(objectClass)] = NSClassFromString(identifier);
    
    // Perform check if a XIB exists with the same name as the cell class
    //
    if (!bundle)
        bundle = [NSBundle mainBundle];
    
    if ([bundle pathForResource:identifier ofType:@"nib"]) {
        self.registeredXIBs[identifier] = objectClass;
        [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellReuseIdentifier:objectClass];
    }
}

- (id)objectAtKeyedSubscript:(id <NSCopying>)key{
    return [self.registeredClasses objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key{
    [self registerClass:(NSString *)key forCellWithReuseIdentifier:obj];
}

- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath{
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NSObject *item = [section.items objectAtIndex:indexPath.row];
    return [self.registeredClasses objectForKey:item.class];
}

- (NSArray *)sections{
    return self.mutableSections;
}

- (CGFloat)defaultTableViewSectionHeight{
    return self.tableView.style == UITableViewStyleGrouped ? 44 : 22;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.mutableSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex{
    if (self.mutableSections.count <= sectionIndex) {
        return 0;
    }
    return ((NXTableViewSection *)[self.mutableSections objectAtIndex:sectionIndex]).items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    
    UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
    if ([item isKindOfClass:[NXTableViewItem class]]){
        cellStyle = ((NXTableViewItem *)item).cellStyle;
    }
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"NXTableViewManager_%@_%li", [item class], (long) cellStyle];
    
    Class cellClass = [self classForCellAtIndexPath:indexPath];
    
    if (self.registeredXIBs[NSStringFromClass(cellClass)]) {
        cellIdentifier = self.registeredXIBs[NSStringFromClass(cellClass)];
    }
    
    if ([item respondsToSelector:@selector(cellIdentifier)] && item.cellIdentifier) {
        cellIdentifier = item.cellIdentifier;
    }
    
    NXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:cellStyle reuseIdentifier:cellIdentifier];
    }
    
    [cell cellDidLoad];
    
    if ([self.delegate conformsToProtocol:@protocol(NXTableViewManagerDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didLoadCell:forRowAtIndexPath:)]){
        [self.delegate tableView:tableView didLoadCell:cell forRowAtIndexPath:indexPath];
    }
    
    cell.rowIndex = indexPath.row;
    cell.sectionIndex = indexPath.section;
    cell.parentTableView = tableView;
    cell.section = section;
    cell.item = item;
    
    [cell cellWillAppear];
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *titles;
    for (NXTableViewSection *section in self.mutableSections) {
        if (section.indexTitle) {
            titles = [NSMutableArray array];
            break;
        }
    }
    if (titles) {
        for (NXTableViewSection *section in self.mutableSections) {
            [titles addObject:section.indexTitle ? section.indexTitle : @""];
        }
    }
    
    return titles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex{
    if (self.mutableSections.count <= sectionIndex) {
        return nil;
    }
    NXTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    return section.headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionIndex{
    if (self.mutableSections.count <= sectionIndex) {
        return nil;
    }
    NXTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    return section.footerTitle;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NXTableViewSection *sourceSection = [self.mutableSections objectAtIndex:sourceIndexPath.section];
    NXTableViewItem *item = [sourceSection.items objectAtIndex:sourceIndexPath.row];
    [sourceSection removeItemAtIndex:sourceIndexPath.row];
    
    NXTableViewSection *destinationSection = [self.mutableSections objectAtIndex:destinationIndexPath.section];
    [destinationSection insertItem:item atIndex:destinationIndexPath.row];
    
    if (item.moveCompletionHandler)
        item.moveCompletionHandler(item, sourceIndexPath, destinationIndexPath);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.mutableSections.count <= indexPath.section) {
        return NO;
    }
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    return item.moveHandler != nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < [self.mutableSections count]) {
        NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
        if (indexPath.row < [section.items count]) {
            NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
            if ([item isKindOfClass:[NXTableViewItem class]]) {
                return item.editingStyle != UITableViewCellEditingStyleNone || item.moveHandler;
            }
        }
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
        NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
        if (item.deletionHandlerWithCompletion) {
            item.deletionHandlerWithCompletion(item, ^{
                [section removeItemAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                for (NSInteger i = indexPath.row; i < section.items.count; i++) {
                    NXTableViewItem *afterItem = [[section items] objectAtIndex:i];
                    NXTableViewCell *cell = (NXTableViewCell *)[tableView cellForRowAtIndexPath:afterItem.indexPath];
                    cell.rowIndex--;
                }
            });
        } else {
            if (item.deletionHandler)
                item.deletionHandler(item);
            [section removeItemAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            for (NSInteger i = indexPath.row; i < section.items.count; i++) {
                NXTableViewItem *afterItem = [[section items] objectAtIndex:i];
                NXTableViewCell *cell = (NXTableViewCell *)[tableView cellForRowAtIndexPath:afterItem.indexPath];
                cell.rowIndex--;
            }
        }
    }
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
        NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
        if (item.insertionHandler)
            item.insertionHandler(item);
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]){
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)])
        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)])
        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)])
        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)])
        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)])
        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]){
        return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    return [[section.items objectAtIndex:indexPath.row] cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]){
        return [self.delegate tableView:tableView heightForHeaderInSection:sectionIndex];
    }
    
    if (self.mutableSections.count <= sectionIndex) {
        return UITableViewAutomaticDimension;
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    
    if (section.headerHeight != UITableViewAutomaticDimension) {
        return section.headerHeight;
    }
    
    if (section.headerView) {
        return section.headerView.frame.size.height;
    } else if (section.headerTitle.length) {
        if (!UITableViewStyleGrouped) {
            return self.defaultTableViewSectionHeight;
        } else {
            CGFloat headerHeight = 0;
            CGFloat headerWidth = CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 40.0f; // 40 = 20pt horizontal padding on each side
            
            CGSize headerRect = CGSizeMake(headerWidth, UITableViewAutomaticDimension);
            
            CGRect headerFrame = [section.headerTitle boundingRectWithSize:headerRect options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] } context:nil];
        
            headerHeight = headerFrame.size.height;
            
            return headerHeight + 20.0f;
        }
    }

    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)sectionIndex{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]){
        return [self.delegate tableView:tableView heightForFooterInSection:sectionIndex];
    }

    if (self.mutableSections.count <= sectionIndex) {
        return UITableViewAutomaticDimension;
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    
    if (section.footerHeight != UITableViewAutomaticDimension) {
        return section.footerHeight;
    }
    
    if (section.footerView) {
        return section.footerView.frame.size.height;
    } else if (section.footerTitle.length) {
        if (!UITableViewStyleGrouped) {
            return self.defaultTableViewSectionHeight;
        } else {
            CGFloat footerHeight = 0;
            CGFloat footerWidth = CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 40.0f; // 40 = 20pt horizontal padding on each side
            
            CGSize footerRect = CGSizeMake(footerWidth, UITableViewAutomaticDimension);
            
            CGRect footerFrame = [section.footerTitle boundingRectWithSize:footerRect options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] } context:nil];
            
            footerHeight = footerFrame.size.height;
            
            return footerHeight + 10.0f;
        }
    }

    return UITableViewAutomaticDimension;
}

// Estimated height support

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]){
        return [self.delegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    
    if (self.mutableSections.count <= indexPath.section) {
        return UITableViewAutomaticDimension;
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    return [[section.items objectAtIndex:indexPath.row] estimatedCellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]){
        return [self.delegate tableView:tableView viewForHeaderInSection:sectionIndex];
    }
    
    if (self.mutableSections.count <= sectionIndex) {
        return nil;
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    return section.headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)sectionIndex{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]){
        return [self.delegate tableView:tableView viewForFooterInSection:sectionIndex];
    }
    
    if (self.mutableSections.count <= sectionIndex) {
        return nil;
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    return section.footerView;
}

// Accessories (disclosures).

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]){
        [self.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    if (item.accessoryButtonTapHandler)
        item.accessoryButtonTapHandler(item);
}

// Selection

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)]){
        return [self.delegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)]){
        [self.delegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)]){
         [self.delegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]){
        return [self.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]){
        return [self.delegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }

    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    if (item.selectionHandler)
        item.selectionHandler(item);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]){
        [self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

// Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]){
        return [self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    return item.editingStyle;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]){
        return [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }

    return NSLocalizedString(@"Delete", @"Delete");
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)]){
        return [self.delegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    
    return YES;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)]){
        [self.delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)]){
        [self.delegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

// Moving/reordering

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]){
        return [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    }
    
    NXTableViewSection *sourceSection = [self.mutableSections objectAtIndex:sourceIndexPath.section];
    NXTableViewItem *item = [sourceSection.items objectAtIndex:sourceIndexPath.row];
    if (item.moveHandler) {
        BOOL allowed = item.moveHandler(item, sourceIndexPath, proposedDestinationIndexPath);
        if (!allowed)
            return sourceIndexPath;
    }

    return proposedDestinationIndexPath;
}

// Indentation

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)]){
        return [self.delegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    
    return 0;
}

// Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]){
        return [self.delegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    return item.copyHandler || item.pasteHandler;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]){
        return [self.delegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    if (item.copyHandler && action == @selector(copy:)){
        return YES;
    }
    
    if (item.pasteHandler && action == @selector(paste:)){
        return YES;
    }
    
    if (item.cutHandler && action == @selector(cut:)){
        return YES;
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]){
        [self.delegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    
    NXTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NXTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    
    if (action == @selector(copy:) && item.copyHandler) {
        item.copyHandler(item);
        return;
    }
    
    if (action == @selector(paste:) && item.pasteHandler) {
        item.pasteHandler(item);
        return;
    }
    
    if (action == @selector(cut:) && item.cutHandler) {
        item.cutHandler(item);
        return;
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        [self.delegate scrollViewDidScroll:self.tableView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidZoom:)]){
        [self.delegate scrollViewDidZoom:self.tableView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [self.delegate scrollViewWillBeginDragging:self.tableView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]){
        [self.delegate scrollViewWillEndDragging:self.tableView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
        [self.delegate scrollViewDidEndDragging:self.tableView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
        [self.delegate scrollViewWillBeginDecelerating:self.tableView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
        [self.delegate scrollViewDidEndDecelerating:self.tableView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]){
        [self.delegate scrollViewDidEndScrollingAnimation:self.tableView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]){
        return [self.delegate viewForZoomingInScrollView:self.tableView];
    }
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]){
        [self.delegate scrollViewWillBeginZooming:self.tableView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]){
        [self.delegate scrollViewDidEndZooming:self.tableView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]){
        return [self.delegate scrollViewShouldScrollToTop:self.tableView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]){
        [self.delegate scrollViewDidScrollToTop:self.tableView];
    }
}

#pragma mark -
#pragma mark Managing sections

- (void)addSection:(NXTableViewSection *)section{
    section.tableViewManager = self;
    [self.mutableSections addObject:section];
}

- (void)addSectionsFromArray:(NSArray *)array{
    for (NXTableViewSection *section in array)
        section.tableViewManager = self;
    [self.mutableSections addObjectsFromArray:array];
}

- (void)insertSection:(NXTableViewSection *)section atIndex:(NSUInteger)index{
    section.tableViewManager = self;
    [self.mutableSections insertObject:section atIndex:index];
}

- (void)insertSections:(NSArray *)sections atIndexes:(NSIndexSet *)indexes{
    for (NXTableViewSection *section in sections)
        section.tableViewManager = self;
    [self.mutableSections insertObjects:sections atIndexes:indexes];
}

- (void)removeSection:(NXTableViewSection *)section{
    [self.mutableSections removeObject:section];
}

- (void)removeAllSections{
    [self.mutableSections removeAllObjects];
}

- (void)removeSectionIdenticalTo:(NXTableViewSection *)section inRange:(NSRange)range{
    [self.mutableSections removeObjectIdenticalTo:section inRange:range];
}

- (void)removeSectionIdenticalTo:(NXTableViewSection *)section{
    [self.mutableSections removeObjectIdenticalTo:section];
}

- (void)removeSectionsInArray:(NSArray *)otherArray{
    [self.mutableSections removeObjectsInArray:otherArray];
}

- (void)removeSectionsInRange:(NSRange)range{
    [self.mutableSections removeObjectsInRange:range];
}

- (void)removeSection:(NXTableViewSection *)section inRange:(NSRange)range{
    [self.mutableSections removeObject:section inRange:range];
}

- (void)removeLastSection{
    [self.mutableSections removeLastObject];
}

- (void)removeSectionAtIndex:(NSUInteger)index{
    [self.mutableSections removeObjectAtIndex:index];
}

- (void)removeSectionsAtIndexes:(NSIndexSet *)indexes{
    [self.mutableSections removeObjectsAtIndexes:indexes];
}

- (void)replaceSectionAtIndex:(NSUInteger)index withSection:(NXTableViewSection *)section{
    section.tableViewManager = self;
    [self.mutableSections replaceObjectAtIndex:index withObject:section];
}

- (void)replaceSectionsWithSectionsFromArray:(NSArray *)otherArray{
    [self removeAllSections];
    [self addSectionsFromArray:otherArray];
}

- (void)replaceSectionsAtIndexes:(NSIndexSet *)indexes withSections:(NSArray *)sections{
    for (NXTableViewSection *section in sections)
        section.tableViewManager = self;
    [self.mutableSections replaceObjectsAtIndexes:indexes withObjects:sections];
}

- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray *)otherArray range:(NSRange)otherRange{
    for (NXTableViewSection *section in otherArray)
        section.tableViewManager = self;
    [self.mutableSections replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
}

- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray *)otherArray{
    [self.mutableSections replaceObjectsInRange:range withObjectsFromArray:otherArray];
}

- (void)exchangeSectionAtIndex:(NSUInteger)idx1 withSectionAtIndex:(NSUInteger)idx2{
    [self.mutableSections exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)sortSectionsUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context{
    [self.mutableSections sortUsingFunction:compare context:context];
}

- (void)sortSectionsUsingSelector:(SEL)comparator{
    [self.mutableSections sortUsingSelector:comparator];
}


@end
