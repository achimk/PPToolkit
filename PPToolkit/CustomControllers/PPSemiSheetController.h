//
//  PPSemiSheetController.h
//  PPCatalog
//
//  Created by Joachim Kret on 18.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPSheetController.h"

typedef enum {
    PPSheetContainerPositionTop     = 0,
    PPSheetContainerPositionLeft,
    PPSheetContainerPositionBottom,
    PPSheetContainerPositionRight
} PPSheetContainerPosition;

#pragma mark -

@interface PPSemiSheetController : PPSheetController {
@protected
    PPSheetContainerPosition    _containerPosition;
}

@property (nonatomic, readwrite, assign) PPSheetContainerPosition containerPosition;

@end

#pragma mark -

@interface PPSemiSheetController (SubclassOnly)

- (CGRect)showContainerFrameForBounds:(CGRect)bounds andContainerPosition:(PPSheetContainerPosition)containerPosition;
- (CGRect)hideContainerFrameForBounds:(CGRect)bounds andContainerPosition:(PPSheetContainerPosition)containerPosition;

- (CGPoint)showContentOffsetForBounds:(CGRect)bounds andContainerPosition:(PPSheetContainerPosition)containerPosition;
- (CGPoint)hideContentOffsetForBounds:(CGRect)bounds andContainerPosition:(PPSheetContainerPosition)containerPosition;

@end
