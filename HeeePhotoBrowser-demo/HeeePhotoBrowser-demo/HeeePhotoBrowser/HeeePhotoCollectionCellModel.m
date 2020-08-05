//
//  HeeePhotoCollectionCellModel.m
//  HeeePhotoBrowser-demo
//
//  Created by Heee on 2020/8/4.
//  Copyright © 2020 hgy. All rights reserved.
//

#import "HeeePhotoCollectionCellModel.h"
#import "SDWebImageDownloader.h"

@implementation HeeePhotoCollectionCellModel
- (void)loadImage:(void (^) (CGFloat downloadProgress))downloadBlock
        completed:(void (^) (UIImage *image))completedBlock {
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:_imageUrl] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (expectedSize > 0) {
                self.downloadProgress = (CGFloat)receivedSize/(CGFloat)expectedSize;
            }
            !downloadBlock?:downloadBlock(self.downloadProgress);
        });
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                self.image = image;
            }
            !completedBlock?:completedBlock(image);
        });
    }];
}

@end
