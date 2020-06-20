//
//  DetailViewController.m
//  HeeePhotoBrowser-demo
//
//  Created by hgy on 2018/10/17.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import "DetailViewController.h"
#import "HeeePhotoBrowser.h"
#import "UIImageView+WebCache.h"

@interface DetailViewController ()
@property (nonatomic,strong) NSMutableArray *IVArr;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片详情";
    self.view.backgroundColor = [UIColor whiteColor];
    _IVArr = [NSMutableArray array];
    
    NSArray *urlArr = @[
                        @"http://t7.baidu.com/it/u=3204887199,3790688592&fm=79&app=86&f=JPEG?w=4610&h=2968",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461180197&di=a23a9834a7b431c9c576f1b35bdb2298&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D3564877025%2C796183547%26fm%3D214%26gp%3D0.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461301631&di=fc9f49499318ba398a469f4be601b516&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2Fa%2F55f8c18720263.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461151728&di=2460be17ebf7d1ea7526ef25e00c6b76&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F5%2F532931489604e.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525606577982&di=2cba09247182622852d3d92e888b64d9&imgtype=0&src=http%3A%2F%2Fp8.qhimg.com%2Ft016ff4d49031ff3653.png",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539781470113&di=2d4e9600e7580773870ebb6b063b7173&imgtype=0&src=http%3A%2F%2Fimg2.ddove.com%2Fupload%2F20120906%2F060740261074.jpg"
                        ];
    
    CGFloat w = ([[UIScreen mainScreen] bounds].size.width - 2*10 - 2*5)/3;
    CGFloat h = w*3/4;
    
    for (int i = 0; i < urlArr.count; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10 + (w + 5)*(i%3), 100 + (h + 5)*(i/3), w, h)];
        [_IVArr addObject:iv];
        iv.clipsToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [iv addGestureRecognizer:tap];
        [iv sd_setImageWithURL:[NSURL URLWithString:urlArr[i]] placeholderImage:[UIImage imageNamed:@"H_默认图片加载.png"]];
        [self.view addSubview:iv];
    }
}

- (void)imageClick:(UIGestureRecognizer *)gestureRecognizer {
    UIView *IV = gestureRecognizer.view;
    [HeeePhotoBrowser showWithImageViews:_IVArr currentIndex:[_IVArr indexOfObject:IV] highQualityImageArray:nil andPreLoadImageCount:2 andDelegate:self];
}

#pragma mark - HeeePhotoBrowserDelegate
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didShowImageAtIndex:(NSInteger)index {
    NSLog(@"已经展示第%zd张图片",index);
}

- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didDisappearAtIndex:(NSInteger)index {
    NSLog(@"浏览器已经消失");
}

- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didLongPressAtIndex:(NSInteger)index {
    NSLog(@"长按了第%zd张图片",index);
}

- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser startDragImageAtIndex:(NSInteger)index {
    NSLog(@"开始拖动第%zd张图片",index);
}

- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser endDragImageAtIndex:(NSInteger)index close:(BOOL)close {
    NSLog(@"第%zd张图片拖动结束",index);
    
    if (close) {
        NSLog(@"浏览器将要消失");
    }else{
        NSLog(@"浏览器不会消失");
    }
}

@end
