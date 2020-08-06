//
//  HeeePhotoDetectingImageView.m
//  HeeePhotoBrowser
//
//  Created by hgy on 2018/5/5.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import "HeeePhotoDetectingImageView.h"
#import "HeeePhotoBrowser.h"
#import "HeeePhotoView.h"

@interface HeeePhotoDetectingImageView()<UIGestureRecognizerDelegate>
@property (nonatomic,assign) CGPoint lastPoint;
@property (nonatomic,assign) BOOL moving;//开始滑动标志
@property (nonatomic,assign) BOOL movable;//防止左右滑的时候，同时可以上下滑
@property (nonatomic,assign) CGPoint originalPoint;
@property (nonatomic,assign) CGAffineTransform originalTransform;
@property (nonatomic,assign) CGFloat deviationX;
@property (nonatomic,assign) CGFloat deviationY;
@property (nonatomic,assign) BOOL isSetAnchor;
@property (nonatomic,assign) BOOL endPullFlag;

@end

@implementation HeeePhotoDetectingImageView
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    }
    
    return self;
}

- (void)appDidEnterBackground {
    [self touchesEnded:[NSSet new] withEvent:nil];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint point = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        if (self.fatherView.contentOffset.y == 0 && point.y > 0) {
            self.fatherView.canCancelContentTouches = NO;
        }
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_photoView.closePullGesture) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    self.originalTransform = self.transform;
    self.originalFrame = self.frame;
    self.originalPoint = point;
    self.lastPoint = point;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_photoView.closePullGesture) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGPoint point = [touch locationInView:window];
    
    //每次开始触摸时，从上往下滑，且与竖直方向夹角的正切值小于1/3时是滑掉图片，否则是左右切换图片。
    if ((point.y > _lastPoint.y && fabs(point.y - _lastPoint.y) >= 3*fabs(point.x - _lastPoint.x)) || _movable) {
        if (!_isSetAnchor) {
            _isSetAnchor = YES;
            CGPoint pointInSelf = [window convertPoint:point toView:self];
            [self setAnchorPoint:CGPointMake(self.transform.a*pointInSelf.x/self.frame.size.width, self.transform.a*pointInSelf.y/self.frame.size.height)];
        }
        
        _endPullFlag = YES;
        self.fatherView.userInteractionEnabled = NO;
        self.fatherView.scrollEnabled = NO;
        [self.photoView gestureEnable:NO];
        
        _deviationX = point.x - _lastPoint.x;
        _deviationY = point.y - _lastPoint.y;
        _lastPoint = point;
        _movable = YES;
        [self.photoBrowser setScrollEnabled:NO];//关闭左右滑动
        
        self.center = CGPointMake(self.center.x + _deviationX, self.center.y + _deviationY);
        
        CGFloat currentDeviationFromBegin = point.y - self.originalPoint.y;
        if (currentDeviationFromBegin <= 0) {
            currentDeviationFromBegin = 0;
        }
        
        CGFloat ScreenHeight = [UIScreen mainScreen].bounds.size.height;
        if (currentDeviationFromBegin >= ScreenHeight - 100) {
            currentDeviationFromBegin = ScreenHeight - 100;
        }
        
        CGFloat ration = 1 - currentDeviationFromBegin/ScreenHeight;
        [self.photoBrowser setClearRate:ration];
        self.transform = CGAffineTransformScale(self.originalTransform, ration, ration);
        
        if (!self.moving && self.startDragImage) {
            self.startDragImage();
        }
        _moving = YES;
        _draging = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _endPullFlag = NO;
    _isSetAnchor = NO;
    _moving = NO;
    self.fatherView.userInteractionEnabled = YES;
    self.fatherView.canCancelContentTouches = YES;
    self.fatherView.scrollEnabled = YES;
    [self.photoView gestureEnable:YES];
    
    if (_photoView.closePullGesture) {
        return;
    }
    
    _lastPoint = CGPointZero;
    if (_movable == NO) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    
    if (_deviationY > 0 && point.y > self.originalPoint.y) {
        CGRect rect = [self.fatherView convertRect:self.frame toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
        [self.photoBrowser hidePhotoBrowserWithFrame:rect];
        !self.endDragImage?:self.endDragImage(YES);
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            [self.photoBrowser setClearRate:1];
            self.transform = self.originalTransform;
            self.frame = self.originalFrame;
        }completion:^(BOOL finished) {
            [self setAnchorPoint:CGPointMake(0.5, 0.5)];
            [self.photoBrowser setScrollEnabled:YES];
            self.movable = NO;
        }];
        
        if (self.endDragImage) {
            self.endDragImage(NO);
        }
    }
    
    self.draging = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.draging = NO;
    });
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self touchesEnded:[NSSet new] withEvent:nil];
}

- (void)endPull {
    self.fatherView.userInteractionEnabled = YES;
    self.fatherView.scrollEnabled = YES;
    if (_endPullFlag) {
        [self.photoBrowser setClearRate:1];
        self.transform = self.originalTransform;
        self.frame = self.originalFrame;
        [self setAnchorPoint:CGPointMake(0.5, 0.5)];
        [self.photoBrowser setScrollEnabled:YES];
        [self.photoView gestureEnable:YES];
        _endPullFlag = NO;
    }
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    CGPoint oldOrigin = self.frame.origin;
    self.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = self.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    self.center = CGPointMake (self.center.x - transition.x, self.center.y - transition.y);
}

@end
