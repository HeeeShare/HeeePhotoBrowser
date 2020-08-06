//
//  HeeePhotoBrowser.m
//  HeeePhotoBrowser
//
//  Created by hgy on 2018/5/5.
//  Copyright © 2018年 hgy. All rights reserved.
//

#define HPBScreenWidth [UIScreen mainScreen].bounds.size.width
#define HPBScreenHeight [UIScreen mainScreen].bounds.size.height

#import "HeeePhotoBrowser.h"
#import "HeeePhotoView.h"
#import "UIImageView+WebCache.h"
#import "HeeePhotoDetectingImageView.h"
#import "HeeePhotoCollectionCell.h"
#import "HeeePhotoCollectionCellModel.h"

@interface HeeePhotoBrowser ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HeeePhotoCollectionCellDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIImageView *animationIV;
@property (nonatomic,strong) NSMutableArray <HeeePhotoCollectionCellModel *>*dataArray;
@property (nonatomic,strong) NSArray <UIImageView *>*imageViewArray;
@property (nonatomic,strong) NSArray <NSString *>*highQualityImageUrls;
@property (nonatomic,strong) NSMutableArray *allPhotoViewArray;
@property (nonatomic,assign) NSUInteger currentIndex;
@property (nonatomic,assign) NSUInteger backwardImageCount;
@property (nonatomic,strong) NSMutableArray <HeeePhotoCollectionCell *>*reuseCellArray;
@property (nonatomic,strong) UILabel *indexLabel;
@property (nonatomic,assign) BOOL noSupportLongPress;

@end

@implementation HeeePhotoBrowser
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, HPBScreenWidth, HPBScreenHeight);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        [self addSubview:self.animationIV];
        [self addSubview:self.collectionView];
        [self addSubview:self.indexLabel];
    }
    
    return self;
}

- (void)removeFromSuperview {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didRemoveAtIndex:)]) {
        [self.delegate photoBrowser:self didRemoveAtIndex:self.currentIndex];
    }
    
    [super removeFromSuperview];
}

+ (instancetype)showWithImageViews:(NSArray <UIImageView *>*)imageViewArray
                      currentIndex:(NSUInteger)currentIndex
              highQualityImageUrls:(NSArray <NSString *>*)highQualityImageUrls {
    if (imageViewArray.count > 0) {
        HeeePhotoBrowser *instance = [HeeePhotoBrowser new];
        instance.imageViewArray = imageViewArray;
        instance.currentIndex = currentIndex;
        instance.highQualityImageUrls = highQualityImageUrls;
        [instance setup];
        [instance show];
        return instance;
    }
    return nil;
}

- (void)setup {
    for (int i = 0; i < self.imageViewArray.count; i++) {
        HeeePhotoCollectionCellModel *model = [HeeePhotoCollectionCellModel new];
        if (self.highQualityImageUrls.count > i) {
            model.imageUrl = self.highQualityImageUrls[i];
        }
        
        [self.dataArray addObject:model];
    }
    
    [self.collectionView reloadData];
    [self setupIndexLabel];
}

