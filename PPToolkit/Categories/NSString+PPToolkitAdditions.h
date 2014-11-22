//
//  NSString+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 25.09.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

@interface NSString (PPToolkitAdditions)

//UUID
+ (NSString *)pp_stringWithUUID;

//Hashing
- (NSString *)pp_MD2Digest;
- (NSString *)pp_MD4Digest;
- (NSString *)pp_MD5Digest;
- (NSString *)pp_SHA1Digest;
- (NSString *)pp_SHA224Digest;
- (NSString *)pp_SHA256Digest;
- (NSString *)pp_SHA384Digest;
- (NSString *)pp_SHA512Digest;
- (NSString *)pp_HMACDigestWithKey:(NSString *)key algorithm:(CCHmacAlgorithm)algorithm;

//Trimming
- (NSString *)pp_stringByTrimmingWhitespaceAndNewlineCharacters;
- (NSString *)pp_stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)pp_stringByTrimmingLeadingWhitespaceAndNewlineCharacters;
- (NSString *)pp_stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)pp_stringByTrimmingTrailingWhitespaceAndNewlineCharacters;

@end
