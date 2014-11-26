//
//  MMProgressHUD.m
//  MMProgressHUD
//
//  Created by Lars Anderson on 10/7/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MMProgressHUD.h"
//#import "MMProgressHUD+Animations.h"

#import "MMProgressHUDWindow.h"
#import "MMProgressHUDViewController.h"

#import "MMProgressHUDOverlayView.h"
#import "MMVectorImage.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#error MMProgressHUD uses APIs only available in iOS 5.0+
#endif

NSString * const MMProgressHUDDefaultConfirmationMessage = @"Cancel?";
NSString * const MMProgressHUDAnimationShow = @"mm-progress-hud-present-animation";
NSString * const MMProgressHUDAnimationDismiss = @"mm-progress-hud-dismiss-animation";
NSString * const MMProgressHUDAnimationWindowFadeOut = @"mm-progress-hud-window-fade-out";
NSString * const MMProgressHUDAnimationKeyShowAnimation = @"show";
NSString * const MMProgressHUDAnimationKeyDismissAnimation = @"dismiss";
NSUInteger const MMProgressHUDConfirmationPulseCount = 8;//Keep this number even
CGFloat    const MMProgressHUDStandardDismissDelay = 0.75f;
CGSize     const MMProgressHUDDefaultImageSize = {37.f, 37.f};

#pragma mark - MMProgressHUD
@interface MMProgressHUD () <MMHudDelegate>

@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) MMProgressHUDWindow *window;
@property (nonatomic, readwrite, getter = isVisible)  BOOL visible;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSArray *animationImages;
@property (nonatomic, strong) CAAnimation *queuedShowAnimation;
@property (nonatomic, strong) CAAnimation *queuedDismissAnimation;
@property (nonatomic, readwrite, strong) MMProgressHUDOverlayView *overlayView;
@property (nonatomic, strong) NSTimer *dismissDelayTimer;
@property (nonatomic, copy) NSString *tempStatus;
@property (nonatomic, strong) NSTimer *confirmationTimer;
@property (nonatomic, getter = isConfirmed) BOOL confirmed;
@property (nonatomic, assign) BOOL presentedAnimated;

@end

#pragma mark - Class Category
//----Fixed bugs: not adappt to Lib. modified by Hequn------<Begin>----//
@interface MMProgressHUD()

- (CGPoint)_windowCenterForHUDAnchor:(CGPoint)anchor;
- (void)dismissWithCompletionState:(MMProgressHUDCompletionState)completionState
                             title:(NSString *)title
                            status:(NSString *)status
                        afterDelay:(float)delay;

- (void)_updateHUDAnimated:(BOOL)animated
            withCompletion:(void(^)(BOOL completed))completionBlock;

- (void)show;
- (void)dismiss;

- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmationMessage
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images;

//----Animation associalized---- Added by Hequn---<Begin>--2014.6.12--//
- (CAAnimationGroup *)_glowAnimation;
- (void)_beginGlowAnimation;
- (void)_endGlowAnimation;
- (void)_dismissWithDropAnimation;
- (void)_dismissWithExpandAnimation;
- (void)_dismissWithShrinkAnimation;
- (void)_dismissWithSwingLeftAnimation;
- (void)_dismissWithSwingRightAnimation;
- (void)_dismissWithBalloonAnimation;
- (void)_dismissWithFadeAnimation;
- (void)_showWithDropAnimation;
- (void)_showWithExpandAnimation;
- (void)_showWithShrinkAnimation;
- (void)_showWithSwingInAnimationFromLeft:(BOOL)left;
- (void)_showWithBalloonAnimation;
- (void)_showWithFadeAnimation;

- (void)_executeShowAnimation:(CAAnimation *)animation;
- (void)_executeDismissAnimation:(CAAnimation *)animation;

//----Animation associalized---- Added by Hequn---<End>--2014.6.12--//
@end


@implementation MMProgressHUD (Class)

//class setters
+ (void)setPresentationStyle:(MMProgressHUDPresentationStyle)animationStyle{
    [[MMProgressHUD sharedHUD] setPresentationStyle:animationStyle];
}

+ (void)setDisplayStyle:(MMProgressHUDDisplayStyle)style{
    MMHud *hud = [[MMProgressHUD sharedHUD] hud];
    [hud setDisplayStyle:style];
}

//updates
+ (void)updateStatus:(NSString *)status{
    [MMProgressHUD updateTitle:nil status:status];
}

+ (void)updateTitle:(NSString *)title status:(NSString *)status{
    MMProgressHUD *hud = [MMProgressHUD sharedHUD];
    
    NSArray *images = nil;
    if (hud.hud.animationImages.count > 0) {
        images = hud.hud.animationImages;
    }
    else if(hud.hud.image != nil){
        images = @[hud.hud.image];
    }
    
    if (title == nil) {
        title = hud.hud.titleText;
    }
    
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:hud.confirmationMessage
                     cancelBlock:hud.cancelBlock
                          images:images];
}

//with progress
+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:nil
                             cancelBlock:nil
                                  images:nil];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
                        image:(UIImage *)image{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:nil
                             cancelBlock:nil
                                  images:@[image]];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
                       images:(NSArray *)images{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:nil
                             cancelBlock:nil
                                  images:images];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:confirmation
                             cancelBlock:cancelBlock
                                  images:nil];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock
                        image:(UIImage *)image{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:confirmation
                             cancelBlock:cancelBlock
                                  images:@[image]];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock
                       images:(NSArray *)images{
    [[MMProgressHUD sharedHUD] setProgressStyle:progressStyle];
    [[MMProgressHUD sharedHUD] showWithTitle:title
                                      status:status
                         confirmationMessage:confirmation
                                 cancelBlock:cancelBlock
                                      images:images];
}

