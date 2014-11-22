//
//  PPSegmentedViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 17.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPSwitchViewController.h"

typedef enum {
    PPSegmentedViewControllerPositionTop    = 0,
    PPSegmentedViewControllerPositionBottom
} PPSegmentedViewControllerPosition;

#pragma mark - PPSegmentedViewController

@interface PPSegmentedViewController : PPSwitchViewController {
@protected
    UISegmentedControl      * _segmentedControl;
}

@property (nonatomic, readwrite, strong) IBOutlet UISegmentedControl * segmentedControl;

+ (Class)defaultSegmentedControlClass;
+ (UIEdgeInsets)defaultSegmentedControlEdgeInsets;
+ (PPSegmentedViewControllerPosition)defaultSegmentedViewControllerPosition;

- (IBAction)segmentedControlValueChanged:(id)sender;

@end

#pragma mark - PPSegmentedViewController (SubclassOnly)

@interface PPSegmentedViewController (SublassOnly)

- (CGRect)frameForSegmentedControl;

@end
