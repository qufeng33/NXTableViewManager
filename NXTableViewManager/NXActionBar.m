//
//  NXActionBar.m
//  NXTableViewManagerDemo
//
//  Created by 蒋瞿风 on 16/10/2.
//  Copyright © 2016年 nightx. All rights reserved.
//

#import "NXActionBar.h"
#import "NXTableViewManager.h"

@interface NXActionBar ()

@property (strong, readwrite, nonatomic) UISegmentedControl *navigationControl;

@end

@implementation NXActionBar

- (id)initWithDelegate:(id)delegate{
    self = [super init];
    if (self){
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"NXActionBar") style:UIBarButtonItemStylePlain target:self action:@selector(handleActionBarDone:)];
        
        self.navigationControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Previous", @"NXActionBar"), NSLocalizedString(@"Next", @"NXActionBar")]];
        self.navigationControl.momentary = YES;
        [self.navigationControl addTarget:self action:@selector(handleActionBarPreviousNext:) forControlEvents:UIControlEventValueChanged];
        
        [self.navigationControl setDividerImage:[[UIImage alloc] init]
                            forLeftSegmentState:UIControlStateNormal
                              rightSegmentState:UIControlStateNormal
                                     barMetrics:UIBarMetricsDefault];
        
        [self sizeToFit];
        
        UIBarButtonItem *prevNextWrapper = [[UIBarButtonItem alloc] initWithCustomView:self.navigationControl];
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self setItems:@[prevNextWrapper, flexible, doneButton]];
        self.actionBarDelegate = delegate;
    }
    return self;
}

- (void)handleActionBarPreviousNext:(UISegmentedControl *)segmentedControl{
    if ([self.actionBarDelegate respondsToSelector:@selector(actionBar:navigationControlValueChanged:)]){
        [self.actionBarDelegate actionBar:self navigationControlValueChanged:segmentedControl];
    }
}

- (void)handleActionBarDone:(UIBarButtonItem *)doneButtonItem{
    if ([self.actionBarDelegate respondsToSelector:@selector(actionBar:doneButtonPressed:)]){
        [self.actionBarDelegate actionBar:self doneButtonPressed:doneButtonItem];
    }
    
}


@end
