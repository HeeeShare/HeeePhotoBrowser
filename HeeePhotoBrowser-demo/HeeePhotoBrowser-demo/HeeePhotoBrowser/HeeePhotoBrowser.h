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
@property (nonatomic,weak) UIViewController *vc;
@property (nonatomic,strong) UIScrollView *scrollView;
- (void)setClearRate:(CGFloat)rate;
- (void)hidePhotoBrowserWithFrame:(CGRect)frame;

/**
 生成方法
 
 @param imageViewArray 包含所有需要展示的imageView
 @param currentIndex 第一次点击的图片位置
 @param highQualityImageArr 高清图url数组，可以多于imageViewArray里的imageView
 @param preLoadImageNumber 预加载图片数量，当前index左右两侧。
 */
+ (instancetype)showPhotoBrowserWithImageViews:(nonnull NSArray *)imageViewArray currentIndex:(NSUInteger)currentIndex highQualityImageArray:(nullable NSArray *)highQualityImageArr andPreLoadImageNumber:(NSUInteger)preLoadImageNumber;
@property (nonatomic,weak) id<HeeePhotoBrowserDelegate> delegate;

@end
