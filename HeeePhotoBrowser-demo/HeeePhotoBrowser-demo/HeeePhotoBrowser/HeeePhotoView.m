//
//  HeeePhotoView.m
//  HeeePhotoBrowser
//
//  Created by hgy on 2018/5/5.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import "HeeePhotoView.h"
#import "HeeeCircleView.h"

@interface HeeePhotoView() <UIScrollViewDelegate>
@property (nonatomic,strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong) UITapGestureRecognizer *singleTap;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic,assign) CGFloat screenWidth;
@property (nonatomic,assign) CGFloat screenHeight;
@property (nonatomic,strong) HeeeCircleView *downloadProgressView;
@property (nonatomic,copy) NSURL *imageUrl;

@end

@implementation HeeePhotoView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _shouldDownloadImage = YES;
        [self addSubview:self.scrollview];
        [self addSubview:self.downloadProgressView];
        self.downloadProgressView.center = CGPointMake(_screenWidth/2, _screenHeight/2);
        self.scrollview.delaysContentTouches = NO;
        //添加手势
        [self addGestureRecognizer:self.doubleTap];
        [self addGestureRecognizer:self.singleTap];
        [self addGestureRecognizer:self.longPress];
    }
    
    return self;
}

- (UIScrollView *)scrollview {
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        if (@available(iOS 11.0, *)) {
            _scrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollview.delegate = self;
        _scrollview.clipsToBounds = YES;
        self.imageview.fatherView = _scrollview;
        [_scrollview addSubview:self.imageview];
    }
    
    return _scrollview;
}

- (HeeePhotoDetectingImageView *)imageview {
    if (!_imageview) {
        _imageview = [[HeeePhotoDetectingImageView alloc] init];
        _imageview.contentMode = UIViewContentModeScaleAspectFit;
        _imageview.clipsToBounds = YES;
        _imageview.photoView = self;
        _imageview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _imageview.userInteractionEnabled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.imageview.photoBrowser = self.photoBrowser;
        });
        
        __weak __typeof(self) weakSelf = self;
        _imageview.startDragImage = ^{
            !weakSelf.startDragImage?:weakSelf.startDragImage();
        };
        
        _imageview.endDragImage = ^(BOOL close) {
            !weakSelf.endDragImage?:weakSelf.endDragImage(close);
        };
    }
    
    return _imageview;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired = 1;
    }
    
    return _doubleTap;
}

- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
        //不让两个手势同时起作用
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
    }
    
    return _singleTap;
}

- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress)];
        _longPress.minimumPressDuration = 0.3;
    }
    
    return _longPress;
}

- (HeeeCircleView *)downloadProgressView {
    if (!_downloadProgressView) {
        _downloadProgressView = [[HeeeCircleView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _downloadProgressView.userInteractionEnabled = NO;
        _downloadProgressView.circleColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        _downloadProgressView.layer.cornerRadius = 20;
        _downloadProgressView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
        _downloadProgressView.layer.borderWidth = 3;
        _downloadProgressView.lineWidth = 3;
        _downloadProgressView.isRoundLineCap = YES;
    }
    
    return _downloadProgressView;
}

-(void)closeGesture {
    self.singleTap.enabled = NO;
    self.doubleTap.enabled = NO;
    self.longPress.enabled = NO;
}

- (void)openGesture {
    self.singleTap.enabled = YES;
    self.doubleTap.enabled = YES;
    self.longPress.enabled = YES;
}

- (void)hideDownloadProgressView {
    self.downloadProgressView.hidden = YES;
    _shouldDownloadImage = NO;
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    _shouldDownloadImage = NO;
    self.imageUrl = url;
    
    __weak typeof (self) weakSelf = self;
    [weakSelf.imageview sd_setImageWithPreviousCachedImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        [weakSelf bringSubviewToFront:weakSelf.downloadProgressView];
        weakSelf.downloadProgressView.hidden = NO;
        weakSelf.downloadProgressView.progress = (CGFloat)receivedSize/(CGFloat)expectedSize;
        [weakSelf.downloadProgressView createCircleAnimate:NO];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            weakSelf.shouldDownloadImage = YES;
        }
        
        if (image) {
            weakSelf.downloadProgressView.hidden = YES;
            
            if (completedBlock) {
                completedBlock(image,error,cacheType,imageURL);
            }
            
            //更新新下载图片的frame
            CGPoint centerPoint = weakSelf.imageview.center;
            CGFloat W = weakSelf.screenWidth*weakSelf.imageview.transform.a;
            CGFloat H = W*image.size.height/image.size.width;
            weakSelf.imageview.frame = CGRectMake(0, 0, W, H);
            weakSelf.imageview.center = centerPoint;
            weakSelf.imageview.originalFrame = CGRectMake(0, (weakSelf.screenHeight - H)/2, weakSelf.screenWidth, weakSelf.screenWidth*H/W);
        }else{
            weakSelf.shouldDownloadImage = YES;
        }
    }];
}

#pragma mark - 手势处理
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self];
    if (self.scrollview.zoomScale <= 1.0) {
        CGFloat scaleX = touchPoint.x + self.scrollview.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + self.scrollview.contentOffset.y;//需要放大的图片的Y点
        [self.scrollview zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
    } else {
        [self.scrollview setZoomScale:1.0 animated:YES]; //还原
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if (self.singleTapBlock) {
        self.singleTapBlock(recognizer);
    }
}

- (void)handleLongPress {
    if (self.longPress.state == UIGestureRecognizerStateBegan) {
        !self.longPressBlock?:self.longPressBlock();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollview.frame = self.bounds;
    [self adjustFrames];
}

- (void)adjustFrames {
    CGRect frame = self.scrollview.frame;
    if (self.imageview.image) {
        CGSize imageSize = self.imageview.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        CGFloat ratio = frame.size.width/imageFrame.size.width;
        imageFrame.size.height = imageFrame.size.height*ratio;
        imageFrame.size.width = frame.size.width;
        
        self.imageview.frame = imageFrame;
        self.scrollview.contentSize = self.imageview.frame.size;
        self.imageview.center = [self centerOfScrollViewContent:self.scrollview];
        
        //默认将长图置中
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (imageFrame.size.height > self.screenHeight) {
                [self.scrollview setContentOffset:CGPointMake(0, (imageFrame.size.height - self.screenHeight)/2) animated:NO];
            }
        });
        
        //将长图滚动到顶部
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (imageFrame.size.height > self.screenHeight) {
                [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        });
        
        CGFloat maxScale = frame.size.height/imageFrame.size.height;
        maxScale = frame.size.width/imageFrame.size.width>maxScale?frame.size.width/imageFrame.size.width:maxScale;
        maxScale = maxScale>2.0?maxScale:2.0;
        
        self.scrollview.minimumZoomScale = 1.0;
        self.scrollview.maximumZoomScale = maxScale;
        self.scrollview.zoomScale = 1.0f;
    }else{
        frame.origin = CGPointZero;
        self.imageview.frame = frame;
        self.scrollview.contentSize = self.imageview.frame.size;
    }
    
    self.scrollview.contentOffset = CGPointZero;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageview.center = [self centerOfScrollViewContent:scrollView];
    [self.imageview endPull];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == 0) {
        scrollView.delaysContentTouches = NO;
    }else{
        scrollView.delaysContentTouches = YES;
    }
    
    _closePullGesture = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.closePullGesture = NO;
    });
}

@end
