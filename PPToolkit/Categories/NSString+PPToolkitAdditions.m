//
//  NSString+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 25.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "NSString+PPToolkitAdditions.h"

#import "NSData+PPToolkitAdditions.h"

#pragma mark - NSString (PPToolkitAdditionsInternal)

@interface NSString (PPToolkitAdditionsInternal)
- (NSData *)pp_prehashData;
@end

#pragma mark - NSString (PPToolkitAdditions)

@implementation NSString (PPToolkitAdditions)

#pragma mark UUID

+ (NSString *)pp_stringWithUUID {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	return (__bridge_transfer NSString *)string;
}

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


- (NSString *)pp_HMACDigestWithKey:(NSString *)key algorithm:(CCHmacAlgorithm)algorithm {
	const char * cKey   = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char * cData  = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
	NSUInteger length = 0;
	switch (algorithm) {
		case kCCHmacAlgSHA1: {
			length = CC_SHA1_DIGEST_LENGTH;
			break;
		}
            
		case kCCHmacAlgMD5: {
			length = CC_MD5_DIGEST_LENGTH;
			break;
		}
            
		case kCCHmacAlgSHA224: {
			length = CC_SHA224_DIGEST_LENGTH;
			break;
		}
            
		case kCCHmacAlgSHA256: {
			length = CC_SHA256_DIGEST_LENGTH;
			break;
		}
            
		case kCCHmacAlgSHA384: {
			length = CC_SHA384_DIGEST_LENGTH;
			break;
		}
            
		case kCCHmacAlgSHA512: {
			length = CC_SHA512_DIGEST_LENGTH;
			break;
		}
	}
    
	if (length == 0) {
		return nil;
	}
    
    unsigned char * digest = malloc(length);
    CCHmac(algorithm, cKey, strlen(cKey), cData, strlen(cData), digest);
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:length * 2];
    for (NSUInteger i = 0; i < length; i++) {
        [string appendFormat:@"%02lx", (unsigned long)digest[i]];
	}
    
	free(digest);
	return string;
}

#pragma mark Trimming

- (NSString *)pp_stringByTrimmingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)pp_stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)pp_stringByTrimmingLeadingWhitespaceAndNewlineCharacters {
    return [self pp_stringByTrimmingLeadingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)pp_stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location+1]; // non-inclusive
}

- (NSString *)pp_stringByTrimmingTrailingWhitespaceAndNewlineCharacters {
    return [self pp_stringByTrimmingTrailingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end

#pragma mark - NSString (PPToolkitAdditionsInternal)

@implementation NSString (PPToolkitAdditionsInternal)

- (NSData *)pp_prehashData {
	const char * cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	return [NSData dataWithBytes:cstr length:self.length];
}

@end
