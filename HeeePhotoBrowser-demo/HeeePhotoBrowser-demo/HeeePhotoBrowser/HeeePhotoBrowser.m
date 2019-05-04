//
//  HeeePhotoBrowser.m
//  HeeePhotoBrowser
//
//  Created by hgy on 2018/5/5.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import "HeeePhotoBrowser.h"
#import "HeeePhotoView.h"
#import "UIImageView+WebCache.h"
#import "HeeePhotoDetectingImageView.h"

@interface HeeePhotoBrowser ()<UIScrollViewDelegate,UIActionSheetDelegate>
@property (nonatomic,strong) UIWindow *window;
@property (nonatomic,strong) NSMutableArray *allPhotoView;
@property (nonatomic,strong) UIImageView *animationIV;//用于动画
@property (nonatomic,strong) NSMutableArray *NFrameArr;//新IV的frame数组
@property (nonatomic,strong) NSArray *highQualityImageArr;//如果有的话，就设置。数量可以多于photoArr的数量
@property (nonatomic,assign) NSUInteger currentIndex;//当前现实的第几张图片
@property (nonatomic,strong) UIView *fatherView;//imageViewArray里面imageView的父view
@property (nonatomic,strong) NSArray *imageViewArray;//需要包含所有的imageView
@property (nonatomic,strong) UILabel *indexLabel;
@property (nonatomic,assign) CGFloat screenWidth;
@property (nonatomic,assign) CGFloat screenHeight;
@property (nonatomic,assign) NSUInteger preLoadImageNumber;

@end

@implementation HeeePhotoBrowser
+ (instancetype)showPhotoBrowserWithImageViews:(NSArray *)imageViewArray currentIndex:(NSUInteger)currentIndex highQualityImageArray:(NSArray *)highQualityImageArr andPreLoadImageNumber:(NSUInteger)preLoadImageNumber {
    if (imageViewArray.count > 0) {
        UIImageView *IV = imageViewArray.firstObject;
        if (IV) {
            HeeePhotoBrowser *instance = [HeeePhotoBrowser new];
            instance.fatherView = IV.superview;
            instance.currentIndex = currentIndex;
            instance.preLoadImageNumber = preLoadImageNumber;
            instance.highQualityImageArr = highQualityImageArr;
            [instance setImageViewArray:imageViewArray];
            return instance;
        }
        return nil;
    }
    return nil;
}

- (void)removeFromSuperview {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserDidDisappear:)]) {
        [self.delegate photoBrowserDidDisappear:self];
    }
    
    [super removeFromSuperview];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        _NFrameArr = [NSMutableArray array];
        _animationIV = [UIImageView new];
        _animationIV.clipsToBounds = YES;
        _animationIV.contentMode = UIViewContentModeScaleAspectFill;
        _animationIV.hidden = YES;
        [self addSubview:_animationIV];
        
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.hidden = YES;
        _window.backgroundColor = [UIColor clearColor];
        _window.windowLevel = UIWindowLevelAlert;
    }
    
    return self;
}

- (CGRect)getFatherViewFrame:(UIView *)view {
    return [_fatherView convertRect:view.frame toCoordinateSpace:_window];
}

- (void)setImageViewArray:(NSArray *)imageViewArray {
    _imageViewArray = imageViewArray;
    [self addScrollView];
    [self addSubview:self.indexLabel];
    [self setUpFrames];
    [self show];
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:22];
        _indexLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
        _indexLabel.bounds = CGRectMake(0, 0, 100, 40);
        _indexLabel.center = CGPointMake(_screenWidth * 0.5, 30);
        _indexLabel.layer.cornerRadius = 15;
        _indexLabel.clipsToBounds = YES;
        
        if (self.imageViewArray.count > 0) {
            _indexLabel.text = [NSString stringWithFormat:@"1/%d", MAX((int)self.imageViewArray.count, (int)self.highQualityImageArr.count)];
        }
    }
    
    return _indexLabel;
}

- (NSMutableArray *)allPhotoView {
    if (!_allPhotoView) {
        _allPhotoView = [NSMutableArray array];
    }
    
    return _allPhotoView;
}

