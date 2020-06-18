//
//  HeeePhotoBrowser.h
//  HeeePhotoBrowser
//
//  Created by hgy on 2018/5/5.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HeeePhotoBrowser;

NS_ASSUME_NONNULL_BEGIN

@protocol HeeePhotoBrowserDelegate <NSObject>
@optional
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didDisappearAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didShowImageAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didLongPressAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser startDragImageAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser endDragImageAtIndex:(NSInteger)index close:(BOOL)close;//close表示结束拖拽后是否会关闭photoBrowser

@end

@interface HeeePhotoBrowser : UIView
- (void)setScrollEnabled:(BOOL)scrollEnabled;
- (void)setClearRate:(CGFloat)rate;
- (void)hidePhotoBrowserWithFrame:(CGRect)frame;

/**
 生成方法
 
 @param imageViewArray 包含所有需要展示的imageView
 @param currentIndex 第一次点击的图片位置
 @param highQualityImageArr 高清图url数组，可以多于imageViewArray里的imageView
 @param preLoadImageCount 预加载图片数量，当前index左右两侧。
 */
+ (instancetype)showPhotoBrowserWithImageViews:(nonnull NSArray *)imageViewArray currentIndex:(NSUInteger)currentIndex highQualityImageArray:(nullable NSArray *)highQualityImageArr andPreLoadImageCount:(NSUInteger)preLoadImageCount;
@property (nonatomic,weak) id<HeeePhotoBrowserDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