+ (void)updateProgress:(CGFloat)progress withStatus:(NSString *)status title:(NSString *)title{
    MMProgressHUD *hud = [MMProgressHUD sharedHUD];
    [hud setProgress:progress];
    
    if (status != nil) {
        hud.hud.messageText = status;
    }
    
    if(title != nil){
        hud.hud.titleText = title;
    }
    
    if (hud.isVisible &&
        (hud.window != nil)) {
        
        void(^animationCompletion)(BOOL completed) = ^(BOOL completed){
            if (progress >= 1.f &&
                hud.progressCompletion != nil) {
                double delayInSeconds = 0.33f;//allow enough time for progress to animate
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    hud.progressCompletion();
                });
            }
        };
        
        [hud _updateHUDAnimated:YES
                 withCompletion:animationCompletion];
    }
    else{
        [hud show];
    }
}

+ (void)updateProgress:(CGFloat)progress
            withStatus:(NSString *)status{
    [MMProgressHUD updateProgress:progress
                       withStatus:status
                            title:nil];
}

+ (void)updateProgress:(CGFloat)progress{
    [MMProgressHUD updateProgress:progress
                       withStatus:nil
                            title:nil];
}

//indeterminate status
+ (void)showWithStatus:(NSString *)status{
    [MMProgressHUD showWithTitle:nil
                          status:status];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                          images:nil];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
                image:(UIImage *)image{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                           image:image];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
               images:(NSArray *)images{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                          images:images];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:cancelBlock
                          images:nil];
}

//cancellation
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock
                image:(UIImage *)image{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:cancelBlock
                          images:@[image]];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images{
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:nil
                     cancelBlock:cancelBlock
                          images:images];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancel{
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:confirmation
                     cancelBlock:cancel
                          images:nil];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
                image:(UIImage *)image{
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:confirmation
                     cancelBlock:cancelBlock
                          images:@[image]];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images{
    [[MMProgressHUD sharedHUD] setProgressStyle:MMProgressHUDProgressStyleIndeterminate];
    
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] showWithTitle:title
                                              status:status
                                 confirmationMessage:confirmation
                                         cancelBlock:cancelBlock
                                              images:images];
        });
    }
    else {
        [[MMProgressHUD sharedHUD] showWithTitle:title
                                          status:status
                             confirmationMessage:confirmation
                                     cancelBlock:cancelBlock
                                          images:images];
    }
}

//dismissal
+ (void)dismissWithError:(NSString *)status
                   title:(NSString *)title
              afterDelay:(float)delay{
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateError
                                                            title:title
                                                           status:status
                                                       afterDelay:delay];
        });
    }
    else{
        [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateError
                                                        title:title
                                                       status:status
                                                   afterDelay:delay];
    }
}

+ (void)dismissWithError:(NSString *)status
                   title:(NSString *)title{
    [MMProgressHUD dismissWithError:status
                              title:title
                         afterDelay:MMProgressHUDStandardDismissDelay];
}

+ (void)dismissWithError:(NSString *)status{
    [MMProgressHUD dismissWithError:status
                              title:nil];
}

+ (void)dismissWithError:(NSString *)status
              afterDelay:(float)delay{
    [MMProgressHUD dismissWithError:status
                              title:nil
                         afterDelay:delay];
}

+ (void)dismissWithSuccess:(NSString *)status
                     title:(NSString *)title
                afterDelay:(float)delay{
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateSuccess
                                                            title:title
                                                           status:status
                                                       afterDelay:delay];
        });
    }
    else{
        [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateSuccess
                                                        title:title
                                                       status:status
                                                   afterDelay:delay];
    }
}

+ (void)dismissWithSuccess:(NSString *)status
                     title:(NSString *)title{
    [MMProgressHUD dismissWithSuccess:status
                                title:title
                           afterDelay:MMProgressHUDStandardDismissDelay];
}

+ (void)dismissWithSuccess:(NSString *)status{
    [MMProgressHUD dismissWithSuccess:status
                                title:nil];
}

+ (void)dismiss{
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] dismiss];
        });
    }
    else {
        [[MMProgressHUD sharedHUD] dismiss];
    }
}

@end
//----Fixed bugs: not adappt to Lib.------<End>----//
@implementation MMProgressHUD

#pragma mark - Class Methods
+ (instancetype)sharedHUD{
    static MMProgressHUD *__sharedHUD = nil;
    
    static dispatch_once_t mmSharedHUDOnceToken;
    dispatch_once(&mmSharedHUDOnceToken, ^{        
        __sharedHUD = [[MMProgressHUD alloc] init];
    });
    
    return __sharedHUD;
}

#pragma mark - Instance Presentation Methods
- (void)showWithTitle:(NSString *)title
              status:(NSString *)status
  confirmationMessage:(NSString *)confirmationMessage
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images{

    self.image = nil;
    self.animationImages = nil;
    
    if (images.count == 1) {
        self.image = images[0];
    }
    else if(images.count > 0){
        self.animationImages = images;
    }
    
    [self showWithTitle:title
                 status:status
    confirmationMessage:confirmationMessage
            cancelBlock:cancelBlock
          progressStyle:self.progressStyle];
}

- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmationMessage
          cancelBlock:(void(^)(void))cancelBlock
        progressStyle:(MMProgressHUDProgressStyle)progressStyle{
    
    MMHudLog(@"Beginning %@ show...", NSStringFromClass(self.class));
    
    self.progressStyle = progressStyle;
    self.cancelBlock = cancelBlock;
    self.title = title;
    self.status = status;
    
    if (confirmationMessage.length > 0) {
        self.confirmationMessage = confirmationMessage;
    }
    else{
        self.confirmationMessage = MMProgressHUDDefaultConfirmationMessage;
    }
    
    if ((self.isVisible == YES) &&
        (self.window != nil) &&
        ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyDismissAnimation] == nil)) {
        [self _updateHUDAnimated:YES withCompletion:nil];
    }
    else{
        [self show];
    }
}

- (void)dismissWithCompletionState:(MMProgressHUDCompletionState)completionState
                             title:(NSString *)title
                           status:(NSString *)status
                        afterDelay:(float)delay{
    if (title) {
        self.title = title;
    }
    
    if (status) {
        self.status = status;
    }
    
    self.hud.completionState = completionState;
    
    if (self.isVisible) {
        [self _updateHUDAnimated:YES withCompletion:^(BOOL completed) {
            if (delay != INFINITY && delay != DISPATCH_TIME_FOREVER) {
                //create a timer in order to be cancellable
                [self.dismissDelayTimer invalidate];
                self.dismissDelayTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                                          target:self
                                                                        selector:@selector(dismiss)
                                                                        userInfo:nil
                                                                         repeats:NO];
            }
        }];
    }
    else{
        [self.dismissDelayTimer invalidate];
        self.dismissDelayTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                                  target:self
                                                                selector:@selector(dismiss)
                                                                userInfo:nil
                                                                 repeats:NO];
    }
}

