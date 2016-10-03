//
//  NXTableViewItem.h
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/1.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NXTableViewSection;

typedef void(^selectionHandler)(id item);
typedef void(^accessoryButtonTapHandler)(id item);
typedef void(^insertionHandler)(id item);
typedef void(^deletionHandler)(id item);
typedef void(^deletionHandlerWithCompletion)(id item,void (^)(void));
typedef BOOL(^moveHandler)(id item, NSIndexPath *sourceIndexPath, NSIndexPath *destinationIndexPath);
typedef void(^moveCompletionHandler)(id item, NSIndexPath *sourceIndexPath, NSIndexPath *destinationIndexPath);
typedef void(^cutHandler)(id item);
typedef void(^copyHandler)(id item);
typedef void(^pasteHandler)(id item);

@interface NXTableViewItem : NSObject

@property (copy  , nonatomic) NSString *title;
@property (copy  , nonatomic) NSString *detailText;
@property (copy  , nonatomic) NSAttributedString *attributedTitle;
@property (copy  , nonatomic) NSAttributedString *attributedDetailText;
@property (strong, nonatomic) UIImage  *image;
@property (strong, nonatomic) UIImage  *highlightedImage;
@property (strong, nonatomic) UIView   *accessoryView;
@property (weak  , nonatomic) NXTableViewSection *section;
@property (copy  , nonatomic) NSString *cellIdentifier;

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) CGFloat estimatedCellHeight;
@property (assign, nonatomic) UITableViewCellStyle cellStyle;
@property (assign, nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (assign, nonatomic) UITableViewCellEditingStyle editingStyle;
@property (assign, nonatomic) UITableViewCellAccessoryType accessoryType;

@property (copy  , nonatomic) selectionHandler selectionHandler;
@property (copy  , nonatomic) accessoryButtonTapHandler accessoryButtonTapHandler;
@property (copy  , nonatomic) insertionHandler insertionHandler;
@property (copy  , nonatomic) deletionHandler deletionHandler;
@property (copy  , nonatomic) deletionHandlerWithCompletion deletionHandlerWithCompletion;
@property (copy  , nonatomic) moveHandler moveHandler;
@property (copy  , nonatomic) moveCompletionHandler moveCompletionHandler;
@property (copy  , nonatomic) cutHandler cutHandler;
@property (copy  , nonatomic) copyHandler copyHandler;
@property (copy  , nonatomic) pasteHandler pasteHandler;

+ (instancetype)item;
+ (instancetype)itemWithTitle:(NSString *)Title;
+ (instancetype)itemWithTitle:(NSString *)Title accessoryType:(UITableViewCellAccessoryType)accessoryType selectionHandler:(selectionHandler)selectionHandler;
+ (instancetype)itemWithTitle:(NSString *)Title accessoryType:(UITableViewCellAccessoryType)accessoryType selectionHandler:(selectionHandler)selectionHandler accessoryButtonTapHandler:(accessoryButtonTapHandler)accessoryButtonTapHandler;

- (id)initWithTitle:(NSString *)Title;
- (id)initWithTitle:(NSString *)Title accessoryType:(UITableViewCellAccessoryType)accessoryType selectionHandler:(selectionHandler)selectionHandler;
- (id)initWithTitle:(NSString *)Title accessoryType:(UITableViewCellAccessoryType)accessoryType selectionHandler:(selectionHandler)selectionHandler accessoryButtonTapHandler:(accessoryButtonTapHandler)accessoryButtonTapHandler;

- (NSIndexPath *)indexPath;

@end
