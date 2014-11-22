//
//  PPNavigationController.m
//  PPToolkit
//
//  Created by Joachim Kret on 07.10.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

#import "PPNavigationController.h"

#import "UIScreen+PPToolkitAdditions.h"

#define kDefaultOpacity             0.5f
#define kDefaultAnimationDuration   0.4f

#pragma mark - PPNavigationBar

@interface PPNavigationBar ()
@property (nonatomic, readwrite, strong) CALayer * colorLayer;
@property (nonatomic, readwrite, strong) CAGradientLayer * gradientLayer;
@end

#pragma mark -

@implementation PPNavigationBar

@synthesize colorLayer = _colorLayer;
@synthesize gradientLayer = _gradientLayer;

#pragma mark Accessors

- (void)setCustomBarTintColor:(UIColor *)barTintColor {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        return;
    }

    if (!barTintColor) {
        self.colorLayer = nil;
        return;
    }
    
    if (!self.colorLayer) {
        self.colorLayer = [CALayer layer];
        self.colorLayer.opacity = (self.translucent) ? kDefaultOpacity : 1.0f;
        self.gradientLayer = nil;
    }
    
    self.barTintColor = [UIColor clearColor];
    self.colorLayer.backgroundColor = [barTintColor CGColor];
}

- (void)setCustomBarTintGradientColors:(NSArray *)gradientColors {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        return;
    }

    if (!gradientColors || !gradientColors.count) {
        self.gradientLayer = nil;
        return;
    }

    if (!self.gradientLayer) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.opacity = (self.translucent) ? kDefaultOpacity : 1.0f;
        self.colorLayer = nil;
    }

    NSMutableArray * gradientCGColors = [NSMutableArray arrayWithCapacity:gradientColors.count];
    
    for (id color in gradientColors) {
        if ([color isKindOfClass:[UIColor class]]) {
            [gradientCGColors addObject:(__bridge id)[color CGColor]];
        }
        else {
            [gradientCGColors addObject:color];
        }
    }
    
    self.barTintColor = [UIColor clearColor];
    self.gradientLayer.colors = gradientCGColors;
}

- (void)setColorLayer:(CALayer *)colorLayer {
    if (colorLayer != _colorLayer) {
        if (_colorLayer) {
            [_colorLayer removeFromSuperlayer];
        }
        
        _colorLayer = colorLayer;
        
        if (colorLayer) {
            [self.layer addSublayer:colorLayer];
        }
    }
}

- (void)setGradientLayer:(CAGradientLayer *)gradientLayer {
    if (gradientLayer != _gradientLayer) {
        if (_gradientLayer) {
            [_gradientLayer removeFromSuperlayer];
        }
        
        _gradientLayer = gradientLayer;
        
        if (gradientLayer) {
            [self.layer addSublayer:gradientLayer];
        }
    }
}

- (void)setTranslucent:(BOOL)translucent {
    [super setTranslucent:translucent];
    
    if (self.colorLayer) {
        self.colorLayer.opacity = (translucent) ? kDefaultOpacity : 1.0f;
        [self.colorLayer setNeedsDisplay];
    }
    
    if (self.gradientLayer) {
        self.gradientLayer.opacity = (translucent) ? kDefaultOpacity : 1.0f;
        [self.gradientLayer setNeedsDisplay];
    }
}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (self.colorLayer) {
            CGFloat statusBarHeight = [UIScreen pp_statusBarHeight];
            self.colorLayer.frame = CGRectMake(0.0f, -statusBarHeight, self.bounds.size.width, self.bounds.size.height + statusBarHeight);
            [self.layer insertSublayer:self.colorLayer atIndex:1];
        }
        else if (self.gradientLayer) {
            CGFloat statusBarHeight = [UIScreen pp_statusBarHeight];
            self.gradientLayer.frame = CGRectMake(0.0f, -statusBarHeight, self.bounds.size.width, self.bounds.size.height + statusBarHeight);
            [self.layer insertSublayer:self.gradientLayer atIndex:1];
        }
    }
}

@end

#pragma mark - PPNavigationController

@interface PPNavigationController ()
@end

#pragma mark -

@implementation PPNavigationController

@dynamic appearsFirstTime;
@dynamic delegate;

+ (Class)defaultNavigationBarClass {
    return [PPNavigationBar class];
}

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _PPNavigationControllerFlags.appearsFirstTime = YES;
    }
    
    return self;
}

- (id)init {
    if (self = [self initWithNavigationBarClass:[[self class] defaultNavigationBarClass] toolbarClass:nil]) {
        //nothing to do...
    }
    
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [self initWithNavigationBarClass:[[self class] defaultNavigationBarClass] toolbarClass:nil]) {
        self.viewControllers = (rootViewController) ? @[rootViewController] : nil;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _PPNavigationControllerFlags.appearsFirstTime = YES;
    }
    
    return self;
}

#pragma mark View

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //reset flags
    _PPNavigationControllerFlags.appearsFirstTime = NO;
}

#pragma mark Accessors

- (void)setDelegate:(id<PPNavigationControllerDelegate>)delegate {
    [super setDelegate:delegate];
}

- (id <PPNavigationControllerDelegate>)delegate {
    return (id <PPNavigationControllerDelegate>)[super delegate];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    if (viewControllers && 0 < viewControllers.count) {
        if ([self.delegate respondsToSelector:@selector(navigationController:didSetViewControllers:animated:)]) {
            [self.delegate navigationController:self didSetViewControllers:viewControllers animated:animated];
        }
    }
}

- (BOOL)appearsFirstTime {
    return _PPNavigationControllerFlags.appearsFirstTime;
}

#pragma mark UINavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController) {
        [super pushViewController:viewController animated:animated];
        
        if ([self.delegate respondsToSelector:@selector(navigationController:didPushToViewController:animated:)]) {
            [self.delegate navigationController:self didPushToViewController:viewController animated:animated];
        }
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController * viewController = [super popViewControllerAnimated:animated];
    
    if (viewController) {
        if ([self.delegate respondsToSelector:@selector(navigationController:didPopToViewController:animated:)]) {
            [self.delegate navigationController:self didPopToViewController:[self.viewControllers lastObject] animated:animated];
        }
    }
    
    return viewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray * viewControllers = [super popToViewController:viewController animated:animated];
    
    if (viewControllers && viewControllers.count) {
        if ([self.delegate respondsToSelector:@selector(navigationController:didPopToViewController:animated:)]) {
            [self.delegate navigationController:self didPopToViewController:[self.viewControllers lastObject] animated:animated];
        }
    }
    
    return viewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray * viewControllers = [super popToRootViewControllerAnimated:animated];
    
    if (viewControllers && viewControllers.count) {
        if ([self.delegate respondsToSelector:@selector(navigationController:didPopToViewController:animated:)]) {
            [self.delegate navigationController:self didPopToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
        }
    }
    
    return viewControllers;
}

@end
