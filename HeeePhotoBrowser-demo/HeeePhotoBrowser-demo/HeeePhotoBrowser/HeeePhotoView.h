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

@interface HeeePhotoView : UIView
@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) HeeePhotoDetectingImageView *imageview;
@property (nonatomic,  weak) HeeePhotoBrowser *photoBrowser;
@property (nonatomic,assign) BOOL closePullGesture;//当图还在滑动时，关闭滑掉图片的操作
@property (nonatomic,assign) BOOL didHandleImageDownload;//是否下载过图片标志。如果下载失败，则重置为NO。

//单击回调
@property (nonatomic, strong) void (^singleTapBlock)(UITapGestureRecognizer *recognizer);

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

- (void)closeGesture;//防止上下滑的时候，同时可以单双击
- (void)openGesture;

@end