#pragma mark - Initializers
- (instancetype)init{
    if( (self = [super initWithFrame:CGRectZero]) ){
        self.hud = [[MMHud alloc] init];
        self.hud.delegate = self;

        UIColor *imageFill = [UIColor colorWithWhite:1.f alpha:1.f];
        self.errorImage = [MMVectorImage
                           vectorImageShapeOfType:MMVectorShapeTypeX
                           size:MMProgressHUDDefaultImageSize
                           fillColor:imageFill];
        self.successImage = [MMVectorImage
                             vectorImageShapeOfType:MMVectorShapeTypeCheck
                             size:MMProgressHUDDefaultImageSize
                             fillColor:imageFill];
        
        [self setAutoresizingMask:
         UIViewAutoresizingFlexibleHeight |
         UIViewAutoresizingFlexibleWidth];
    }
    
    return self;
}

- (void)dealloc{
    MMHudLog(@"dealloc");
    
    if (_window != nil) {
        [_window setHidden:YES];
    }
}

- (void)forceCleanup{
    //Do not invoke this method unless you are in a unit test environment
    if (self.window != nil) {
        [self.window setHidden:YES];
    }
    self.window.rootViewController = nil;
    self.window = nil;
}

#pragma mark - Passthrough Properties
- (void)setOverlayMode:(MMProgressHUDWindowOverlayMode)overlayMode{
    self.overlayView.overlayMode = overlayMode;
}

- (MMProgressHUDWindowOverlayMode)overlayMode{
    return self.overlayView.overlayMode;
}

- (void)setAnimationLoopDuration:(CGFloat)animationLoopDuration{
    self.hud.animationLoopDuration = animationLoopDuration;
}

- (CGFloat)animationLoopDuration{
    return self.hud.animationLoopDuration;
}

- (void)setProgress:(CGFloat)progress{
    [self.hud setProgress:progress animated:YES];
    
    self.hud.accessibilityValue = [NSString stringWithFormat:@"%i%%", (int)(progress/1.f*100)];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, [NSString stringWithFormat:@"%@ %@", self.hud.accessibilityLabel, self.hud.accessibilityValue]);
}

- (CGFloat)progress{
    return self.hud.progress;
}

- (void)setProgressStyle:(MMProgressHUDProgressStyle)progressStyle{
    self.hud.progressStyle = progressStyle;
    
    if ((progressStyle == MMProgressHUDProgressStyleLinear) ||
        (progressStyle == MMProgressHUDProgressStyleRadial)) {
        self.accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently;
    }
    else{
        self.accessibilityTraits &= ~UIAccessibilityTraitUpdatesFrequently;
    }
}

- (MMProgressHUDProgressStyle)progressStyle{
    return self.hud.progressStyle;
}

- (void)setTitle:(NSString *)title{
    self.hud.titleText = title;
}

- (NSString *)title{
    return self.hud.titleText;
}

- (void)setStatus:(NSString *)status{
    self.hud.messageText = status;
}

- (NSString *)status{
    return self.hud.messageText;
}

#pragma mark - Property Overrides

- (MMProgressHUDOverlayView *)overlayView{
    if (_overlayView == nil) {
        _overlayView = [[MMProgressHUDOverlayView alloc] init];
        _overlayView.alpha = 0.f;
    }
    
    return _overlayView;
}

- (CGColorRef)glowColor{
    if (_glowColor == NULL) {
        CGColorRef redColor = CGColorRetain([UIColor redColor].CGColor);
        self.glowColor = redColor;
        CGColorRelease(redColor);
    }
    
    return _glowColor;
}

- (MMHud *)hud {
    if (_hud == nil) {
        _hud = [[MMHud alloc] init];
    }
    
    return _hud;
}

- (void)setProgressCompletion:(void (^)(void))progressCompletion{
    if (progressCompletion != nil) {
        typeof(self) __weak weakSelf = self;
        _progressCompletion = ^(void){
            progressCompletion();
            
            weakSelf.progressCompletion = nil;
        };
    }
    else{
        _progressCompletion = nil;
    }
}

- (void)setCancelBlock:(void (^)(void))cancelBlock{
    _cancelBlock = cancelBlock;
    
    if (cancelBlock != nil) {
        self.hud.accessibilityTraits |=
        (UIAccessibilityTraitAllowsDirectInteraction |
        UIAccessibilityTraitButton);
    }
    else{
        self.hud.accessibilityTraits &= ~(UIAccessibilityTraitAllowsDirectInteraction |
                                         UIAccessibilityTraitButton);
    }
}

#pragma mark - Builders
- (void)_buildHUDWindow {
    if (self.window == nil) {
        self.window = [[MMProgressHUDWindow alloc] init];
        
        MMProgressHUDViewController *vc = [[MMProgressHUDViewController alloc] init];
        [vc setView:self];
        
        [self.window setRootViewController:vc];
        
        [self _buildOverlayViewForMode:self.overlayMode inView:self.window];
        [self.window setHidden:NO];
    }
}

- (void)_buildOverlayViewForMode:(MMProgressHUDWindowOverlayMode)overlayMode inView:(UIView *)view{
    
    self.overlayView.frame = view.bounds;
    self.overlayView.overlayMode = overlayMode;
    
    [view insertSubview:self.overlayView atIndex:0];
}

- (void)_buildHUD{
    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleHeight | 
     UIViewAutoresizingFlexibleWidth];
    
    [self _buildHUDWindow];
    
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
    [tapToDismiss setNumberOfTapsRequired:1];
    [tapToDismiss setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:tapToDismiss];
    
    self.hud.image = self.image;
    self.hud.animationImages = self.animationImages;
    
    self.hud.layer.transform = CATransform3DIdentity;
    
    [self.hud applyLayoutFrames];
    
    [self addSubview:self.hud];
}

