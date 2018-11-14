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

@interface HeeePhotoDetectingImageView()
@property (nonatomic,assign) CGPoint lastPoint;
@property (nonatomic,assign) BOOL movable;//防止左右滑的时候，同时可以上下滑
@property (nonatomic,assign) CGPoint originalPoint;
@property (nonatomic,assign) CGAffineTransform originalTransform;
@property (nonatomic,assign) CGFloat deviationX;
@property (nonatomic,assign) CGFloat deviationY;
@property (nonatomic,assign) BOOL isSetAnchor;
@property (nonatomic,assign) CGFloat screenWidth;
@property (nonatomic,assign) CGFloat screenHeight;

@end

@implementation HeeePhotoDetectingImageView
- (instancetype)init
{
    self = [super init];
    if (self) {
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    }
    
    return self;
}

- (void)appDidEnterBackground {
    [self touchesEnded:[NSSet new] withEvent:nil];
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
        
        self.fatherView.userInteractionEnabled = NO;
        self.fatherView.scrollEnabled = NO;
        [self.photoView closeGesture];
        
        _deviationX = point.x - _lastPoint.x;
        _deviationY = point.y - _lastPoint.y;
        _lastPoint = point;
        _movable = YES;
        [self.photoBrowser.scrollView setScrollEnabled:NO];//关闭左右滑动
        
        self.center = CGPointMake(self.center.x + _deviationX, self.center.y + _deviationY);
        
        CGFloat currentDeviationFromBegin = point.y - self.originalPoint.y;
        if (currentDeviationFromBegin <= 0) {
            currentDeviationFromBegin = 0;
        }
        
        if (currentDeviationFromBegin >= _screenHeight - 100) {
            currentDeviationFromBegin = _screenHeight - 100;
        }
        
        CGFloat ration = 1 - currentDeviationFromBegin/_screenHeight;
        [self.photoBrowser setClearRate:ration];
        self.transform = CGAffineTransformScale(self.originalTransform, ration, ration);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_photoView.closePullGesture) {
        return;
    }
    
    self.fatherView.userInteractionEnabled = YES;
    self.fatherView.scrollEnabled = YES;
    [self.photoView openGesture];
    _isSetAnchor = NO;
    
    //初始化
    _lastPoint = CGPointZero;
    if (_movable == NO) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    
    if (_deviationY > 0 && point.y > self.originalPoint.y) {
        CGRect rect = [self.fatherView convertRect:self.frame toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
        [self.photoBrowser hidePhotoBrowserWithFrame:rect];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            [self.photoBrowser setClearRate:1];
            self.transform = self.originalTransform;
            self.frame = self.originalFrame;
        }completion:^(BOOL finished) {
            [self setAnchorPoint:CGPointMake(0.5, 0.5)];
            [self.photoBrowser.scrollView setScrollEnabled:YES];
            self.movable = NO;
        }];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (_photoView.closePullGesture) {
        return;
    }
    
    self.fatherView.userInteractionEnabled = YES;
    [self.photoView openGesture];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint oldOrigin = self.frame.origin;
    self.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = self.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    self.center = CGPointMake (self.center.x - transition.x, self.center.y - transition.y);
}

@end
