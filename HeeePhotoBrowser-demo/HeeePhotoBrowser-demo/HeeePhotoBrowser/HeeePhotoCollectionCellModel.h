//
//  HeeePhotoCollectionCellModel.h
//  HeeePhotoBrowser-demo
//
//  Created by Heee on 2020/8/4.
//  Copyright © 2020 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeeePhotoCollectionCellModel : NSObject
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,copy) NSString *imageUrl;
@property (nonatomic,assign) CGFloat downloadProgress;
- (void)loadImage:(void (^) (CGFloat downloadProgress))downloadBlock
        completed:(void (^) (UIImage *image))completedBlock;

@end
