//
//  HeeePhotoView.h
//  HeeePhotoBrowser
//
//  Created by hgy on 2018/5/5.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "HeeePhotoDetectingImageView.h"
#import "HeeePhotoBrowser.h"

@class HeeePhotoView;

@protocol HeeePhotoViewDelegate <NSObject>
@optional
- (void)photoViewLongPress:(HeeePhotoView *)photoView;
- (void)photoViewStartDragImage:(HeeePhotoView *)photoView;
- (void)photoViewEndDragImage:(HeeePhotoView *)photoView willClose:(BOOL)close;
- (void)photoViewSingleTap:(HeeePhotoView *)photoView;

@end

@interface HeeePhotoView : UIView
@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) HeeePhotoDetectingImageView *imageview;
@property (nonatomic,assign) BOOL closePullGesture;//当图还在滑动时，关闭滑掉图片的操作
@property (nonatomic,weak) id <HeeePhotoViewDelegate> delegate;
- (void)adjustImageFrames;
- (void)gestureEnable:(BOOL)enable;//防止上下滑的时候，同时可以单双击

@end
