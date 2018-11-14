//
//  HeeePhotoBrowser.h
//  HeeePhotoBrowser
//
//  Created by hgy on 2018/5/5.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HeeePhotoBrowser;

@protocol HeeePhotoBrowserDelegate <NSObject>
@optional
- (void)photoBrowserDidDisappear:(HeeePhotoBrowser *)photoBrowser;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didScrollToIndex:(NSInteger)index;

@end

@interface HeeePhotoBrowser : UIView
@property (nonatomic,strong) UIScrollView *scrollView;//(无需操作)
- (void)setClearRate:(CGFloat)rate;//(无需操作)
- (void)hidePhotoBrowserWithFrame:(CGRect)frame;//(无需操作)

/**
 生成方法
 
 @param imageViewArray 包含所有需要展示的imageView
 @param clickImageIndex 第一次点击的图片位置
 @param highQualityImageArr 高清图url数组，可以多于imageViewArray里的imageView
 */
+ (instancetype)showPhotoBrowserWithImageView:(nonnull NSArray *)imageViewArray clickImageIndex:(NSUInteger)clickImageIndex andHighQualityImageArray:(nullable NSArray *)highQualityImageArr;
@property (nonatomic,weak) id<HeeePhotoBrowserDelegate> delegate;

@end