#pragma mark - Layout
- (void)_updateMessageLabelsAnimated:(BOOL)animated{
    [self.hud updateTitle:self.title message:self.status animated:animated];
}

- (void)_updateHUDAnimated:(BOOL)animated withCompletion:(void(^)(BOOL completed))completionBlock{
    MMHudLog(@"Updating %@ with completion...", NSStringFromClass(self.class));
    
    if (self.dismissDelayTimer != nil) {
        [self.dismissDelayTimer invalidate], self.dismissDelayTimer = nil;
    }
    
    if (animated) {
        [UIView
         animateWithDuration:0.1f
         delay:0.f
         options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             [self _updateHUD];
         }
         completion:completionBlock];
    }
    else{
        [self _updateHUD];
        
        if (completionBlock != nil) {
            completionBlock(YES);
        }
    }
}

- (void)_updateHUD{
    [self.hud updateLayoutFrames];
    
    [self.hud updateAnimated:YES withCompletion:nil];
    
    self.hud.center = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
}

- (CGPoint)_windowCenterForHUDAnchor:(CGPoint)anchor{
    
    CGFloat hudHeight = CGRectGetHeight(self.hud.frame);
    
    CGPoint position;
    if (UIInterfaceOrientationIsPortrait([[[[UIApplication sharedApplication] keyWindow] rootViewController] interfaceOrientation])) {
        
        CGFloat y = roundf(self.window.center.y + (anchor.y - 0.5f) * hudHeight);
        CGFloat x = roundf(self.window.center.x);
        
        position = CGPointMake(x, y);
    }
    else{
        CGFloat x = roundf(self.window.center.y);
        CGFloat y = roundf(self.window.center.x + (anchor.y - 0.5f) * hudHeight);
        
        position = CGPointMake(x, y);
    }
    
    return [self _antialiasedPositionPointForPoint:position forLayer:self.hud.layer];
}

#pragma mark - Presentation
- (void)show{
    if (self.dismissDelayTimer != nil) {
        [self.dismissDelayTimer invalidate], self.dismissDelayTimer = nil;
    }
    
    NSAssert([NSThread isMainThread], @"Show should be run on main thread!");
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self _buildHUD];
    
    self.presentedAnimated = YES;
    switch (self.presentationStyle) {
        case MMProgressHUDPresentationStyleDrop:
            [self _showWithDropAnimation];
            break;
        case MMProgressHUDPresentationStyleExpand:
            [self _showWithExpandAnimation];
            break;
        case MMProgressHUDPresentationStyleShrink:
            [self _showWithShrinkAnimation];
            break;
        case MMProgressHUDPresentationStyleSwingLeft:
            [self _showWithSwingInAnimationFromLeft:YES];
            break;
        case MMProgressHUDPresentationStyleSwingRight:
            [self _showWithSwingInAnimationFromLeft:NO];
            break;
        case MMProgressHUDPresentationStyleBalloon:
            [self _showWithBalloonAnimation];
            break;
        case MMProgressHUDPresentationStyleFade:
            [self _showWithFadeAnimation];
            break;
        case MMProgressHUDPresentationStyleNone:
        default:{
            self.presentedAnimated = NO;
            
            CGPoint newCenter = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
            
            self.hud.center = newCenter;
            self.hud.layer.transform = CATransform3DIdentity;
            self.overlayView.alpha = 1.0f;
            
        }
            break;
    }
    
    [CATransaction commit];
    
    CGFloat duration = (self.presentationStyle == MMProgressHUDPresentationStyleNone) ? 0.f : MMProgressHUDAnimateInDurationShort;
    
    [UIView
     animateWithDuration:duration
     delay:0.f
     options:UIViewAnimationOptionCurveEaseOut |
             UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         self.overlayView.alpha = 1.0f;
     }
     completion:^(BOOL completed){
         UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.hud.accessibilityLabel);
     }];
}

- (void)dismiss{
    NSAssert([NSThread isMainThread], @"Dismiss method should be run on main thread!");
    
    MMHudLog(@"Dismissing...");
    
    switch (self.presentationStyle) {
        case MMProgressHUDPresentationStyleDrop:
            [self _dismissWithDropAnimation];
            break;
        case MMProgressHUDPresentationStyleExpand:
            [self _dismissWithExpandAnimation];
            break;
        case MMProgressHUDPresentationStyleShrink:
            [self _dismissWithShrinkAnimation];
            break;
        case MMProgressHUDPresentationStyleSwingLeft:
            [self _dismissWithSwingLeftAnimation];
            break;
        case MMProgressHUDPresentationStyleSwingRight:
            [self _dismissWithSwingRightAnimation];
            break;
        case MMProgressHUDPresentationStyleBalloon:
            [self _dismissWithBalloonAnimation];
            break;
        case MMProgressHUDPresentationStyleFade:
            [self _dismissWithFadeAnimation];
            break;
        case MMProgressHUDPresentationStyleNone:
        default:
            self.hud.layer.opacity = 0.f;
            self.overlayView.layer.opacity = 0.f;
            
            [self removeFromSuperview];
            
            self.visible = NO;
            [self.window setHidden:YES];
            self.window = nil;
            break;
    }
    
    CGFloat duration = (self.presentationStyle == MMProgressHUDPresentationStyleNone) ? 0.f : MMProgressHUDAnimateOutDurationLong;
    CGFloat delay = (self.presentationStyle == MMProgressHUDPresentationStyleDrop) ? MMProgressHUDAnimateOutDurationShort : 0.f;
    
    [UIView
     animateWithDuration:duration
     delay:delay
     options:UIViewAnimationOptionCurveEaseIn |
             UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         self.overlayView.alpha = 0.f;
     }
     completion:^(BOOL finished) {
         
         self.image = nil;
         self.animationImages = nil;
         self.progress = 0.f;
         self.hud.completionState = MMProgressHUDCompletionStateNone;
         
         [self.window setHidden:YES], self.window = nil;
         
         UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
     }];
}

