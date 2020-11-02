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
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didRemoveAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didShowImageAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didLongPressAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser startDragImageAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser endDragImageAtIndex:(NSInteger)index close:(BOOL)close;//close表示结束拖拽后是否会关闭photoBrowser
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser willDismissImageAtIndex:(NSInteger)index;
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didDismissImageAtIndex:(NSInteger)index;

@end

@interface HeeePhotoBrowser : UIView
- (void)setScrollEnabled:(BOOL)scrollEnabled;
- (void)setClearRate:(CGFloat)rate;
- (void)hidePhotoBrowserWithFrame:(CGRect)frame;

/**
 实例方法
 
 @param imageViewArray 包含所有需要展示的imageView
 @param currentIndex 第一次点击的图片位置(imageViewArray中的位置)
 @param highQualityImageUrls 如果imageViewArray展示的是缩略图，那么如果需要点开本工具后查看高清图,则highQualityImageUrls里放高清图url
 */
+ (instancetype)showWithImageViews:(NSArray <UIImageView *>*)imageViewArray
                      currentIndex:(NSUInteger)currentIndex
              highQualityImageUrls:(NSArray <NSString *>*)highQualityImageUrls;

- (void)hide;

@property (nonatomic,weak) id<HeeePhotoBrowserDelegate> delegate;

/// 向现有显示工具里动态添加网络图片
/// @param imageUrlArray 所添加图片的地址
/// @param forward 是加到最前面还是最后面
- (void)addImages:(NSArray <NSString *>*)imageUrlArray direction:(BOOL)forward;

@end
