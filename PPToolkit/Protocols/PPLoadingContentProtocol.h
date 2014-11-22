//
//  PPLoadingContentProtocol.h
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

typedef enum {
    PPLoadingContentStateUndefined  = 0,
    PPLoadingContentStateNormal,
    PPLoadingContentStateLoading,
    PPLoadingContentStateEmpty,
    PPLoadingContentStateError
} PPLoadingContentState;

@protocol PPLoadingContentProtocol <NSObject>

@required
- (void)setLoadingContentState:(PPLoadingContentState)state;
- (void)setLoadingContentState:(PPLoadingContentState)newState withPreviusState:(PPLoadingContentState)oldState object:(id)object;

@end
