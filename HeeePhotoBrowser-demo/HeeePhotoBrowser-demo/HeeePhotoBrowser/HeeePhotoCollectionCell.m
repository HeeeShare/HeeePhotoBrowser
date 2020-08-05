//
//  HeeePhotoCollectionCell.m
//  HeeePhotoBrowser-demo
//
//  Created by Heee on 2020/8/4.
//  Copyright © 2020 hgy. All rights reserved.
//

#import "HeeePhotoCollectionCell.h"
#import "HeeePhotoCollectionCellModel.h"
#import "HeeePhotoView.h"
#import "HeeeCircleView.h"

@interface HeeePhotoCollectionCell ()<HeeePhotoViewDelegate>
@property (nonatomic,strong) HeeePhotoView *photoView;
@property (nonatomic,strong) HeeeCircleView *downloadProgressView;

@end

@implementation HeeePhotoCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoView];
        
        [self.contentView addSubview:self.downloadProgressView];
        self.downloadProgressView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    }
    return self;
}

- (void)setModel:(HeeePhotoCollectionCellModel *)model {
    _model = model;
    
    __weak __typeof(self) weakSelf = self;
    self.photoView.imageview.image = model.image;
    if (model.imageUrl.length && !model.downloadProgress) {
        self.downloadProgressView.hidden = NO;
        [model loadImage:^(CGFloat downloadProgress) {
            weakSelf.downloadProgressView.progress = downloadProgress;
            [weakSelf.downloadProgressView createCircleAnimate:YES];
            if (downloadProgress==1.0) {
                weakSelf.downloadProgressView.hidden = YES;
            }
        } completed:^(UIImage *image) {
            if (image) {
                weakSelf.photoView.imageview.image = image;
            }
        }];
    }else{
        self.downloadProgressView.hidden = YES;
    }
    
    if (self.photoView.scrollview.zoomScale == 1.0 && self.photoView.imageview.transform.a == 1 && !self.photoView.imageview.animateFlag) {
        [self.photoView adjustFrames];
    }
}

- (void)resetZoomScale {
    self.photoView.scrollview.zoomScale = 1.0;
}

#pragma mark - HeeePhotoViewDelegate
- (void)photoViewLongPress:(HeeePhotoView *)photoView {
    if (_delegate && [_delegate respondsToSelector:@selector(photoViewLongPress:)]) {
        [_delegate photoViewLongPress:photoView];
    }
}

- (void)photoViewStartDragImage:(HeeePhotoView *)photoView {
    if (_delegate && [_delegate respondsToSelector:@selector(photoViewStartDragImage:)]) {
        [_delegate photoViewStartDragImage:photoView];
    }
}

- (void)photoViewEndDragImage:(HeeePhotoView *)photoView willClose:(BOOL)close {
    if (_delegate && [_delegate respondsToSelector:@selector(photoViewEndDragImage:willClose:)]) {
        [_delegate photoViewEndDragImage:photoView willClose:close];
    }
}

- (void)photoViewSingleTap:(HeeePhotoView *)photoView {
    if (_delegate && [_delegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [_delegate photoViewSingleTap:photoView];
    }
}

#pragma mark - lazy
- (HeeePhotoView *)photoView {
    if (!_photoView) {
        _photoView = [[HeeePhotoView alloc] initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _photoView.delegate = self;
    }
    
    return _photoView;
}

- (HeeeCircleView *)downloadProgressView {
    if (!_downloadProgressView) {
        _downloadProgressView = [[HeeeCircleView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _downloadProgressView.userInteractionEnabled = NO;
        _downloadProgressView.circleColor = [UIColor redColor];
        _downloadProgressView.layer.cornerRadius = 20;
        _downloadProgressView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
        _downloadProgressView.layer.borderWidth = 3;
        _downloadProgressView.duration = 0.3;
        _downloadProgressView.lineWidth = 3;
        _downloadProgressView.isRoundLineCap = YES;
    }
    
    return _downloadProgressView;
}

@end