- (void)addImages:(NSArray<NSString *> *)imageUrlArray direction:(BOOL)forward {
    if (forward) {
        NSUInteger count = self.dataArray.count;
        NSMutableArray *reloadArr = [NSMutableArray array];
        for (NSUInteger i = 0; i < imageUrlArray.count; i++) {
            NSString *imageUrl = imageUrlArray[i];
            HeeePhotoCollectionCellModel *model = [HeeePhotoCollectionCellModel new];
            model.imageUrl = imageUrl;
            [self.dataArray addObject:model];
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:count + i inSection:0];
            [reloadArr addObject:indexpath];
        }
        [UIView performWithoutAnimation:^{
            [self.collectionView insertItemsAtIndexPaths:reloadArr];
        }];
    }else{
        CGFloat offsetX = self.collectionView.contentOffset.x;
        NSMutableArray *temArr = [NSMutableArray array];
        NSMutableArray *reloadArr = [NSMutableArray array];
        for (NSUInteger i = 0; i < imageUrlArray.count; i++) {
            NSString *imageUrl = imageUrlArray[i];
            HeeePhotoCollectionCellModel *model = [HeeePhotoCollectionCellModel new];
            model.imageUrl = imageUrl;
            [temArr addObject:model];
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
            [reloadArr addObject:indexpath];
        }
        self.backwardImageCount+=imageUrlArray.count;
        
        self.currentIndex+=temArr.count;
        [self.dataArray insertObjects:temArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, temArr.count)]];
        [UIView performWithoutAnimation:^{
            [self.collectionView insertItemsAtIndexPaths:reloadArr];
        }];
        [self.collectionView setContentOffset:CGPointMake(offsetX + temArr.count*self.collectionView.bounds.size.width, 0) animated:NO];
        if (!self.collectionView.isTracking) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        }
    }
    
    [self setupIndexLabel];
}

- (void)show {
    //隐藏原图
    UIImageView *currentImgV = self.imageViewArray[self.currentIndex];
    currentImgV.alpha = 0;
    
    //显示动画图
    self.animationIV.image = currentImgV.image;
    self.animationIV.frame = [self getImgVFrameInWindow:currentImgV];
    self.animationIV.hidden = NO;
    
    self.collectionView.hidden = YES;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
        self.animationIV.frame = [self getImageViewFrame:currentImgV.image];
        self.animationIV.layer.cornerRadius = 0;
    } completion:^(BOOL finished) {
        self.animationIV.hidden = YES;
        self.collectionView.hidden = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didShowImageAtIndex:)]) {
            [self.delegate photoBrowser:self didShowImageAtIndex:self.currentIndex];
        }
    }];
}

- (void)setupIndexLabel {
    self.indexLabel.text = [NSString stringWithFormat:@"%@/%@",@(self.currentIndex+1),@(self.dataArray.count)];
    self.indexLabel.hidden = self.dataArray.count>1?0:1;
    [self.indexLabel sizeToFit];
    CGFloat width = self.indexLabel.bounds.size.width + 24;
    CGFloat height = self.indexLabel.bounds.size.height + 8;
    CGFloat top = 20;
    if (@available(iOS 11.0, *)) {
        top = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    CGFloat left = (HPBScreenWidth - width)/2;
    self.indexLabel.frame = CGRectMake(left, top, width, height);
    self.indexLabel.layer.cornerRadius = self.indexLabel.bounds.size.height/2;
}

- (CGRect)getImageViewFrame:(UIImage *)image {
    CGFloat W = HPBScreenWidth;
    CGFloat H = W*image.size.height/image.size.width;
    
    if (!image) {
        H = 9*W/16;
    }
    
    return CGRectMake(0, (HPBScreenHeight - H)/2, W, H);
}

- (CGRect)getImgVFrameInWindow:(UIView *)view {
    return [view.superview convertRect:view.frame toView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark -
- (void)setScrollEnabled:(BOOL)scrollEnabled {
    [self.collectionView setScrollEnabled:scrollEnabled];
}

- (void)setClearRate:(CGFloat)rate {
    self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:pow(rate, 3)];
}

- (void)hidePhotoBrowserWithFrame:(CGRect)frame {
    if (_currentIndex - _backwardImageCount < _imageViewArray.count) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
        cell.contentView.hidden = YES;
        
        //原图
        UIImageView *IV = self.imageViewArray[_currentIndex - _backwardImageCount];
        
        _animationIV.hidden = NO;
        _animationIV.frame = frame;
        [UIView animateWithDuration:0.25 animations:^{
            self.animationIV.frame = [self getImgVFrameInWindow:self.imageViewArray[self.currentIndex - self.backwardImageCount]];
            self.animationIV.layer.cornerRadius = IV.layer.cornerRadius;
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        } completion:^(BOOL finished) {
            IV.alpha = 1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - HeeePhotoCollectionCellDelegate
- (void)photoViewLongPress:(HeeePhotoView *)photoView {
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didLongPressAtIndex:)]) {
        [_delegate photoBrowser:self didLongPressAtIndex:self.currentIndex];
    }
}

- (void)photoViewStartDragImage:(HeeePhotoView *)photoView {
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:startDragImageAtIndex:)]) {
        [_delegate photoBrowser:self startDragImageAtIndex:self.currentIndex];
    }
}