- (CGPoint)_antialiasedPositionPointForPoint:(CGPoint)oldCenter forLayer:(CALayer *)layer{
    CGPoint newCenter = oldCenter;
    
    CGSize viewSize = layer.bounds.size;
    CGPoint anchor = layer.anchorPoint;
    
    double intPart;
    CGFloat viewXRemainder = modf(viewSize.width/2,&intPart);
    CGFloat viewCenterXRemainder = modf(oldCenter.x/2, &intPart);
    
    if (anchor.x != 0.f && anchor.x != 1.f) {
        if (((viewXRemainder == 0) &&//if view width is even
            (viewCenterXRemainder != 0)) ||//and if center x is odd
            ((viewXRemainder != 0) &&//if view width is odd
             (viewCenterXRemainder == 0))) {//and if center x is even
                newCenter.x = oldCenter.x + viewXRemainder;
            }
    }

    CGFloat viewYRemainder = modf(viewSize.height/2,&intPart);
    CGFloat viewCenterYRemainder = modf(oldCenter.y/2, &intPart);
    
    if (anchor.y != 0.f && anchor.y != 1.f) {
        if (((viewYRemainder == 0) &&//if view width is even
             (viewCenterYRemainder != 0)) ||//and if center x is odd
            ((viewYRemainder != 0) &&//if view width is odd
             (viewCenterYRemainder == 0))) {//and if center x is even
                newCenter.y = oldCenter.y + viewYRemainder;
            }
    }
    
    return newCenter;
}

#pragma mark - Gestures
- (void)_handleTap:(UITapGestureRecognizer *)recognizer{
    MMHudLog(@"Handling tap");
    
    if((self.cancelBlock != nil) &&
       (self.confirmed == NO)){
        MMHudLog(@"Asking to confirm cancel");
        
        self.tempStatus = [self.status copy];
        CGFloat timerDuration = MMProgressHUDAnimateInDurationNormal*MMProgressHUDConfirmationPulseCount;
        self.confirmationTimer = [NSTimer scheduledTimerWithTimeInterval:timerDuration
                                                                  target:self
                                                                selector:@selector(_resetConfirmationTimer:)
                                                                userInfo:nil
                                                                 repeats:NO];
        self.status = self.confirmationMessage;
    
        [self.hud updateTitle:self.hud.titleText message:self.confirmationMessage animated:YES];
        
        self.confirmed = YES;
        
        [self _beginGlowAnimation];
    }
    else if(self.confirmed){
        MMHudLog(@"confirmed to dismiss!");
        
        [self.confirmationTimer invalidate], self.confirmationTimer = nil;
        
        if(self.cancelBlock != nil){
            self.cancelBlock();
        }
        
        self.hud.completionState = MMProgressHUDCompletionStateError;
        [self.hud setNeedsUpdate:YES];
        [self.hud updateAnimated:YES
                  withCompletion:^(__unused BOOL completed) {
            [self dismiss];
        }];
        
        self.confirmed = NO;
    }
}

- (void)_resetConfirmationTimer:(NSTimer *)timer{
    MMHudLog(@"Resetting confirmation timer");
    
    [self.confirmationTimer invalidate], self.confirmationTimer = nil;
    self.status = self.tempStatus;
    self.tempStatus = nil;
    
    self.confirmed = NO;
    
    [self _endGlowAnimation];
    
    [self.hud updateTitle:self.hud.titleText message:self.status animated:YES];
}

- (UIImage *)_imageForCompletionState:(MMProgressHUDCompletionState)completionState{
    switch (completionState) {
        case MMProgressHUDCompletionStateError:
            return self.errorImage;
        case MMProgressHUDCompletionStateSuccess:
            return self.successImage;
        case MMProgressHUDCompletionStateNone:
            return nil;
    }
}

#pragma mark - MMHud Delegate
- (void)hudDidCompleteProgress:(MMHud *)hud{
    if(self.progressCompletion != nil){
        self.progressCompletion();
    }
    
    self.hud.accessibilityValue = nil;
}

- (UIImage *)hud:(MMHud *)hud imageForCompletionState:(MMProgressHUDCompletionState)completionState{
    return [self _imageForCompletionState:completionState];
}

- (CGPoint)hudCenterPointForDisplay:(MMHud *)hud{
    return [self _windowCenterForHUDAnchor:hud.layer.anchorPoint];
}


//----Animation associalized---- Added by Hequn---<Begin>--2014.6.12--//
#pragma mark - Animations
- (CAAnimationGroup *)_glowAnimation {
    CABasicAnimation *glowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowColor"];
    glowAnimation.fromValue = (id)self.hud.layer.shadowColor;
    glowAnimation.toValue = (id)self.glowColor;
    
    CABasicAnimation *shadowOpacity = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowOpacity.fromValue = @(self.hud.layer.shadowOpacity);
    shadowOpacity.toValue = @1.f;
    
    CGColorRef whiteishColor = CGColorRetain([UIColor colorWithWhite:0.f alpha:0.85f].CGColor);
    
    CABasicAnimation *hudBackground = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    
    hudBackground.fromValue = (id)self.hud.layer.backgroundColor;
    hudBackground.toValue = (__bridge id)whiteishColor;
    
    CGColorRelease(whiteishColor);
    
    CAAnimationGroup *glowGroup = [CAAnimationGroup animation];
    glowGroup.animations = @[glowAnimation, shadowOpacity, hudBackground];
    glowGroup.duration = MMProgressHUDAnimateInDurationNormal;
    glowGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    glowGroup.autoreverses = YES;
    glowGroup.repeatCount = INFINITY;
    
    return glowGroup;
}

- (void)_beginGlowAnimation{
    
    CAAnimationGroup *glowGroup = [self _glowAnimation];
    
    [self.hud.layer addAnimation:glowGroup forKey:@"glow-animation"];
}

- (void)_endGlowAnimation{
    [self.hud.layer removeAnimationForKey:@"glow-animation"];
}

