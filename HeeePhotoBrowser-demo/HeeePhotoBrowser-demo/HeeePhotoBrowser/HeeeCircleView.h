//
//  HeeeCircleView.h
//  HeeeCircleView
//
//  Created by hgy on 2018/4/18.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^animateCompletion)(BOOL finish);//finish:动画正常结束是否
@interface HeeeCircleView : UIView
//配置
@property (nonatomic,assign) CGFloat startAngle;//起始角(0~1.0)，默认0(3点钟方向)
@property (nonatomic,assign) CGFloat duration;//默认0s
@property (nonatomic,strong) UIColor *circleColor;//圆环颜色，默认grayColor
@property (nonatomic,strong) UIColor *fillColor;//填充色，默认clearColor
@property (nonatomic,assign) CGFloat lineWidth;//默认10
@property (nonatomic,assign) BOOL isRoundLineCap;//是否是圆形端点样式，默认NO
@property (nonatomic,assign) BOOL clockwise;//是否顺时针，默认顺时针
@property (nonatomic,assign) CGFloat progress;//设置进度(0~1.0)
@property (nonatomic,  copy) animateCompletion animateCompletion;//动画完成回调

//开始
- (void)createCircleAnimate:(BOOL)animate;

@end
