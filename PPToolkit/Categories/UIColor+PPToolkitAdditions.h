//
//  UIColor+PPToolkitAdditions.h
//  PPToolkit
//
//  Created by Joachim Kret on 07.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

//flat colors
extern const UInt32 PPColorTurquise;
extern const UInt32 PPColorGreenSea;
extern const UInt32 PPColorEmerland;
extern const UInt32 PPColorNephritis;
extern const UInt32 PPColorPeterRiver;
extern const UInt32 PPColorBelizeHole;
extern const UInt32 PPColorAmethyst;
extern const UInt32 PPColorWisteria;
extern const UInt32 PPColorWetAsphalt;
extern const UInt32 PPColorMidnightBlue;
extern const UInt32 PPColorSunflower;
extern const UInt32 PPColorTangerine;
extern const UInt32 PPColorCarrot;
extern const UInt32 PPColorPumpkin;
extern const UInt32 PPColorAlizarin;
extern const UInt32 PPColorPomegranate;
extern const UInt32 PPColorClouds;
extern const UInt32 PPColorSilver;
extern const UInt32 PPColorConcrete;
extern const UInt32 PPColorAsbestos;

#pragma mark -

@interface UIColor (PPToolkitAdditions)

@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) CGFloat red;                        // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat green;                      // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat blue;                       // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat white;                      // Only valid if colorSpaceModel == kCGColorSpaceModelMonochrome
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) UInt32 rgbHex;

- (NSString *)pp_colorSpaceString;

- (NSArray *)pp_arrayFromRGBAComponents;

- (BOOL)pp_red:(CGFloat *)r green:(CGFloat *)g blue:(CGFloat *)b alpha:(CGFloat *)a;

- (UIColor *)pp_colorByLuminanceMapping;

- (UIColor *)pp_colorByMultiplyingByRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor *)pp_colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor *)pp_colorByLighteningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor *)pp_colorByDarkeningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (UIColor *)pp_colorByMultiplyingBy:(CGFloat)f;
- (UIColor *)pp_colorByAdding:(CGFloat)f;
- (UIColor *)pp_colorByLighteningTo:(CGFloat)f;
- (UIColor *)pp_colorByDarkeningTo:(CGFloat)f;

- (UIColor *)pp_colorByMultiplyingByColor:(UIColor *)color;
- (UIColor *)pp_colorByAddingColor:(UIColor *)color;
- (UIColor *)pp_colorByLighteningToColor:(UIColor *)color;
- (UIColor *)pp_colorByDarkeningToColor:(UIColor *)color;

- (NSString *)pp_stringFromColor;
- (NSString *)pp_hexStringFromColor;

+ (UIColor *)pp_randomColor;
+ (UIColor *)pp_colorWithString:(NSString *)stringToConvert;
+ (UIColor *)pp_colorWithRGBHex:(UInt32)hex;
+ (UIColor *)pp_colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha;
+ (UIColor *)pp_colorWithHexString:(NSString *)stringToConvert;

+ (UIColor *)pp_colorWithName:(NSString *)cssColorName;

@end