- (void)addScrollView
{
    __weak typeof (self) weakSelf = self;
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delaysContentTouches = NO;
    _scrollView.frame = self.bounds;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    [self addSubview:_scrollView];
    
    for (int i = 0; i < self.imageViewArray.count; i++) {
        HeeePhotoView *view = [[HeeePhotoView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
        [self.allPhotoView addObject:view];
        if (_highQualityImageArr.count <= i) {
            [view hideDownloadProgressView];
        }
        view.tag = 100 + i;
        view.imageview.tag = i;
        view.photoBrowser = self;
        UIImageView *IV = self.imageViewArray[i];
        view.imageview.image = IV.image;
        
        CGFloat W = _screenWidth;
        CGFloat H = W*IV.image.size.height/IV.image.size.width;
        
        if (!IV.image) {
            H = 9*W/16;
        }
        
        [_NFrameArr addObject:[NSValue valueWithCGRect:CGRectMake(0, (_screenHeight - H)/2, W, H)]];
        
        //处理单击
        view.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
            [weakSelf hidePhotoBrowser:recognizer];
        };
        
        if (_currentIndex == i) {
            _animationIV.image = IV.image;
            _animationIV.frame = [self getFatherViewFrame:_imageViewArray[i]];
        }
        [_scrollView addSubview:view];
    }
    
    if (_highQualityImageArr.count > _imageViewArray.count) {
        for (NSUInteger i = _imageViewArray.count; i < _highQualityImageArr.count; i++) {
            HeeePhotoView *view = [[HeeePhotoView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
            [self.allPhotoView addObject:view];
            view.tag = 100 + i;
            view.imageview.tag = i;
            view.photoBrowser = self;
            
            //处理单击
            view.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
                [weakSelf hidePhotoBrowser:recognizer];
            };
            
            [_scrollView addSubview:view];
        }
    }
    
    [self handleImageDownload];
}

- (void)setUpFrames
{
    CGRect rect = self.bounds;
    rect.size.width += 10 * 2;
    _scrollView.bounds = rect;
    _scrollView.center = CGPointMake(_screenWidth*0.5, _screenHeight*0.5);
    
    CGFloat y = 0;
    __block CGFloat w = _screenWidth;
    CGFloat h = _screenHeight;
    
    //设置所有HeeePhotoView的frame
    [_scrollView.subviews enumerateObjectsUsingBlock:^(HeeePhotoView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = 10 + idx * (10 * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, _screenHeight);
    _scrollView.contentOffset = CGPointMake(self.currentIndex * _scrollView.frame.size.width, 0);
    _indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    _indexLabel.center = CGPointMake(_screenWidth*0.5, 24);
    
    //iphone X
    if (@available(iOS 11.0, *)) {
        if ([[UIApplication sharedApplication].delegate window].safeAreaInsets.bottom == 34) {
            _indexLabel.center = CGPointMake(_screenWidth*0.5, 24 + 34);
        }
    }
}

- (void)handleImageDownload {
    __weak typeof (self) weakSelf = self;
    NSInteger start = (NSInteger)(_currentIndex - _preLoadImageNumber);
    if (start < 0) {
        start = 0;
    }
    
    NSInteger end = (NSInteger)(_currentIndex + _preLoadImageNumber + 1);
    if (end >= MAX(self.imageViewArray.count, self.highQualityImageArr.count)) {
        end = MAX(self.imageViewArray.count, self.highQualityImageArr.count);
    }
    
    for (NSInteger i = start; i < end; i++) {
        if (_highQualityImageArr.count > i) {
            HeeePhotoView *photoView = _allPhotoView[i];
            if (photoView.shouldDownloadImage) {
                UIImage *placeholderImage = nil;
                if (i < _imageViewArray.count) {
                    UIImageView *IV = self.imageViewArray[i];
                    placeholderImage = IV.image;
                }
                [photoView setImageWithURL:[NSURL URLWithString:_highQualityImageArr[i]] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image && i < weakSelf.imageViewArray.count) {
                        if (weakSelf.currentIndex == i) {
                            weakSelf.animationIV.image = image;
                        }
                        
                        CGFloat W = weakSelf.screenWidth;
                        CGFloat H = W*image.size.height/image.size.width;
                        [weakSelf.NFrameArr replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:CGRectMake(0, (weakSelf.screenHeight - H)/2, W, H)]];
                    }
                }];
            }
        }
    }
}

- (void)show {
    _window.hidden = NO;
    [_window addSubview:self];
    HeeePhotoView *view = [_scrollView viewWithTag:100 + _currentIndex];
    view.hidden = YES;
    
    //隐藏原图
    UIImageView *originalIV = _imageViewArray[self.currentIndex];
    originalIV.alpha = 0;
    
    //显示动画图
    _animationIV.hidden = NO;
    _animationIV.layer.cornerRadius = originalIV.layer.cornerRadius;
    
    _indexLabel.alpha = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        NSValue *frameValue = self.NFrameArr[self.currentIndex];
        self.animationIV.frame = frameValue.CGRectValue;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
        self.indexLabel.alpha = 1;
        self.animationIV.layer.cornerRadius = 0;
    } completion:^(BOOL finished) {
        self.animationIV.hidden = YES;
        view.hidden = NO;
    }];
}