- (void)_showWithDropAnimation{
    self.hud.layer.anchorPoint = CGPointMake(0.5f, 0.f);
    
    CGPoint newCenter = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.center = CGPointMake(newCenter.x, -CGRectGetHeight(self.hud.frame));
        self.hud.layer.opacity = 1.f;
        
        [self _executeShowAnimation:[self _dropAnimationIn]];
    }
    [CATransaction commit];
}

- (void)_dismissWithDropAnimation{
    
    double newAngle = arc4random_uniform(1000)/1000.f*M_2_PI-(M_2_PI)/2.f;
    CGPoint newPosition = CGPointMake(self.hud.layer.position.x, self.frame.size.height + self.hud.frame.size.height);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        [self _executeDismissAnimation:[self _dropAnimationOut]];
        
        self.hud.layer.position = newPosition;
        self.hud.layer.transform = CATransform3DMakeRotation(newAngle, 0.f, 0.f, 1.f);
    }
    [CATransaction commit];
}

- (void)_showWithExpandAnimation{
    self.hud.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.hud.layer.position =  [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    self.hud.alpha = 0.f;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.transform = CATransform3DIdentity;
        self.hud.layer.opacity = 1.0f;
        
        [self _executeShowAnimation:[self _shrinkAnimation:NO animateOut:NO]];
    }
    [CATransaction commit];
}

- (void)_dismissWithExpandAnimation{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.transform = CATransform3DMakeScale(3.f, 3.f, 1.f);
        self.hud.layer.opacity = 0.f;
        
        [self _executeDismissAnimation:[self _shrinkAnimation:NO animateOut:YES]];
    }
    [CATransaction commit];
}

- (void)_showWithShrinkAnimation{
    self.hud.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.hud.layer.position = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    self.hud.alpha = 0.f;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.transform = CATransform3DIdentity;
        self.hud.layer.opacity = 1.0f;
        
        [self _executeShowAnimation:[self _shrinkAnimation:YES animateOut:NO]];
    }
    [CATransaction commit];
}

- (void)_dismissWithShrinkAnimation{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.transform = CATransform3DMakeScale(0.25, 0.25, 1.f);
        self.hud.layer.opacity = 0.f;
        
        [self _executeDismissAnimation:[self _shrinkAnimation:YES animateOut:YES]];
    }
    [CATransaction commit];
}

- (void)_showWithSwingInAnimationFromLeft:(BOOL)fromLeft{
    self.hud.layer.anchorPoint = CGPointMake(0.5f, 0.0f);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.opacity = 1.f;
        self.hud.layer.position = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
        
        [self _executeShowAnimation:[self _swingInAnimationFromLeft:fromLeft]];
    }
    [CATransaction commit];
}

- (void)_dismissWithSwingRightAnimation{
    [self _dismissWithDropAnimation];
}

- (void)_dismissWithSwingLeftAnimation{
    [self _dismissWithDropAnimation];
}

- (void)_showWithBalloonAnimation{
    self.hud.layer.anchorPoint = CGPointMake(0.5, 1.0);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.opacity = 1.f;
        CGPoint center = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
        self.hud.layer.position = CGPointMake(center.x, CGRectGetHeight(self.frame) + CGRectGetHeight(self.hud.frame));
        //        self.hud.layer.position = center;
        
        
        [self _executeShowAnimation:[self _balloonAnimationIn]];
    }
    [CATransaction commit];
}

- (void)_dismissWithBalloonAnimation{
    self.hud.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.transform = CATransform3DMakeRotation(M_PI_2, 0.f, 0.f, 1.f);
        
        [self _executeDismissAnimation:[self _balloonAnimationOut]];
        
        CGPoint center = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
        self.hud.layer.position = CGPointMake(center.x, -CGRectGetHeight(self.hud.frame));
    }
    [CATransaction commit];
}

- (void)_showWithFadeAnimation{
    self.hud.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.hud.layer.transform = CATransform3DIdentity;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        [self _executeShowAnimation:[self _fadeInAnimation]];
        
        self.hud.layer.opacity = 1.f;
        self.hud.layer.position = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    }
    [CATransaction commit];
}

- (void)_dismissWithFadeAnimation{
    self.hud.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.hud.layer.transform = CATransform3DIdentity;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        [self _executeDismissAnimation:[self _fadeOutAnimation]];
        
        self.hud.layer.opacity = 0.f;
        self.hud.layer.position = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    }
    [CATransaction commit];
}

#pragma mark - Animation Foundries
- (CAKeyframeAnimation *)_dropInAnimationPositionAnimationWithCenter:(CGPoint)newCenter {
    CAKeyframeAnimation *dropInPositionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.hud.center.x, self.hud.center.y);
    CGPathAddLineToPoint(path, NULL, newCenter.x - 10.f, newCenter.y - 2.f);
    CGPathAddCurveToPoint(path, NULL,
                          newCenter.x, newCenter.y - 10.f,
                          newCenter.x + 10.f, newCenter.y - 10.f,
                          newCenter.x + 5.f, newCenter.y - 2.f);
    CGPathAddCurveToPoint(path, NULL,
                          newCenter.x + 7, newCenter.y - 7.f,
                          newCenter.x, newCenter.y - 7.f,
                          newCenter.x - 3.f, newCenter.y);
    CGPathAddCurveToPoint(path, NULL,
                          newCenter.x, newCenter.y - 4.f,
                          newCenter.x , newCenter.y - 4.f,
                          newCenter.x, newCenter.y);
    
    dropInPositionAnimation.path = path;
    dropInPositionAnimation.calculationMode = kCAAnimationCubic;
    dropInPositionAnimation.keyTimes = @[@0.0f,
                                         @0.25f,
                                         @0.35f,
                                         @0.55f,
                                         @0.7f,
                                         @1.0f];
    dropInPositionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CGPathRelease(path);
    
    return dropInPositionAnimation;
}

- (CAKeyframeAnimation *)_dropInAnimationRotationAnimationWithInitialAngle:(CGFloat)initialAngle keyTimes:(NSArray *)keyTimes{
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.values = @[@(initialAngle),
                        @(-initialAngle * 0.85),
                        @(initialAngle * 0.6),
                        @(-initialAngle * 0.3),
                        @0.f];
    rotation.calculationMode = kCAAnimationCubic;
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotation.keyTimes = keyTimes;
    
    return rotation;
}

