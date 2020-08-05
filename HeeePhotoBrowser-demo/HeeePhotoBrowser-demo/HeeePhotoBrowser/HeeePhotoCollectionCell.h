//
//  HeeePhotoCollectionCell.h
//  HeeePhotoBrowser-demo
//
//  Created by Heee on 2020/8/4.
//  Copyright © 2020 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HeeePhotoCollectionCellModel;
@class HeeePhotoView;

@protocol HeeePhotoCollectionCellDelegate <NSObject>
@optional
- (void)photoViewLongPress:(HeeePhotoView *)photoView;
- (void)photoViewStartDragImage:(HeeePhotoView *)photoView;
- (void)photoViewEndDragImage:(HeeePhotoView *)photoView willClose:(BOOL)close;
- (void)photoViewSingleTap:(HeeePhotoView *)photoView;

@end

@interface HeeePhotoCollectionCell : UICollectionViewCell
@property (nonatomic,strong) HeeePhotoCollectionCellModel *model;
@property (nonatomic,weak) id <HeeePhotoCollectionCellDelegate> delegate;
- (void)resetZoomScale;

@end
