//
//  NSArray+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 06.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (PPToolkitAdditions)

//Hashing
- (NSString *)pp_MD2Digest;
- (NSString *)pp_MD4Digest;
- (NSString *)pp_MD5Digest;
- (NSString *)pp_SHA1Digest;
- (NSString *)pp_SHA224Digest;
- (NSString *)pp_SHA256Digest;
- (NSString *)pp_SHA384Digest;
- (NSString *)pp_SHA512Digest;

@end