- (void)setClearRate:(CGFloat)rate {
    self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:pow(rate, 3)];
    _indexLabel.alpha = pow(rate, 3);
}

- (void)hidePhotoBrowser:(UITapGestureRecognizer *)recognizer {
    if (_currentIndex < _imageViewArray.count) {
        HeeePhotoView *view = (HeeePhotoView *)recognizer.view;
        view.hidden = YES;
        
        //原图
        UIImageView *IV = self.imageViewArray[self.currentIndex];
        
        //更新animationIV的frame
        _animationIV.frame = [view.scrollview convertRect:view.imageview.frame toCoordinateSpace:_window];
        _animationIV.hidden = NO;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.animationIV.frame = [self getFatherViewFrame:self.imageViewArray[view.tag - 100]];
            self.animationIV.layer.cornerRadius = IV.layer.cornerRadius;
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
            self.indexLabel.alpha = 0;
        } completion:^(BOOL finished) {
            IV.alpha = 1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.window.hidden = YES;
                [self removeFromSuperview];
            });
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.window.hidden = YES;
            [self removeFromSuperview];
        }];
    }
}

- (void)hidePhotoBrowserWithFrame:(CGRect)frame {
    if (_currentIndex < _imageViewArray.count) {
        HeeePhotoView *view = [_scrollView viewWithTag:100 + _currentIndex];
        view.hidden = YES;
        
        //原图
        UIImageView *IV = self.imageViewArray[self.currentIndex];
        
        _animationIV.hidden = NO;
        _animationIV.frame = frame;
        [UIView animateWithDuration:0.25 animations:^{
            self.animationIV.frame = [self getFatherViewFrame:self.imageViewArray[view.tag - 100]];
            self.animationIV.layer.cornerRadius = IV.layer.cornerRadius;
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
            self.indexLabel.alpha = 0;
        } completion:^(BOOL finished) {
            IV.alpha = 1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.window.hidden = YES;
                [self removeFromSuperview];
            });
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.window.hidden = YES;
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    if (index >= 0 && index < MAX(self.imageViewArray.count, self.highQualityImageArr.count)) {
        _indexLabel.text = [NSString stringWithFormat:@"%d/%d", index + 1, MAX((int)self.imageViewArray.count, (int)self.highQualityImageArr.count)];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int autualIndex = scrollView.contentOffset.x/_scrollView.bounds.size.width;
    //设置当前下标
    self.currentIndex = autualIndex;
    [self handleImageDownload];
    
    if (self.currentIndex >= MAX(_imageViewArray.count, _highQualityImageArr.count)) {
        [self removeFromSuperview];
        return;
    }
    
    //恢复所有view的zoomScale为1.0
    for (HeeePhotoView *view in _scrollView.subviews) {
        if (view.imageview.tag != autualIndex) {
            view.scrollview.zoomScale = 1.0;
        }
    }
    
    //让所有原view可见
    for (int i = 0; i < _imageViewArray.count; i++) {
        UIImageView *originalIV = _imageViewArray[i];
        originalIV.alpha = 1;
    }
    
    //让滑动到对应的原view不可见，刷新animationIV
    if (_currentIndex < _imageViewArray.count) {
        NSValue *frameValue = _NFrameArr[_currentIndex];
        UIImageView *IV = _imageViewArray[_currentIndex];
        IV.alpha = 0;
        _animationIV.image = IV.image;
        _animationIV.frame = frameValue.CGRectValue;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didScrollToIndex:)]) {
        [_delegate photoBrowser:self didScrollToIndex:autualIndex];
    }
}

@end