- (CAAnimation *)_dropAnimationIn{
    CGFloat initialAngle = M_2_PI/10.f + arc4random_uniform(1000)/1000.f*M_2_PI/5.f;
    CGPoint newCenter = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    
    MMHudLog(@"Center after drop animation: %@", NSStringFromCGPoint(newCenter));
    
    CAKeyframeAnimation *dropInAnimation = [self _dropInAnimationPositionAnimationWithCenter:newCenter];
    CAKeyframeAnimation *rotationAnimation = [self _dropInAnimationRotationAnimationWithInitialAngle:initialAngle
                                                                                            keyTimes:dropInAnimation.keyTimes];
    
    CAAnimationGroup *showAnimation = [CAAnimationGroup animation];
    showAnimation.animations = @[dropInAnimation, rotationAnimation];
    showAnimation.duration = MMProgressHUDAnimateInDurationLong;
    
    [self _executeShowAnimation:showAnimation];
    
    self.hud.layer.position = newCenter;
    self.hud.layer.transform = CATransform3DIdentity;
    
    return showAnimation;
}

- (CAAnimation *)_dropAnimationOut{
    double newAngle = arc4random_uniform(1000)/1000.f*M_2_PI-(M_2_PI)/2.f;
    CATransform3D rotation = CATransform3DMakeRotation(newAngle, 0.f, 0.f, 1.f);
    CGPoint newPosition = CGPointMake(self.hud.layer.position.x, self.frame.size.height + self.hud.frame.size.height);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.fromValue = [NSValue valueWithCATransform3D:self.hud.layer.transform];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotation];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:self.hud.layer.position];
    positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
    
    CAAnimationGroup *fallOffAnimation = [CAAnimationGroup animation];
    fallOffAnimation.animations = @[rotationAnimation, positionAnimation];
    fallOffAnimation.duration = MMProgressHUDAnimateOutDurationLong;
    fallOffAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fallOffAnimation.removedOnCompletion = YES;
    
    return fallOffAnimation;
}

- (CAAnimation *)_shrinkAnimation:(BOOL)shrink animateOut:(BOOL)fadeOut{
    CGFloat startingOpacity;// = fadeOut ? 1.0 : 0.f;
    CGFloat startingScale;// = shrink ? 0.25 : 1.0f;
    CGFloat endingOpacity;
    CGFloat endingScale;
    
    if (fadeOut) { //shrink & expand out
        startingOpacity = 1.f;
        startingScale = 1.f;
        endingOpacity = 0.f;
        
        if (shrink) {
            endingScale = 0.25f;
        }
        else{
            endingScale = 3.f;
        }
    }
    else{
        startingOpacity = 0.f;
        endingScale = 1.f;
        endingOpacity = 1.f;
        
        if (shrink) {//shrink in
            startingScale = 3.f;
        }
        else{//expand in
            startingScale = 0.25f;
        }
    }
    
    CAKeyframeAnimation *expand = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    if (fadeOut) {
        expand.keyTimes = @[@0.f,
                            @0.45f,
                            @1.0f];
        
        if (shrink) {
            expand.values = @[@(startingScale),
                              @(startingScale*1.2f),
                              @(endingScale)];
        }
        else{
            expand.values = @[@(startingScale),
                              @(startingScale*0.8f),
                              @(endingScale)];
        }
    }
    else{
        expand.keyTimes = @[@0.f,
                            @0.65f,
                            @0.80f,
                            @1.0f];
        
        if (shrink) {
            expand.values = @[@(startingScale),
                              @(endingScale*0.9f),
                              @(endingScale*1.1f),
                              @(endingScale)];
        }
        else{
            expand.values = @[@(startingScale),
                              @(endingScale*1.1f),
                              @(endingScale*0.9f),
                              @(endingScale)];
        }
    }
    
    expand.calculationMode = kCAAnimationCubic;
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @(startingOpacity);
    fade.toValue = @(endingOpacity);
    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[expand, fade];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationGroup.duration = fadeOut ? MMProgressHUDAnimateOutDurationShort : MMProgressHUDAnimateInDurationShort;
    
    return animationGroup;
}

