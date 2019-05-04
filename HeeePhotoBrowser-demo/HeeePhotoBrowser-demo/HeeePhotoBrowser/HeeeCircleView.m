//
//  HeeeCircleView.m
//  HeeeCircleView
//
//  Created by hgy on 2018/4/18.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import "HeeeCircleView.h"

@implementation HeeeCircleView{
    CAShapeLayer *layer;
    NSTimer *animateTimer;
    CGFloat endAngle;
    CGFloat unit;
    CGFloat lastProgress;
    CGFloat didCompleteProgress;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, MIN(frame.size.width, frame.size.height), MIN(frame.size.width, frame.size.height))];
    if (self) {
        _lineWidth = 10;
        _clockwise = YES;
        _circleColor = [UIColor grayColor];
        _fillColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    
    if (_lineWidth > self.frame.size.width/2) {
        _lineWidth = self.frame.size.width/2;
    }
}

- (void)setProgress:(CGFloat)progress {
    lastProgress = _progress;
    _progress = progress;
    
    if (_progress > 1) {
        _progress = 1;
    }else if (_progress < 0) {
        _progress = 0;
    }
}

- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = startAngle;
    
    if (_startAngle > 1) {
        _startAngle = 1;
    }else if (_startAngle < 0) {
        _startAngle = fabs(_startAngle);
        _startAngle = _startAngle - (int)_startAngle;
        if (_clockwise) {
            _startAngle = 1 - _startAngle;
        }
    }
}

- (void)createCircleAnimate:(BOOL)animate {
    if (!layer) {
        layer = [CAShapeLayer new];
        layer.lineWidth = _lineWidth;
        layer.strokeColor = _circleColor.CGColor;
        layer.fillColor = _fillColor.CGColor;
        [self.layer addSublayer:layer];
    }
    
    didCompleteProgress = 0;
    
    if (_isRoundLineCap) {
        layer.lineCap = kCALineCapRound;
    }else{
        layer.lineCap = kCALineCapButt;
    }
    
    if (_duration == 0) {
        animate = NO;
    }
    
    if (animate) {
        endAngle = _startAngle + (_clockwise?lastProgress:(-lastProgress));
    }else{
        endAngle = _startAngle + (_clockwise?_progress:(-_progress));
    }
    
    if (animateTimer) {
        [animateTimer invalidate];
        animateTimer = nil;
    }
    
    if (animate) {
        unit = (_progress - lastProgress)/(_duration*60);
        if (!_clockwise) {
            unit = -unit;
        }
        animateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(circleAnimate) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:animateTimer forMode:NSRunLoopCommonModes];
    }else{
        [self drawCircle:NO];
    }
}

- (void)circleAnimate {
    endAngle+=unit;
    didCompleteProgress+=fabs(unit);
    
    CGFloat offset = fabs(didCompleteProgress - fabs(self.progress - lastProgress));
    if (offset < fabs(unit) && offset > 0) {
        if (animateTimer) {
            [animateTimer invalidate];
            animateTimer = nil;
        }
        
        didCompleteProgress = self.progress;
        endAngle = _startAngle + (_clockwise?self.progress:(-self.progress));
        [self drawCircle:YES];
    }else{
        [self drawCircle:YES];
    }
}

- (void)drawCircle:(BOOL)animate {
    CGFloat temEndAngle = endAngle;
    
    if (_progress == 0) {
        temEndAngle = _startAngle;
    }else if (_progress == 1 && endAngle > 0 && endAngle < 1) {
        temEndAngle = 1 - _startAngle;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:(self.frame.size.width/2 - _lineWidth/2) startAngle:_startAngle*2*M_PI endAngle:temEndAngle*2*M_PI clockwise:_clockwise];
    layer.path = [path CGPath];
    
    if (animate && _animateCompletion) {
        _animateCompletion(YES);
    }
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    if (animateTimer) {
        [animateTimer invalidate];
        animateTimer = nil;
    }
}

@end