- (void)photoViewEndDragImage:(HeeePhotoView *)photoView willClose:(BOOL)close {
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:endDragImageAtIndex:close:)]) {
        [_delegate photoBrowser:self endDragImageAtIndex:self.currentIndex close:close];
    }
}

- (void)photoViewSingleTap:(HeeePhotoView *)photoView {
    CGRect frame = [photoView.scrollview convertRect:photoView.imageview.frame toCoordinateSpace:self];
    [self hidePhotoBrowserWithFrame:frame];
}

#pragma mark - collectionDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(HPBScreenWidth + 20, HPBScreenHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HeeePhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HeeePhotoCollectionCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    cell.delegate = self;
    
    if (![self.reuseCellArray containsObject:cell]) {
        [self.reuseCellArray addObject:cell];
    }
    
    [self.reuseCellArray makeObjectsPerformSelector:@selector(adjustImageFrames)];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = (scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width;
    if (index >= 0 && index < self.dataArray.count) {
        if (self.currentIndex != index) {
            self.currentIndex = index;
            [self setupIndexLabel];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int autualIndex = scrollView.contentOffset.x/scrollView.bounds.size.width;
    //设置当前下标
    self.currentIndex = autualIndex;

    if (self.currentIndex >= self.dataArray.count) {
        [self removeFromSuperview];
        return;
    }
    
    //恢复所有view的zoomScale为1.0
    for (HeeePhotoCollectionCell *cell in self.reuseCellArray) {
        HeeePhotoCollectionCell *currentCell = (HeeePhotoCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
        if (cell != currentCell) {
            [cell resetZoomScale];
        }
    }
    
    //让所有原view可见
    for (int i = 0; i < self.imageViewArray.count; i++) {
        UIImageView *originalIV = self.imageViewArray[i];
        originalIV.alpha = 1;
    }
    
    //让滑动到对应的原view不可见，刷新animationIV
    if (_currentIndex - _backwardImageCount < self.imageViewArray.count) {
        UIImageView *IV = self.imageViewArray[_currentIndex - _backwardImageCount];
        IV.alpha = 0;
        self.animationIV.image = IV.image;
        self.animationIV.frame = [self getImageViewFrame:IV.image];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didShowImageAtIndex:)]) {
        [_delegate photoBrowser:self didShowImageAtIndex:autualIndex];
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-10, 0, HPBScreenWidth + 20, HPBScreenHeight) collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[HeeePhotoCollectionCell class] forCellWithReuseIdentifier:@"HeeePhotoCollectionCell"];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.delaysContentTouches = NO;
        
        _collectionView = collectionView;
    }
    
    return _collectionView;
}

- (NSMutableArray <HeeePhotoCollectionCellModel *>*)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableArray <HeeePhotoCollectionCell *>*)reuseCellArray {
    if (!_reuseCellArray) {
        _reuseCellArray = [NSMutableArray array];
    }
    
    return _reuseCellArray;
}

- (UIImageView *)animationIV {
    if (!_animationIV) {
        _animationIV = [UIImageView new];
        _animationIV.clipsToBounds = YES;
        _animationIV.contentMode = UIViewContentModeScaleAspectFill;
        _animationIV.hidden = YES;
    }
    
    return _animationIV;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:18];
        _indexLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        _indexLabel.clipsToBounds = YES;
    }
    
    return _indexLabel;
}

@end