- (CAAnimation *)_swingInAnimationFromLeft:(BOOL)fromLeft{
    CAKeyframeAnimation *rotate = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    
    CGPoint endPoint = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    CGPoint startPoint;
    
    CGFloat height;
    CGFloat width;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint cp1;
    CGPoint cp2;
    
    if (UIInterfaceOrientationIsPortrait([[[[UIApplication sharedApplication] keyWindow] rootViewController] interfaceOrientation])) {
        height = CGRectGetHeight(self.window.frame);
        width = CGRectGetWidth(self.window.frame);
    }
    else{
        height = CGRectGetWidth(self.window.frame);
        width = CGRectGetHeight(self.window.frame);
    }
    
    if (fromLeft) { //swing in from left
        startPoint = CGPointMake(-CGRectGetWidth(self.hud.frame), 0.f);
        
        cp1 = CGPointMake(startPoint.x + 10.f, startPoint.y + height/4);
        cp2 = CGPointMake(endPoint.x - width/4, endPoint.y);
        
        rotate.values = @[[NSNumber numberWithFloat:M_PI_4],
                          @0.0f,
                          [NSNumber numberWithFloat:-M_PI_4/6],
                          [NSNumber numberWithFloat:M_PI_4/12],
                          @0.0f];
    }
    else{//swing in from right
        if (UIInterfaceOrientationIsPortrait([[[[UIApplication sharedApplication] keyWindow] rootViewController] interfaceOrientation])) {
            startPoint = CGPointMake(CGRectGetWidth(self.window.frame) + CGRectGetWidth(self.hud.frame), 0.f);
        }
        else{
            startPoint = CGPointMake(CGRectGetHeight(self.window.frame) + CGRectGetWidth(self.hud.frame), 0.f);
        }
        
        cp1 = CGPointMake(startPoint.x - 10.f, startPoint.y + height/4);
        cp2 = CGPointMake(endPoint.x + width/4, endPoint.y);
        
        rotate.values = @[[NSNumber numberWithFloat:-M_PI_4],
                          @0.0f,
                          [NSNumber numberWithFloat:M_PI_4/6],
                          [NSNumber numberWithFloat:-M_PI_4/12],
                          @0.0f];
    }
    
    MMHudLog(@"Start point: %@", NSStringFromCGPoint(startPoint));
    MMHudLog(@"End Point: %@", NSStringFromCGPoint(endPoint));
    
    MMHudLog(@"cp1: %@", NSStringFromCGPoint(cp1));
    MMHudLog(@"cp2: %@", NSStringFromCGPoint(cp2));
    
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(path, NULL, cp1.x, cp1.y, cp2.x, cp2.y, endPoint.x, endPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x - 5.f, endPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x + 3.f, endPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    CAKeyframeAnimation *swing = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    swing.path = path;
    swing.calculationMode = kCAAnimationCubic;
    swing.keyTimes = @[@0.0f,
                       @0.75f,
                       @0.8f,
                       @0.9f,
                       @1.0f];
    swing.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CGPathRelease(path);
    
    rotate.keyTimes = swing.keyTimes;
    rotate.timingFunctions = swing.timingFunctions;
    rotate.calculationMode = kCAAnimationCubic;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[swing, rotate];
    group.duration = MMProgressHUDAnimateInDurationMedium;
    
    return group;
}

- (CAAnimation *)_moveInAnimation{
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 0.33f;
    
    return transition;
}

- (CAAnimation *)_fadeInAnimation{
    NSString *opacityKey = @"opacity";
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKey];
    NSNumber *currentValue = [self.hud.layer valueForKey:opacityKey];
    if ([currentValue floatValue] == 1.f) {
        animation.fromValue = @(0.f);
    }
    else{
        animation.fromValue = [self.hud.layer.presentationLayer valueForKey:opacityKey];;
    }
    animation.toValue = @(1.f);
    animation.duration = MMProgressHUDAnimateInDurationShort;
    
    return animation;
}

- (CAAnimation *)_fadeOutAnimation{
    NSString *opacityKey = @"opacity";
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKey];
    animation.fromValue = [self.hud.layer.presentationLayer valueForKey:opacityKey];
    animation.toValue = @(0.f);
    animation.duration = MMProgressHUDAnimateOutDurationMedium;
    
    return animation;
}

- (CAAnimation *)_balloonAnimationIn{
    return [self _dropAnimationIn];
}

- (CAAnimation *)_balloonAnimationOut{
    CGPoint newPosition = CGPointMake(self.hud.layer.position.x, -self.hud.frame.size.height);
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.calculationMode = kCAAnimationCubic;
    
    CGPoint currentPosition = self.hud.layer.position;
    CGPoint travelVector = CGPointMake(newPosition.x - currentPosition.x, newPosition.y - currentPosition.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.hud.layer.position.x, self.hud.layer.position.y);
    CGPathAddCurveToPoint(path, NULL,
                          currentPosition.x, currentPosition.y + travelVector.y/4,
                          newPosition.x - 50.f, newPosition.y - travelVector.y/2,
                          newPosition.x, newPosition.y);
    
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    positionAnimation.rotationMode = kCAAnimationRotateAuto;
    positionAnimation.path = path;
    positionAnimation.duration = MMProgressHUDAnimateOutDurationLong;
    positionAnimation.removedOnCompletion = YES;
    
    CGPathRelease(path);
    
    return positionAnimation;
}

- (CAAnimation *)_confettiAnimationOut{
    //    self.hud.layer dr
    return nil;
}

#pragma mark - Execution
- (void)_executeShowAnimation:(CAAnimation *)animation{
    [animation setValue:MMProgressHUDAnimationShow forKey:@"name"];
    
    self.visible = YES;
    
    typeof(self) __weak weakSelf = self;
    void(^showCompletion)(void) = ^(void){
        MMProgressHUD *blockSelf = weakSelf;
        MMHudLog(@"Show animation ended: %@", blockSelf.hud);
        
        blockSelf.queuedShowAnimation = nil;
        
        if (blockSelf.queuedDismissAnimation != nil) {
            [blockSelf _executeDismissAnimation:blockSelf.queuedDismissAnimation];
            blockSelf.queuedDismissAnimation = nil;
        }
    };
    
    if ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyDismissAnimation] != nil) {
        self.queuedShowAnimation = animation;
    }
    else if([self.hud.layer animationForKey:MMProgressHUDAnimationKeyShowAnimation] == nil){
        self.queuedShowAnimation = nil;
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:showCompletion];
        {
            [self.hud.layer addAnimation:animation forKey:MMProgressHUDAnimationKeyShowAnimation];
        }
        [CATransaction commit];
    }
}

- (void)_executeDismissAnimation:(CAAnimation *)animation{
    [animation setValue:MMProgressHUDAnimationDismiss forKey:@"name"];
    
    typeof(self) __weak weakSelf = self;
    void(^endCompletion)(void) = ^(void){
        MMProgressHUD *blockSelf = weakSelf;
        MMHudLog(@"Dismiss animation ended");
        
        if (blockSelf.dismissAnimationCompletion != nil) {
            blockSelf.dismissAnimationCompletion();
        }
        
        [blockSelf.hud removeFromSuperview];
        
        blockSelf.queuedDismissAnimation = nil;
        
        //reset for next presentation
        [blockSelf.hud prepareForReuse];
        
        if (blockSelf.queuedShowAnimation != nil) {
            [blockSelf _executeShowAnimation:blockSelf.queuedShowAnimation];
        }
    };
    
    if ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyShowAnimation] != nil) {
        self.queuedDismissAnimation = animation;
    }
    else if([self.hud.layer animationForKey:MMProgressHUDAnimationKeyDismissAnimation] == nil){
        self.queuedDismissAnimation = nil;
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:endCompletion];
        {
            [self.hud.layer addAnimation:animation forKey:MMProgressHUDAnimationKeyDismissAnimation];
        }
        [CATransaction commit];
    }
}
//----Animation associalized---- Added by Hequn---<End>--2014.6.12--//
@end
