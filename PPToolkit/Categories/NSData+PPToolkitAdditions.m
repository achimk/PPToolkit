//
//  NSData+PPToolkitAdditions.m
//  PPToolkit
//
//  Created by Joachim Kret on 06.12.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "NSData+PPToolkitAdditions.h"

#include <CommonCrypto/CommonDigest.h>

static const char pp_base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short pp_base64DecodingTable[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

#pragma mark - NSData (PPToolkitAdditionsInternal)

@interface NSData (PPToolkitAdditionsInternal)
+ (NSString *)pp_stringFromDigest:(uint8_t *)digest length:(int)length;
@end

#pragma mark - NSData (PPToolkitAdditions)

@implementation NSData (PPToolkitAdditions)

#pragma mark Base64

// Adapted from http://www.cocoadev.com/index.pl?BaseSixtyFour
- (NSString *)pp_base64EncodedString {
	const uint8_t *input = self.bytes;
	NSInteger length = self.length;
	
	NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
	
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
			
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
		
        NSInteger index = (i / 3) * 4;
        output[index + 0] = pp_base64EncodingTable[(value >> 18) & 0x3F];
        output[index + 1] = pp_base64EncodingTable[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? pp_base64EncodingTable[(value >> 6) & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? pp_base64EncodingTable[(value >> 0) & 0x3F] : '=';
    }
	
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


// Adapted from http://www.cocoadev.com/index.pl?BaseSixtyFour
+ (NSData *)pp_dataWithBase64String:(NSString *)base64String {
	const char *string = [base64String cStringUsingEncoding:NSASCIIStringEncoding];
	NSInteger inputLength = base64String.length;
	
	if (string == NULL/* || inputLength % 4 != 0*/) {
		return nil;
	}
	
	while (inputLength > 0 && string[inputLength - 1] == '=') {
		inputLength--;
	}
	
	NSInteger outputLength = inputLength * 3 / 4;
	NSMutableData* data = [NSMutableData dataWithLength:outputLength];
	uint8_t *output = data.mutableBytes;
	
	NSInteger inputPoint = 0;
	NSInteger outputPoint = 0;
	while (inputPoint < inputLength) {
		char i0 = string[inputPoint++];
		char i1 = string[inputPoint++];
		char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */
		char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';
		
		output[outputPoint++] = (pp_base64DecodingTable[(int)i0] << 2) | (pp_base64DecodingTable[(int)i1] >> 4);
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((pp_base64DecodingTable[(int)i1] & 0xf) << 4) | (pp_base64DecodingTable[(int)i2] >> 2);
		}
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((pp_base64DecodingTable[(int)i2] & 0x3) << 6) | pp_base64DecodingTable[(int)i3];
		}
	}
	
	return data;
}

#pragma mark Hashing

- (NSString *)pp_MD2Digest {
	uint8_t digest[CC_MD2_DIGEST_LENGTH];
	CC_MD2(self.bytes, (CC_LONG)self.length, digest);
	return [[self class] pp_stringFromDigest:digest length:CC_MD2_DIGEST_LENGTH];
}


- (NSString *)pp_MD4Digest {
	uint8_t digest[CC_MD4_DIGEST_LENGTH];
	CC_MD4(self.bytes, (CC_LONG)self.length, digest);
	return [[self class] pp_stringFromDigest:digest length:CC_MD4_DIGEST_LENGTH];
}


- (NSString *)pp_MD5Digest {
	uint8_t digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5(self.bytes, (CC_LONG)self.length, digest);
	return [[self class] pp_stringFromDigest:digest length:CC_MD5_DIGEST_LENGTH];
}


- (NSString *)pp_SHA1Digest {
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(self.bytes, (CC_LONG)self.length, digest);
	return [[self class] pp_stringFromDigest:digest length:CC_SHA1_DIGEST_LENGTH];
}


- (NSString *)pp_SHA224Digest {
	uint8_t digest[CC_SHA224_DIGEST_LENGTH];
	CC_SHA224(self.bytes, (CC_LONG)self.length, digest);
	return [[self class] pp_stringFromDigest:digest length:CC_SHA224_DIGEST_LENGTH];
}


- (NSString *)pp_SHA256Digest {
	uint8_t digest[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(self.bytes, (CC_LONG)self.length, digest);
	return [[self class] pp_stringFromDigest:digest length:CC_SHA256_DIGEST_LENGTH];
}


- (NSString *)pp_SHA384Digest {
	uint8_t digest[CC_SHA384_DIGEST_LENGTH];
	CC_SHA384(self.bytes, (CC_LONG)self.length, digest);
	return [[self class] pp_stringFromDigest:digest length:CC_SHA384_DIGEST_LENGTH];
}


- (NSString *)pp_SHA512Digest {
	uint8_t digest[CC_SHA512_DIGEST_LENGTH];
	CC_SHA512(self.bytes, (CC_LONG)self.length, digest);
	return [[self class] pp_stringFromDigest:digest length:CC_SHA512_DIGEST_LENGTH];
}


@end

#pragma mark - NSData (PPToolkitAdditionsInternal)

@implementation NSData (PPToolkitAdditionsInternal)

+ (NSString *)pp_stringFromDigest:(uint8_t *)digest length:(int)length {
	NSMutableString * ms = [[NSMutableString alloc] initWithCapacity:length * 2];
	
    for (int i = 0; i < length; i++) {
		[ms appendFormat: @"%02x", (int)digest[i]];
	}
    
	return [ms copy];
}

@end