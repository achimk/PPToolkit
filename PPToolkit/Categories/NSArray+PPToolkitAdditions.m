//
//  NSArray+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 06.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "NSArray+PPToolkitAdditions.h"

#import "NSData+PPToolkitAdditions.h"

#pragma mark - NSArray (PPToolkitAdditionsInternal)

@interface NSArray (PPToolkitAdditionsInternal)

- (NSData *)pp_prehashData;

@end

#pragma mark - NSArray (PPToolkitAdditions)

@implementation NSArray (PPToolkitAdditions)

#pragma mark Hashing

- (NSString *)pp_MD2Digest {
	return [[self pp_prehashData] pp_MD2Digest];
}


- (NSString *)pp_MD4Digest {
	return [[self pp_prehashData] pp_MD4Digest];
}


- (NSString *)pp_SHA224Digest {
	return [[self pp_prehashData] pp_SHA224Digest];
}


- (NSString *)pp_SHA384Digest {
	return [[self pp_prehashData] pp_SHA384Digest];
}


- (NSString *)pp_SHA512Digest {
	return [[self pp_prehashData] pp_SHA512Digest];
}


- (NSString *)pp_MD5Digest {
	return [[self pp_prehashData] pp_MD5Digest];
}


- (NSString *)pp_SHA1Digest {
	return [[self pp_prehashData] pp_SHA1Digest];
}


- (NSString *)pp_SHA256Digest {
	return [[self pp_prehashData] pp_SHA256Digest];
}

@end

#pragma mark - NSArray (PPToolkitAdditionsInternal)

@implementation NSArray (PPToolkitAdditionsInternal)

- (NSData *)pp_prehashData {
    return [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:kNilOptions error:nil];
}

@end