//
//  HeeePhotoDetectingImageView.h
//  HeeePhotoBrowser
//
//  Created by hgy on 2018/5/5.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HeeePhotoView;
@class HeeePhotoBrowser;

@interface HeeePhotoDetectingImageView : UIImageView
@property (nonatomic,weak) HeeePhotoBrowser *photoBrowser;
@property (nonatomic,weak) HeeePhotoView *photoView;
@property (nonatomic,weak) UIScrollView *fatherView;
@property (nonatomic,assign) CGRect originalFrame;
@property (nonatomic,copy) void (^startDragImage) (void);
@property (nonatomic,copy) void (^endDragImage) (BOOL close);

- (void)endPull;
@end
