//
//  ViewController.m
//  HeeePhotoBrowser-demo
//
//  Created by hgy on 2018/10/17.
//  Copyright © 2018年 hgy. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "HeeePhotoBrowser.h"

@interface ViewController ()<HeeePhotoBrowserDelegate>
@property (nonatomic,strong) NSMutableArray *IVArr;
@property (nonatomic,strong) NSArray *urlArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ViewController";
    self.view.backgroundColor = [UIColor whiteColor];
    _IVArr = [NSMutableArray array];
    _urlArr = @[
                @"http://t7.baidu.com/it/u=3204887199,3790688592&fm=79&app=86&f=JPEG?w=4610&h=2968",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461180197&di=a23a9834a7b431c9c576f1b35bdb2298&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D3564877025%2C796183547%26fm%3D214%26gp%3D0.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461301631&di=fc9f49499318ba398a469f4be601b516&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2Fa%2F55f8c18720263.jpg",
                ];
    
    CGFloat kUIScreen_width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat w = (kUIScreen_width - 2*10 - 2*5)/3;
    CGFloat h = w*3/4;
    
    NSArray *imageName = @[@"IMG_0168.JPG",@"IMG_0169.JPG",@"IMG_0170.JPG"];
    for (int i = 0; i < imageName.count; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10 + (w + 5)*(i%3), 100 + (h + 5)*(i/3), w, h)];
        iv.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        [_IVArr addObject:iv];
        iv.clipsToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [iv addGestureRecognizer:tap];
        iv.image = [UIImage imageNamed:imageName[i]];
        [self.view addSubview:iv];
    }
}

- (void)imageClick:(UIGestureRecognizer *)gestureRecognizer {
    NSUInteger currentIndex = [_IVArr indexOfObject:gestureRecognizer.view];
    [HeeePhotoBrowser showWithImageViews:_IVArr currentIndex:currentIndex highQualityImageUrls:_urlArr];
}

@end
